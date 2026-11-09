import numpy as np
import xarray as xr
from netCDF4 import Dataset
import pandas as pd
import time
import logging
from typing import List, Optional, Tuple
from pydantic import BaseModel, PrivateAttr

class NcBase(BaseModel):
    path: str
    variable: str
    alias: Optional[str] = None
    lags: Optional[List[int]] = None
    latitude_name: Optional[str] = None
    longitude_name: Optional[str] = None
    date_name: Optional[str] = None
    chunk_size: Optional[Tuple[int, ...]] = None
    ds: Optional[xr.Dataset] = None
    _logger: logging.Logger = PrivateAttr()
    model_config = {"arbitrary_types_allowed": True}

    def __init__(self, **data):
        super().__init__(**data)
        self._set_logger()
        self._get_attributes()
        self._get_chunk_size()

    def _get_attributes(self):

        self.ds = xr.open_dataset(self.path, chunks="auto")
        context = {var: idx for idx, var in enumerate(self.ds.variables)}
        self.latitude_name = self._get_names('lat', context)
        self.longitude_name = self._get_names('lon', context)
        self.date_name = self._get_names('date', context)
        self._logger.info(f"Detected NetCDF variables -> latitude: {self.latitude_name}, longitude: {self.longitude_name}, date: {self.date_name}")

    def _set_logger(self):
        self._logger = logging.getLogger("NetCDF Handler")
        self._logger.setLevel(logging.INFO)
        if not self._logger.handlers:
            ch = logging.StreamHandler()
            ch.setLevel(logging.INFO)
            formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
            ch.setFormatter(formatter)
            self._logger.addHandler(ch)

    def _get_chunk_size(self):
        with Dataset(self.path, "r") as nc:
            var = nc.variables[self.variable]
            chunk_info = var.chunking()

            if chunk_info == 'contiguous':
                self.chunk_size=tuple(var.shape)
            else:
                self.chunk_size=tuple(chunk_info)

            self._logger.info(f"Chunk size: {self.chunk_size}")

    @staticmethod
    def _get_names(subject:str, context:dict):

        possibles=[]
        if subject == 'lat':
            possibles = ['lat', 'latitude', 'Latitude']
        elif subject == 'lon':
            possibles = ['lon', 'longitude', 'Longitude', 'LON']
        elif subject == 'date':
            possibles = ['time', 'date', 'DATE', 'Time', 'sdate', 'month']

        name = next((var for var in possibles if var in context), None)
        return name

    def get_values(self, lat:float, lon:float, date:str = None):

        results=[]
        if self.is_date_required():

            if date is None:
                raise ValueError(f"Missing {self.date_name}.")

            date = pd.to_datetime(date)
            if self.is_month_required():
                month = date.month
                value = self.ds[self.variable].sel({self.latitude_name: lat, self.longitude_name: lon}, method='nearest'
                ).sel({self.date_name: month}).compute().values
                results.append(value.item())
            else:
                max_lag = max(self.lags)
                start_date = date - pd.Timedelta(days=max_lag)
                end_date = date
                values = self.ds[self.variable].sel({self.latitude_name: lat, self.longitude_name: lon}, method='nearest'
                ).sel({self.date_name: slice(start_date, end_date)}).compute().values
                results.extend([np.mean(values[-lag:]) for lag in self.lags])
        else:
            value = self.ds[self.variable].sel({self.latitude_name: lat, self.longitude_name: lon}, method='nearest'
            ).compute().values
            results.append(value.item())

        return results

    def get_dataframe(self, coordinates: pd.DataFrame):

        start = time.time()
        self._logger.info(f"Starting extraction of values for variable {self.variable}")
        context = {col: idx for idx, col in enumerate(coordinates.columns)}
        lat_col = self._get_names('lat', context)
        lon_col = self._get_names('lon', context)
        date_col = self._get_names('date', context) or ''

        if lat_col is None:
            raise ValueError("Latitude column not found in the coordinates DataFrame.")
        if lon_col is None:
            raise ValueError("Longitude column not found in the coordinates DataFrame.")

        data = []
        for row in coordinates.itertuples():
            lat = getattr(row, lat_col)
            lon = getattr(row, lon_col)
            date = getattr(row, date_col, None)
            values = self.get_values(lat, lon, date)
            data.append(values)

        df = pd.DataFrame(data, columns=self.get_headers())
        df.insert(0, lat_col, coordinates[lat_col].values)
        df.insert(1, lon_col, coordinates[lon_col].values)
        if self.is_date_required() and date_col:
            df.insert(2, date_col, coordinates[date_col].values)

        self._logger.info(f"Extracting values of variable {self.variable} is finished. Average time per coordinate: {(time.time() - start) / len(coordinates):.2f} seconds.")
        self.ds.close()

        return df

    def get_headers(self, prefix: str = None):
        prefix = prefix or ""
        variable_alias = self.alias or self.variable
        prefix += f"{variable_alias}"
        if self.lags is None:
            return [prefix]
        return [f"{prefix}_{lag}" for lag in self.lags]

    def is_date_required(self):
        return self.date_name is not None
    def is_month_required(self):
        return self.date_name == 'month'
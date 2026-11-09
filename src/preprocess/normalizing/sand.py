# 00 Bash Script

# 01 Load Library =========================================
import netCDF4
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import xarray as xr


# 01.1 Define the convolution function
def convolve_2d(data_matrix, kernel):
    # Get dimensions of the data matrix and kernel
    n_rows, n_cols = data_matrix.countries_shape
    kernel_rows, kernel_cols = kernel.countries_shape

    # Define padding size (half kernel size)
    pad_size = (kernel_rows // 2, kernel_cols // 2)

    # Check if padding is needed
    if any(pad < 0 for pad in pad_size):
        raise ValueError("Kernel size cannot be larger than the data matrix dimensions.")

    # Add padding around the data matrix
    padded_matrix = np.pad(data_matrix, ((pad_size[0], pad_size[0]), (pad_size[1], pad_size[1])), mode='constant')

    # Convolution with padding
    convolved_matrix = np.zeros_like(data_matrix, dtype=np.float64)

    for i in range(n_rows):
        for j in range(n_cols):
            window = padded_matrix[i:i + kernel_rows, j:j + kernel_cols]
            convolved_matrix[i, j] = np.sum(1.0 * window * kernel)
            n = i * n_cols + j
            nt = n_rows * n_cols
            prg = n/nt * 100
            if prg == int(prg):
                print('Progress: ', prg, '%')

    return convolved_matrix


# 02 Load data set ========================================

# The soil_class_horizon_01.nc file contains the soil class definition for the first horizon of the soil profile. and
# each value refer an ID on the soil_class definition.csv file. Thus, we need to read the soil_class definition.csv file
# to get the soil class definition, and extract the sand and clay content for each class.
scFile = "/Volumes/Researches/CHS/CLIMOS/SFFA/resources/data/raw/v2/morphology/soil_classdefinition.csv"
sc = pd.read_csv(scFile)

# 03 Load Horizon
# Open the netCDF file
hrFile = "/Users/soheili/Desktop/soil_class_horizon_01.nc"
hr = xr.open_dataset(hrFile)
# subset of the data lat1:lat2, lon1:lon2
hr = hr.sel(lat=slice(35, 36), lon=slice(33, 34))

# Define the window size for the convolution
window_size = 5

# Create the averaging kernel
kernel = np.full((window_size, window_size), 1.0 / (window_size * window_size))

# 04. Apply the convolution filter ============================================

# Extract the sand and clay content for each soil class
#clay = hr['Band1'].values.reshape(-1).astype(int)
#clay = sc.loc[clay - 1, 'CLAY'].values
#clay = clay.reshape(hr['Band1'].shape)

sand = hr['Band1'].values.reshape(-1).astype(int)
sand = sc.loc[sand - 1, 'SAND'].values
sand = sand.reshape(hr['Band1'].shape)


#clay_convolved = convolve_2d(clay, kernel)
sand_convolved = convolve_2d(sand, kernel)

# writing the output to a netCDF file such that lat and lon are the same as the input file and variable name is clay
# clay_convolved = xr.DataArray(clay_convolved, coords=[hr.lat, hr.lon], dims=['lat', 'lon'])
#clay = xr.DataArray(clay_convolved, coords=[hr.lat, hr.lon], dims=['lat', 'lon'], name='clay')
#clay = clay.rename("clay")
#path = '/Users/soheili/Desktop/clay.nc'
#clay.to_netcdf(path)

sand = xr.DataArray(sand_convolved, coords=[hr.lat, hr.lon], dims=['lat', 'lon'], name='sand')
sand = sand.rename("sand")
path = '/Users/soheili/Desktop/sand.nc'
sand.to_netcdf(path)

path = 'sand.nc'


# Latitude:  35.0933
# Longitude:  33.4334
# Observed Sand:  0.3456
# Observed Clay:  0.2908

# 05 Test the convolution function ============================================

ds = xr.open_dataset(path)
clay = ds['clay'].sel(lat=35.0933, lon=33.4334, method='nearest').values
ds.close()
print('Clay: ', clay)

ds = xr.open_dataset(path)
sand = ds['sand'].sel(lat=35.0933, lon=33.4334, method='nearest').values
ds.close()
print('Sand: ', sand)


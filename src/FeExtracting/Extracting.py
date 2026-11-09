import argparse
import pandas as pd
import os
from NcBase import NcBase

def main():
    args = parser.parse_args()

    nc_path = args.netcdf
    coord_path = args.coord_file
    variable = args.variable
    alias = args.alias
    output_file = f"{alias or variable}.csv"
    output_path = os.path.join(args.output_dir, output_file)
    lags = args.lags

    print("=== Extraction Parameters ===")
    print(f"NetCDF Path: {nc_path}")
    print(f"Coordinates File: {coord_path}")
    print(f"Variable: {variable}")
    print(f"Alias: {alias}")
    print(f"Output Path: {output_path}")
    print(f"Lags: {lags}")

    # Load coordinates
    coordinates_df = pd.read_csv(coord_path)

    # Initialize NetCDF handler
    nc_handler = NcBase(path=nc_path, variable=variable, alias=alias, lags=lags)

    # Extract data for all coordinates
    result_df = nc_handler.get_dataframe(coordinates=coordinates_df)

    # Save the result to CSV
    result_df.to_csv(output_path, index=False)
    print(f"Extracted data saved to {output_path}")


if __name__  == "__main__":
    parser = argparse.ArgumentParser(description="Extracting features from NetCDF files based on coordinates and dates.")
    parser.add_argument('--netcdf', type=str, required=True, help='Path to the NetCDF file')
    parser.add_argument('--coord_file', type=str, required=True, help='Path to the coordinates CSV file')
    parser.add_argument('--variable', type=str, required=True, help='Variable name in the NetCDF file')
    parser.add_argument('--alias', type=str, required=False, default=None, help='Alias name for the variable')
    parser.add_argument('--lags', type=int, nargs='+', default=None, help='List of lag days for rolling averages')
    parser.add_argument('--output_dir', type=str, required=True, help='Path to save the output DataFrame CSV file')
    main()
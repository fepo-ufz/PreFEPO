#!/bin/bash

# Input variables, including coordinates files, NetCDF files, and output file

netcdf_file="$1"
variable_name="$2"
csv_file="$3"

echo "Extract meteo is started."
# List of lag windows in days
lags=(1 7 14 21 28 35 42 49 56 63 70 90 120 150 180 210 240 270 300 330 365)

# Output CSV file for this specific NetCDF file
output_csv="coordinates_extracted_${netcdf_file%.nc}.csv"

# Create the header for the output CSV file, including columns for each lag
echo -n "lat,lon,date" > $output_csv
for lag in "${lags[@]}"; do
  echo -n ",${variable_name}_${lag}" >> $output_csv
done
echo "" >> $output_csv  # New line after the header

#check the netcdf file is exist or not
if [ ! -f "$netcdf_file" ]; then
  echo "NetCDF file not found: $netcdf_file"
  exit 1
fi

#check the csv file is exist or not
if [ ! -f "$csv_file" ]; then
  echo "CSV file not found: $csv_file"
  exit 1
fi

# Loop through each line in the CSV
while IFS=, read -r lat lon sdate; do

  # Skip the header row
  if [ "$lat" != "lat" ]; then
    # Prepare a line for the output CSV
    output_line="$lat,$lon,$sdate"

    # Iterate over each lag value
    for lag in "${lags[@]}"; do
      # Compute the start date for the current lag and set end_date as the CSV date
      start_date=$(date -d "$sdate - $lag days" +"%Y-%m-%d")
      end_date=$sdate  # The end date is always the date from the CSV

      echo "start_date: $start_date"
      echo "end_date: $end_date"


      # Extract the mean value directly using CDO, replacing 'temperature' with the input variable name
      mean_value=$(cdo -output -timmean -seldate,$start_date,$end_date -remapnn,lon=${lon}_lat=${lat} -selname,"$variable_name" "$netcdf_file")


      # Append the mean value to the output line
      output_line="$output_line,$mean_value"
    done

    # Write the result to the output CSV file
    echo "$output_line" >> $output_csv
  fi
done < "$csv_file"
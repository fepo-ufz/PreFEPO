#!/bin/bash
#SBATCH --job-name=normalize_meteo
#SBATCH --array=1-5
#SBATCH --output=normalize_nc_files_2_%A_%a.out
#SBATCH --error=normalize_nc_files_2_%A_%a.err
#SBATCH --time=0-10:00:00
#SBATCH --mem-per-cpu=50G

module load foss/2022b CDO/2.2.2

#!/bin/bash

# CSV file with coordinates
csv_file="./coorddate.csv"

case $SLURM_ARRAY_TASK_ID in
    1)
      echo "Processing tmin.nc..."
      ./meteoExtract.sh "tmin.nc" "tmin_normalized" "$csv_file"
      ;;

    2)
      echo "Processing tmax.nc..."
      ./meteoExtract.sh "tmax.nc" "tmax_normalized" "$csv_file"
      ;;

    3)
      echo "Processing tavg.nc..."
      ./meteoExtract.sh "tavg.nc" "tavg_normalized" "$csv_file"
      ;;

    4)
      echo "Processing pre.nc..."
      ./meteoExtract.sh "pre.nc" "pre_normalized" "$csv_file"
      ;;

    5)
      echo "Processing pet.nc..."
      ./meteoExtract.sh "pet.nc" "pet_normalized" "$csv_file"
      ;;
  esac

echo "All NetCDF files have been processed."
#!/bin/bash
#SBATCH --job-name=normalize_meteo
#SBATCH --array=1-5
#SBATCH --output=normalize_nc_files_%A_%a.out
#SBATCH --error=normalize_nc_files_%A_%a.err
#SBATCH --time=0-10:00:00
#SBATCH --mem-per-cpu=50G

# If the value is NA, keep it as NA.
# If the value is greater than the max, set it to 1.
# If the value is less than the min, set it to 0.
# For values within the range, apply the Min-Max normalization formula.

module load foss/2022b CDO/2.2.2

NA_VALUE=-9999

# Switch case to run different commands for each array task
case $SLURM_ARRAY_TASK_ID in

  1)
    # Task 1: Normalize tmin.nc
    cdo -z zip_4 expr,'tmin_normalized=tmin=='"$NA_VALUE"'?tmin:(tmin>50?1:(tmin<-40?0:(tmin-(-40))/(50-(-40))))' tmin.nc tmin_normalized.nc
    ;;

  2)
    # Task 2: Normalize tmax.nc
    cdo -z zip_4 expr,'tmax_normalized=tmax=='"$NA_VALUE"'?tmax:(tmax>50?1:(tmax<-40?0:(tmax-(-40))/(50-(-40))))' tmax.nc tmax_normalized.nc
    ;;

  3)
    # Task 3: Normalize tavg.nc
    cdo -z zip_4 expr,'tavg_normalized=tavg=='"$NA_VALUE"'?tavg:(tavg>50?1:(tavg<-40?0:(tavg-(-40))/(50-(-40))))' tavg.nc tavg_normalized.nc
    ;;

  4)
    # Task 4: Normalize pre.nc
    cdo -z zip_4 expr,'pre_normalized=pre=='"$NA_VALUE"'?pre:(pre>200?1:(pre<0?0:(pre-0)/(200-0)))' pre.nc pre_normalized.nc
    ;;

  5)
    # Task 5: Normalize pet.nc
    cdo -z zip_4 expr,'pet_normalized=pet=='"$NA_VALUE"'?pet:(pet>300?1:(pet<0?0:(pet-0)/(300-0)))' pet.nc pet_normalized.nc
    ;;

esac

echo "Normalization completed for all files!"
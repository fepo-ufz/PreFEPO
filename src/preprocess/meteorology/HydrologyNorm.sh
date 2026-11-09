#!/bin/bash
#SBATCH --job-name=normalize_Hydrology
#SBATCH --array=1-6
#SBATCH --output=normalize_nc_files_%A_%a.out
#SBATCH --error=normalize_nc_files_%A_%a.err
#SBATCH --time=0-10:00:00
#SBATCH --mem-per-cpu=50G

module load foss/2022b CDO/2.2.2

NA_VALUE=-9999

# Switch case to run different commands for each array task
case $SLURM_ARRAY_TASK_ID in

  1)
    # Task 1: Normalize SWC_L1.nc
    cdo -z zip_4 expr,'SWC_L01=SWC_L01=='"$NA_VALUE"'?SWC_L01:(SWC_L01>40?1:(SWC_L01<0?0:(SWC_L01-0)/(40-0)))' SWC_L01.nc SWC_L01_normalized.nc
    ;;

  2)
    # Task 2: Normalize SWC_L2.nc
    cdo -z zip_4 expr,'SWC_L02=SWC_L02=='"$NA_VALUE"'?SWC_L02:(SWC_L02>70?1:(SWC_L02<0?0:(SWC_L02-0)/(70-0)))' SWC_L02.nc SWC_L02_normalized.nc
    ;;

  3)
    # Task 3: Normalize SWC_L3.nc
    cdo -z zip_4 expr,'SWC_L03=SWC_L03=='"$NA_VALUE"'?SWC_L03:(SWC_L03>100?1:(SWC_L03<0?0:(SWC_L03-0)/(100-0)))' SWC_L03.nc SWC_L03_normalized.nc
    ;;

  4)
    # Task 4: Normalize SWC_L4.nc
    cdo -z zip_4 expr,'SWC_L04=SWC_L04=='"$NA_VALUE"'?SWC_L04:(SWC_L04>110?1:(SWC_L04<0?0:(SWC_L04-0)/(110-0)))' SWC_L04.nc SWC_L04_normalized.nc
    ;;

  5)
    # Task 5: Normalize SWC_L5.nc
    cdo -z zip_4 expr,'SWC_L05=SWC_L05=='"$NA_VALUE"'?SWC_L05:(SWC_L05>300?1:(SWC_L05<0?0:(SWC_L05-0)/(300-0)))' SWC_L05.nc SWC_L05_normalized.nc
    ;;

  6)
    # Task 5: Normalize SWC_L6.nc
    cdo -z zip_4 expr,'SWC_L06=SWC_L06=='"$NA_VALUE"'?SWC_L06:(SWC_L06>600?1:(SWC_L06<0?0:(SWC_L06-0)/(600-0)))' SWC_L06.nc SWC_L06_normalized.nc
    ;;
esac

echo "Normalization completed for all files!"
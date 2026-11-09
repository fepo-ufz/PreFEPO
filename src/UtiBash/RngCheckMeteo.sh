#!/bin/bash
#SBATCH --job-name=checking_meteorology
#SBATCH --array=1-5
#SBATCH --output=normalize_nc_files_%A_%a.out
#SBATCH --error=normalize_nc_files_%A_%a.err
#SBATCH --time=0-10:00:00
#SBATCH --mem-per-cpu=50G

module load foss/2022b CDO/2.2.2

###################################################
# Settings
###################################################
INDIR="/gpfs1/data/climos/FEPO/ProcessedData/Meteorology/Norm"
TODAY=$(date +"%Y%m%d")

echo "Input directory  : $INDIR"


###################################################
# Select file + variable name
###################################################
case $SLURM_ARRAY_TASK_ID in
  1) FNAME="tmin.nc"; VARNAME="tmin_normalized" ;;
  2) FNAME="tmax.nc"; VARNAME="tmax_normalized" ;;
  3) FNAME="tavg.nc"; VARNAME="tavg_normalized" ;;
  4) FNAME="pre.nc";  VARNAME="pre_normalized"  ;;
  5) FNAME="pet.nc";  VARNAME="pet_normalized"  ;;
esac

INFILE="${INDIR}/${FNAME}"
OUTTXT="${INDIR}/${FNAME%.nc}_minmax.txt"

echo "Processing file: $INFILE"
echo "Variable       : $VARNAME"


###################################################
# Compute Global Min/Max
###################################################
echo "Computing min/max..."

global_min=$(cdo -s output -fldmin -timmin -selname,"$VARNAME" "$INFILE")
global_max=$(cdo -s output -fldmax -timmax -selname,"$VARNAME" "$INFILE")

echo "Global Min: $global_min"
echo "Global Max: $global_max"


###################################################
# Save Min/Max to Text File
###################################################
{
  echo "File       : $INFILE"
  echo "Variable   : $VARNAME"
  echo "Date       : $TODAY"
  echo "Global Min : $global_min"
  echo "Global Max : $global_max"
} > "$OUTTXT"

echo "Min/Max values saved in: $OUTTXT"
echo "Task $SLURM_ARRAY_TASK_ID completed."
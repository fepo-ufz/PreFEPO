#!/bin/bash
#SBATCH --job-name=extract_meteo
#SBATCH --array=1-7
#SBATCH --output=./Logs/logs/extract_meteo_%A_%a.out
#SBATCH --error=./Logs/logs/extract_meteo_%A_%a.err
#SBATCH --time=0-10:00:00
#SBATCH --mem-per-cpu=15G

module purge
module load foss/2022b
module load CDO/2.2.2
module load Conda/24.3.0
source activate envFepo     # <-- change to your env

export LC_ALL=C

##########################################
# Input / Output Directories
##########################################

INDIR="/gpfs1/data/climos/FEPO/ProcessedData/Meteorology"
OUTDIR="$1"
COORD_FILE="$2"
lags=(1 7 14 21 28 35 42 49 56 63 70 90 120 150 180 210 240  270 300 330 365)

mkdir -p "$OUTDIR"

if [ -z "$SLURM_ARRAY_TASK_ID" ]; then
    SLURM_ARRAY_TASK_ID=1
fi

##########################################
# Select file
##########################################
case "$SLURM_ARRAY_TASK_ID" in
    1) netcdf="${INDIR}/tmin.nc"; var="tmin"; alias="tmin" ;;
    2) netcdf="${INDIR}/tmax.nc"; var="tmax"; alias="tmax" ;;
    3) netcdf="${INDIR}/tavg.nc"; var="tavg"; alias="tavg" ;;
    4) netcdf="${INDIR}/pre.nc";  var="pre"; alias="pre"  ;;
    5) netcdf="${INDIR}/pet.nc";  var="pet"; alias="pet" ;;
    6) netcdf="${INDIR}/tmin_era.nc"; var="tmin"; alias="tmin_era" ;;
    7) netcdf="${INDIR}/tmax_era.nc"; var="tmax"; alias="tmax_era" ;;
    *) echo "Invalid ID"; exit 1 ;;
esac

python src/FeExtracting/Extracting.py \
    --netcdf "$netcdf" \
    --coord_file "$COORD_FILE" \
    --output_dir "$OUTDIR" \
    --variable "$var" \
    --alias "$alias" \
    --lags "${lags[@]}"

echo "Extraction completed for $var"
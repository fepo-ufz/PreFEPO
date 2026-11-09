#!/bin/bash
#SBATCH --job-name=extract_long_meteo
#SBATCH --array=1-3
#SBATCH --output=./Logs/logs/extract_long_meteo_%A_%a.out
#SBATCH --error=./Logs/logs/extract_long_meteo_%A_%a.err
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

# These are long-term monthly data; no lags needed, therefore not defined

mkdir -p "$OUTDIR"

if [ -z "$SLURM_ARRAY_TASK_ID" ]; then
    SLURM_ARRAY_TASK_ID=1
fi

##########################################
# Select file
##########################################
case "$SLURM_ARRAY_TASK_ID" in
    1) netcdf="${INDIR}/LM_pet.nc"; var="pet"; alias="LM_pet" ;;
    2) netcdf="${INDIR}/LM_pre.nc"; var="pre"; alias="LM_pre" ;;
    3) netcdf="${INDIR}/LM_tavg.nc"; var="tavg"; alias="LM_tavg" ;;
    *) echo "Invalid ID"; exit 1 ;;
esac

python src/FeExtracting/Extracting.py \
    --netcdf "$netcdf" \
    --coord_file "$COORD_FILE" \
    --output_dir "$OUTDIR" \
    --variable "$var" \
    --alias "$alias"

echo "Extraction completed for $var"

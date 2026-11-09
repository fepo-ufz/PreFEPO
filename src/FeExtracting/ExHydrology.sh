#!/bin/bash
#SBATCH --job-name=extract_hydro
#SBATCH --array=1-6
#SBATCH --output=./Logs/logs/extract_hydro_%A_%a.out
#SBATCH --error=./Logs/logs/extract_hydro_%A_%a.err
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

INDIR="/gpfs1/data/climos/FEPO/ProcessedData/Hydrology"
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
    1) netcdf="${INDIR}/SWC_L01.nc"; var="SWC_L01"; alias="swc1" ;;
    2) netcdf="${INDIR}/SWC_L02.nc"; var="SWC_L02"; alias="swc2" ;;
    3) netcdf="${INDIR}/SWC_L03.nc"; var="SWC_L03"; alias="swc3" ;;
    4) netcdf="${INDIR}/SWC_L04.nc"; var="SWC_L04"; alias="swc4" ;;
    5) netcdf="${INDIR}/SWC_L05.nc"; var="SWC_L05"; alias="swc5" ;;
    6) netcdf="${INDIR}/SWC_L06.nc"; var="SWC_L06"; alias="swc6" ;;
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
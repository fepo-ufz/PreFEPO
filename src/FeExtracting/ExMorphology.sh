#!/bin/bash
#SBATCH --job-name=extract_morph
#SBATCH --array=1-6
#SBATCH --output=./Logs/logs/extract_morph_%A_%a.out
#SBATCH --error=./Logs/logs/extract_morph_%A_%a.err
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

INDIR="/gpfs1/data/climos/FEPO/ProcessedData/Morphology"
OUTDIR="$1"
COORD_FILE="$2"

mkdir -p "$OUTDIR"

if [ -z "$SLURM_ARRAY_TASK_ID" ]; then
    SLURM_ARRAY_TASK_ID=1
fi

##########################################
# Select file
##########################################
case "$SLURM_ARRAY_TASK_ID" in
    1) netcdf="${INDIR}/aspect.nc";     var="aspect";     alias="aspect"     ;;
    2) netcdf="${INDIR}/slope.nc";      var="slope";      alias="slope"      ;;
    3) netcdf="${INDIR}/elevation.nc";  var="elevation";  alias="elevation"  ;;
    4) netcdf="${INDIR}/sand.nc";       var="sand";       alias="sand"       ;;
    5) netcdf="${INDIR}/clay.nc";       var="clay";       alias="clay"       ;;
    6) netcdf="${INDIR}/lc.nc";         var="lc";         alias="lc"         ;;
    *) echo "Invalid ID"; exit 1 ;;
esac

python src/FeExtracting/Extracting.py \
    --netcdf "$netcdf" \
    --coord_file "$COORD_FILE" \
    --output_dir "$OUTDIR" \
    --variable "$var" \
    --alias "$alias"

echo "Extraction completed for $var"
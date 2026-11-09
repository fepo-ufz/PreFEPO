#!/bin/bash
#SBATCH --job-name=rechunk_meteo
#SBATCH --array=1-7
#SBATCH --output=rechunk_meteo_%A_%a.out
#SBATCH --error=rechunk_meteo_%A_%a.err
#SBATCH --time=3-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=50G

module purge
module load foss/2022b
module load netCDF/4.9.0  # Provides nccopy
export LC_ALL=C

##########################################
# Input / Output Directories
##########################################

INDIR="/gpfs1/data/climos/FEPO/ProcessedData/Meteorology/Norm"
OUTDIR="/gpfs1/data/climos/FEPO/ProcessedData/Meteorology/Norm/rechunked"

mkdir -p "$OUTDIR"

if [ -z "$SLURM_ARRAY_TASK_ID" ]; then
    SLURM_ARRAY_TASK_ID=1
fi

##########################################
# Select file
##########################################
case "$SLURM_ARRAY_TASK_ID" in
    1) infile="${INDIR}/tmin.nc";  var="tmin" ;;
    2) infile="${INDIR}/tmax.nc";  var="tmax" ;;
    3) infile="${INDIR}/tavg.nc";  var="tavg" ;;
    4) infile="${INDIR}/pre.nc";   var="pre"  ;;
    5) infile="${INDIR}/pet.nc";   var="pet"  ;;
    6) infile="${INDIR}/tmin_era.nc";  var="tmin" ;;
    7) infile="${INDIR}/tmax_era.nc";  var="tmax" ;;
    *) echo "Invalid SLURM_ARRAY_TASK_ID"; exit 1 ;;
esac

outfile="${OUTDIR}/$(basename ${infile%.nc}).nc"

echo "------------------------------------------"
echo "Rechunking NetCDF file:"
echo " Input : $infile"
echo " Var   : $var"
echo " Output: $outfile"
echo " Chunk : (365, 100, 100)"
echo "------------------------------------------"

##########################################
# Rechunk using nccopy
##########################################

# -k 4 → output as NetCDF4
# -d 4 → gzip level 4
# -c var:365,4,4 → chunk sizes

nccopy -k 4 -d 1 -c ${var}:365,100,100 "$infile" "$outfile"
#nccopy -d 4 out.nc out_compressed.nc

echo "Done!"
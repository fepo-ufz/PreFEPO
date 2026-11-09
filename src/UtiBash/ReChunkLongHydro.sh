#!/bin/bash
#SBATCH --job-name=rechunk_long_hydro
#SBATCH --array=1-6
#SBATCH --output=rechunk_long_hydro_%A_%a.out
#SBATCH --error=rechunk_long_hydro_%A_%a.err
#SBATCH --time=0-10:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G

module purge
module load foss/2022b
module load netCDF/4.9.0
export LC_ALL=C

##########################################
# Input / Output Directories
##########################################

INDIR="/gpfs1/data/climos/FEPO/ProcessedData/Hydrology/LongMonthly/Norm"
OUTDIR="/gpfs1/data/climos/FEPO/ProcessedData/Hydrology/LongMonthly/Norm/rechunked"

mkdir -p "$OUTDIR"

if [ -z "$SLURM_ARRAY_TASK_ID" ]; then
    SLURM_ARRAY_TASK_ID=1
fi

##########################################
# Select file
##########################################
case "$SLURM_ARRAY_TASK_ID" in
    1) infile="${INDIR}/SWC_L01.nc"; var="SWC_L01";;
    2) infile="${INDIR}/SWC_L02.nc"; var="SWC_L02";;
    3) infile="${INDIR}/SWC_L03.nc"; var="SWC_L03";;
    4) infile="${INDIR}/SWC_L04.nc"; var="SWC_L04";;
    5) infile="${INDIR}/SWC_L05.nc"; var="SWC_L05";;
    6) infile="${INDIR}/SWC_L06.nc"; var="SWC_L06";;
    *) echo "Invalid ID"; exit 1 ;;
esac

outfile="${OUTDIR}/$(basename ${infile%.nc}).nc"

echo "------------------------------------------"
echo "Rechunking NetCDF file:"
echo " Input : $infile"
echo " Var   : $var"
echo " Output: $outfile"
echo " Chunk : (1, 100, 100)"
echo "------------------------------------------"

##########################################
# Rechunk using nccopy
##########################################

# -k 4 → output as NetCDF4
# -d 4 → gzip level 4
# -c var:1,100,100 → chunk sizes

nccopy -k 4 -d 1 -c ${var}:1,100,100 "$infile" "$outfile"
#nccopy -d 4 out.nc out_compressed.nc

echo "Done!"
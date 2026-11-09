#!/bin/bash
#SBATCH --job-name=rechunk_morpho
#SBATCH --array=1-5
#SBATCH --output=rechunk_morpho_%A_%a.out
#SBATCH --error=rechunk_morpho_%A_%a.err
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

INDIR="/gpfs1/data/climos/FEPO/ProcessedData/Morphology/Norm"
OUTDIR="/gpfs1/data/climos/FEPO/ProcessedData/Morphology/Norm/rechunked"

mkdir -p "$OUTDIR"

if [ -z "$SLURM_ARRAY_TASK_ID" ]; then
    SLURM_ARRAY_TASK_ID=1
fi

##########################################
# Select file
##########################################
case "$SLURM_ARRAY_TASK_ID" in
    1) infile="${INDIR}/aspect.nc";    var="aspect"    ;;
    2) infile="${INDIR}/slope.nc";     var="slope"     ;;
    3) infile="${INDIR}/elevation.nc"; var="elevation" ;;
    4) infile="${INDIR}/sand.nc";      var="sand"      ;;
    5) infile="${INDIR}/clay.nc";      var="clay"      ;;
    6) infile="${INDIR}/lc.nc";        var="lc"        ;;
    *) echo "Invalid SLURM_ARRAY_TASK_ID"; exit 1      ;;
esac

outfile="${OUTDIR}/$(basename ${infile%.nc}).nc"

echo "------------------------------------------"
echo "Rechunking NetCDF file:"
echo " Input : $infile"
echo " Var   : $var"
echo " Output: $outfile"
echo " Chunk : (100, 100)"
echo "------------------------------------------"

##########################################
# Rechunk using nccopy
##########################################

# -k 4 → output as NetCDF4
# -d 4 → gzip level 4
# -c var:100,100 → chunk sizes

nccopy -k 4 -d 1 -c ${var}:100,100 "$infile" "$outfile"
#nccopy -d 4 out.nc out_compressed.nc

echo "Done!"
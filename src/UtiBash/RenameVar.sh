#!/bin/bash
#SBATCH --job-name=rename_vars
#SBATCH --array=1-4
#SBATCH --output=rename_%A_%a.out
#SBATCH --error=rename_%A_%a.err
#SBATCH --time=0-10:00:00
#SBATCH --mem-per-cpu=50G

module purge
module load foss/2022b
module load CDO/2.2.2

export LC_ALL=C

##########################################
# Input / Output Directories
##########################################

INDIR="/gpfs1/data/climos/FEPO/ProcessedData/Meteorology/Norm"
OUTDIR="/gpfs1/data/climos/FEPO/ProcessedData/Meteorology/Norm/2"
mkdir -p "$OUTDIR"

echo "----------------------------------------"
echo "SLURM ARRAY TASK ID: $SLURM_ARRAY_TASK_ID"
echo "Input directory     : $INDIR"
echo "Output directory    : $OUTDIR"
echo "----------------------------------------"

##########################################
# Choose file + old variable based on task ID
##########################################

case "$SLURM_ARRAY_TASK_ID" in
    1) netcdf="${INDIR}/tmin.nc"; var_old="tmin_normalized"; var_new="tmin" ;;
    2) netcdf="${INDIR}/tmax.nc"; var_old="tmax_normalized"; var_new="tmax" ;;
    3) netcdf="${INDIR}/tavg.nc"; var_old="tavg_normalized"; var_new="tavg" ;;
    4) netcdf="${INDIR}/pre.nc";  var_old="pre_normalized"; var_new="pre" ;;
    ##5) netcdf="${INDIR}/pet.nc";  var_old="pet_normalized"; var_new="pet" ;;
    *) echo "Invalid SLURM_ARRAY_TASK_ID: $SLURM_ARRAY_TASK_ID"; exit 1 ;;
esac

outfile="${OUTDIR}/$(basename "$netcdf")"

echo "Processing file     : $netcdf"
echo "Renaming variable   : $var_old → $var_new"
echo "Output file         : $outfile"
echo "----------------------------------------"

##########################################
# Run CDO rename with compression
##########################################

cdo -f nc4c -z zip_4 chvar,"${var_old}","${var_new}" "$netcdf" "$outfile"

echo "Finished: $outfile"
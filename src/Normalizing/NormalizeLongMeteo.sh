#!/bin/bash
#SBATCH –-job-name=normalize_long_meteo
#SBATCH –-array=1-3
#SBATCH –-output=normalize_swc_%A_%a.out
#SBATCH –-error=normalize_swc_%A_%a.err
#SBATCH –-time=0-10:00:00
#SBATCH –-mem-per-cpu=50G

###############################################################
# Normalization Information
###############################################################
module load foss/2022b CDO/2.2.2

NA_VALUE=-9999
###############################################
# Input and Output Directories
###############################################

INDIR="/gpfs1/data/climos/FEPO/ProcessedData/Meteorology/LongMonthly"
OUTDIR="/gpfs1/data/climos/FEPO/ProcessedData/Meteorology/LongMonthly/Norm"

mkdir -p "$OUTDIR"

echo "Input directory  : $INDIR"
echo "Output directory : $OUTDIR"

###############################################
# Select job based on SLURM array index
###############################################
case $SLURM_ARRAY_TASK_ID in
  1) VAR="pet"; MIN=0; MAX=8 ;;
  2) VAR="pre"; MIN=0; MAX=300 ;;
  3) VAR="tavg"; MIN=-10; MAX=30 ;;
  *) echo "Invalid SLURM_ARRAY_TASK_ID"; exit 1 ;;
esac

INFILE="${INDIR}/${VAR}.nc"
OUTFILE="${OUTDIR}/${VAR}.nc"

cdo -z zip_4 expr,"${VAR}=${VAR}==${NA_VALUE}?${VAR}:(${VAR}>${MAX}?1:(${VAR}<${MIN}?0:(${VAR}-${MIN})/(${MAX}-${MIN})))" "$INFILE" "$OUTFILE"

echo "Normalization completed for task $SLURM_ARRAY_TASK_ID ($VAR)"
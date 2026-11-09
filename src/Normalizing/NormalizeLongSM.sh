#!/bin/bash
#SBATCH --job-name=normalize_long_swc
#SBATCH --array=1-6
#SBATCH --output=normalize_swc_%A_%a.out
#SBATCH --error=normalize_swc_%A_%a.err
#SBATCH --time=0-10:00:00
#SBATCH --mem-per-cpu=50G

###############################################################
# Normalization Information
###############################################################
module load foss/2022b CDO/2.2.2

NA_VALUE=-9999
###############################################
# Input and Output Directories
###############################################

INDIR="/gpfs1/data/climos/FEPO/ProcessedData/Hydrology/LongMonthly"
OUTDIR="/gpfs1/data/climos/FEPO/ProcessedData/Hydrology/LongMonthly/Norm"

mkdir -p "$OUTDIR"

echo "Input directory  : $INDIR"
echo "Output directory : $OUTDIR"

###############################################
# Select job based on SLURM array index
###############################################
case $SLURM_ARRAY_TASK_ID in
  1) VAR="SWC_L01"; MIN=5; MAX=30 ;;
  2) VAR="SWC_L02"; MIN=10; MAX=60 ;;
  3) VAR="SWC_L03"; MIN=20; MAX=90 ;;
  4) VAR="SWC_L04"; MIN=20; MAX=120 ;;
  5) VAR="SWC_L05"; MIN=60; MAX=260 ;;
  6) VAR="SWC_L06"; MIN=150; MAX=550 ;;
  *) echo "Invalid SLURM_ARRAY_TASK_ID"; exit 1 ;;
esac

INFILE="${INDIR}/${VAR}.nc"
OUTFILE="${OUTDIR}/${VAR}.nc"

cdo -z zip_4 expr,"${VAR}=${VAR}==${NA_VALUE}?${VAR}:(${VAR}>${MAX}?1:(${VAR}<${MIN}?0:(${VAR}-${MIN})/(${MAX}-${MIN})))" "$INFILE" "$OUTFILE"

echo "Normalization completed for task $SLURM_ARRAY_TASK_ID ($VAR)"
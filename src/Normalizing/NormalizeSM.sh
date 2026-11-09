#!/bin/bash
#SBATCH --job-name=normalize_swc
#SBATCH --array=1-6
#SBATCH --output=normalize_swc_%A_%a.out
#SBATCH --error=normalize_swc_%A_%a.err
#SBATCH --time=0-10:00:00
#SBATCH --mem-per-cpu=50G

###############################################################
# Soil Moisture (SWC) Min–Max Normalization
#
# Missing values (NA = -9999) remain unchanged.
# Values outside range are clipped to [0,1].
#
# SWC normalization ranges:
#   SWC_L01: 0–40
#   SWC_L02: 0–70
#   SWC_L03: 0–100
#   SWC_L04: 0–110
#   SWC_L05: 0–300
#   SWC_L06: 0–600
#
# Output goes to:
#   Normalized_SWC_YYYYMMDD/
###############################################################

module load foss/2022b CDO/2.2.2

NA_VALUE=-9999

TODAY=$(date +"%Y%m%d")
OUTDIR="Normalized_SWC_${TODAY}"
mkdir -p "$OUTDIR"

echo "Saving normalized files to: $OUTDIR"

###############################################################################
case $SLURM_ARRAY_TASK_ID in

  1)
    INFILE="SWC_L01.nc"
    OUTFILE="${OUTDIR}/SWC_L01.nc"
    cdo -z zip_4 expr,"SWC_L01=SWC_L01==$NA_VALUE?SWC_L01:(SWC_L01>40?1:(SWC_L01<0?0:(SWC_L01-0)/(40-0)))" \
        "$INFILE" "$OUTFILE"
    ;;

  2)
    INFILE="SWC_L02.nc"
    OUTFILE="${OUTDIR}/SWC_L02.nc"
    cdo -z zip_4 expr,"SWC_L02=SWC_L02==$NA_VALUE?SWC_L02:(SWC_L02>70?1:(SWC_L02<0?0:(SWC_L02-0)/(70-0)))" \
        "$INFILE" "$OUTFILE"
    ;;

  3)
    INFILE="SWC_L03.nc"
    OUTFILE="${OUTDIR}/SWC_L03.nc"
    cdo -z zip_4 expr,"SWC_L03=SWC_L03==$NA_VALUE?SWC_L03:(SWC_L03>100?1:(SWC_L03<0?0:(SWC_L03-0)/(100-0)))" \
        "$INFILE" "$OUTFILE"
    ;;

  4)
    INFILE="SWC_L04.nc"
    OUTFILE="${OUTDIR}/SWC_L04.nc"
    cdo -z zip_4 expr,"SWC_L04=SWC_L04==$NA_VALUE?SWC_L04:(SWC_L04>110?1:(SWC_L04<0?0:(SWC_L04-0)/(110-0)))" \
        "$INFILE" "$OUTFILE"
    ;;

  5)
    INFILE="SWC_L05.nc"
    OUTFILE="${OUTDIR}/SWC_L05.nc"
    cdo -z zip_4 expr,"SWC_L05=SWC_L05==$NA_VALUE?SWC_L05:(SWC_L05>300?1:(SWC_L05<0?0:(SWC_L05-0)/(300-0)))" \
        "$INFILE" "$OUTFILE"
    ;;

  6)
    INFILE="SWC_L06.nc"
    OUTFILE="${OUTDIR}/SWC_L06.nc"
    cdo -z zip_4 expr,"SWC_L06=SWC_L06==$NA_VALUE?SWC_L06:(SWC_L06>600?1:(SWC_L06<0?0:(SWC_L06-0)/(600-0)))" \
        "$INFILE" "$OUTFILE"
    ;;

esac
###############################################################################

echo "Task $SLURM_ARRAY_TASK_ID completed."
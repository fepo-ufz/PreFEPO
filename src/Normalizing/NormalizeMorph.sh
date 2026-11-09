#!/bin/bash
#SBATCH --job-name=normalize_morphology
#SBATCH --array=1-5
#SBATCH --output=normalize_morph_%A_%a.out
#SBATCH --error=normalize_morph_%A_%a.err
#SBATCH --time=0-05:00:00
#SBATCH --mem-per-cpu=30G

module load foss/2022b CDO/2.2.2

NA_VALUE=-9999

###############################################
# Input and Output Directories
###############################################

INDIR="/gpfs1/data/climos/FEPO/RawData/Morphology/"
TODAY=$(date +"%Y%m%d")
OUTDIR="${INDIR}/Normalized_Morph_${TODAY}"

mkdir -p "$OUTDIR"
echo "Input directory  : $INDIR"
echo "Output directory : $OUTDIR"
###############################################


###############################################
# Select job based on SLURM array index
###############################################
case $SLURM_ARRAY_TASK_ID in

  1)
    # aspect.nc (0–360)
    INFILE="${INDIR}/aspect.nc"
    TEMP="${OUTDIR}/aspect_temp.nc"
    OUTFILE="${OUTDIR}/aspect.nc"

    echo "INFILE = $INFILE"

    cdo expr,"aspect=Band1==$NA_VALUE?Band1:(Band1>360?1:(Band1<0?0:(Band1/360)))" \
        "$INFILE" "$TEMP"

    cdo -f nc4c -z zip_4 copy "$TEMP" "$OUTFILE"
    rm "$TEMP"
    ;;

  2)
    # dem.nc (-450–3000)
    INFILE="${INDIR}/dem.nc"
    TEMP="${OUTDIR}/elevation_temp.nc"
    OUTFILE="${OUTDIR}/elevation.nc"

    echo "INFILE = $INFILE"

    cdo expr,"elevation=Band1==$NA_VALUE?Band1:(Band1>3000?1:(Band1<-450?0:(Band1+450)/3450))" \
        "$INFILE" "$TEMP"

    cdo -f nc4c -z zip_4 copy "$TEMP" "$OUTFILE"
    rm "$TEMP"
    ;;

  3)
    # slope.nc (0–70)
    INFILE="${INDIR}/slope.nc"
    TEMP="${OUTDIR}/slope_temp.nc"
    OUTFILE="${OUTDIR}/slope.nc"

    echo "INFILE = $INFILE"

    cdo expr,"slope=Band1==$NA_VALUE?Band1:(Band1>70?1:(Band1<0?0:(Band1/70)))" \
        "$INFILE" "$TEMP"

    cdo -f nc4c -z zip_4 copy "$TEMP" "$OUTFILE"
    rm "$TEMP"
    ;;

  4)
    # sand.nc (% → 0–1)
    INFILE="${INDIR}/sand.nc"
    TEMP="${OUTDIR}/sand_temp.nc"
    OUTFILE="${OUTDIR}/sand.nc"

    echo "INFILE = $INFILE"

    cdo expr,"sand=sand==$NA_VALUE?sand:(sand*0.01)" \
        "$INFILE" "$TEMP"

    cdo -f nc4c -z zip_4 copy "$TEMP" "$OUTFILE"
    rm "$TEMP"
    ;;

  5)
    # clay.nc (% → 0–1)
    INFILE="${INDIR}/clay.nc"
    TEMP="${OUTDIR}/clay_temp.nc"
    OUTFILE="${OUTDIR}/clay.nc"

    echo "INFILE = $INFILE"

    cdo expr,"clay=clay==$NA_VALUE?clay:(clay*0.01)" \
        "$INFILE" "$TEMP"

    cdo -f nc4c -z zip_4 copy "$TEMP" "$OUTFILE"
    rm "$TEMP"
    ;;

esac

echo "Normalization completed for task $SLURM_ARRAY_TASK_ID"
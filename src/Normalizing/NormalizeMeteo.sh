#!/bin/bash
#SBATCH --job-name=normalize_meteo
#SBATCH --array=1-7
#SBATCH --output=normalize_nc_files_%A_%a.out
#SBATCH --error=normalize_nc_files_%A_%a.err
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

INDIR="/gpfs1/data/climos/FEPO/RawData/Meteorology"
OUTDIR="/gpfs1/data/climos/FEPO/ProcessedData/Meteorology/Norm"

mkdir -p "$OUTDIR"

echo "Input directory  : $INDIR"
echo "Output directory : $OUTDIR"
###############################################


###############################################
# Select job based on SLURM array index
###############################################
case $SLURM_ARRAY_TASK_ID in

  1)
    INFILE="${INDIR}/tmin.nc"
    OUTFILE="${OUTDIR}/tmin.nc"
    cdo -z zip_4 expr,"tmin=tmin==$NA_VALUE?tmin:(tmin>50?1:(tmin<-40?0:(tmin-(-40))/(50-(-40))))" \
        "$INFILE" "$OUTFILE"
    ;;

  2)
    INFILE="${INDIR}/tmax.nc"
    OUTFILE="${OUTDIR}/tmax.nc"
    cdo -z zip_4 expr,"tmax=tmax==$NA_VALUE?tmax:(tmax>50?1:(tmax<-40?0:(tmax-(-40))/(50-(-40))))" \
        "$INFILE" "$OUTFILE"
    ;;

  3)
    INFILE="${INDIR}/tavg.nc"
    OUTFILE="${OUTDIR}/tavg.nc"
    cdo -z zip_4 expr,"tavg=tavg==$NA_VALUE?tavg:(tavg>50?1:(tavg<-40?0:(tavg-(-40))/(50-(-40))))" \
        "$INFILE" "$OUTFILE"
    ;;

  4)
    INFILE="${INDIR}/pre.nc"
    OUTFILE="${OUTDIR}/pre.nc"
    cdo -z zip_4 expr,"pre=pre==$NA_VALUE?pre:(pre>200?1:(pre<0?0:(pre-0)/(200-0)))" \
        "$INFILE" "$OUTFILE"
    ;;

  5)
    INFILE="${INDIR}/pet.nc"
    OUTFILE="${OUTDIR}/pet.nc"
    cdo -z zip_4 expr,"pet=pet==$NA_VALUE?pet:(pet>10?1:(pet<0?0:(pet-0)/(10-0)))" \
        "$INFILE" "$OUTFILE"
    ;;
  6)
    INFILE="${INDIR}/tmin_era.nc"
    OUTFILE="${OUTDIR}/tmin_era.nc"
    cdo -z zip_4 expr,"tmin=tmin==$NA_VALUE?tmin:(tmin>50?1:(tmin<-40?0:(tmin-(-40))/(50-(-40))))" \
        "$INFILE" "$OUTFILE"
    ;;
  7)
    INFILE="${INDIR}/tmax_era.nc"
    OUTFILE="${OUTDIR}/tmax_era.nc"
    cdo -z zip_4 expr,"tmax=tmax==$NA_VALUE?tmax:(tmax>50?1:(tmax<-40?0:(tmax-(-40))/(50-(-40))))" \
        "$INFILE" "$OUTFILE"
    ;;
  *)
    echo "Invalid SLURM_ARRAY_TASK_ID: $SLURM_ARRAY_TASK_ID"
    exit 1

esac

echo "Normalization completed for task $SLURM_ARRAY_TASK_ID"
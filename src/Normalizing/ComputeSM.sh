#!/bin/bash
#SBATCH --job-name=compute_swc_cum_all
#SBATCH --array=1-5
#SBATCH --output=compute_swc_cum_all_%A_%a.out
#SBATCH --error=compute_swc_cum_all_%A_%a.err
#SBATCH --time=0-23:00:00
#SBATCH --mem-per-cpu=50G

###############################################################
# Compute Cumulative Soil Water Content (SWC) for Each Layer
# This script computes the cumulative soil water content (SWC)
# for soil layers L02 to L06 using weighted averages of the
# current and all preceding layers. Each SLURM array task
# processes one soil layer.
# Input File:
#   - mHM_Fluxes_States.nc
# Output Files:
#   - SWC_L02.nc, SWC_L03.nc, SWC_L04.nc, SWC_L05.nc, SWC_L06.nc
#   - Corresponding min/max text files for each layer
###############################################################

module load foss/2022b CDO/2.2.2

# Absolute paths for input and output
CDO_INPUT="/gpfs1/data/climos/mhm_output/emo_v1/mHM_Fluxes_States.nc"
OUTDIR="/gpfs1/data/climos/mhm_output/transfer_MinIO/Hydrology/V3/Standard"

# Ensure the output directory exists
mkdir -p "$OUTDIR"

# Map each array task ID (1..5) to a specific soil layer (02..06)
case $SLURM_ARRAY_TASK_ID in
  1) LAYER="02"; FORMULA='SWC_L02=(10*SWC_L02 + 5*SWC_L01)/15' ;;
  2) LAYER="03"; FORMULA='SWC_L03=(15*SWC_L03 + 10*SWC_L02 + 5*SWC_L01)/30' ;;
  3) LAYER="04"; FORMULA='SWC_L04=(30*SWC_L04 + 15*SWC_L03 + 10*SWC_L02 + 5*SWC_L01)/60' ;;
  4) LAYER="05"; FORMULA='SWC_L05=(40*SWC_L05 + 30*SWC_L04 + 15*SWC_L03 + 10*SWC_L02 + 5*SWC_L01)/100' ;;
  5) LAYER="06"; FORMULA='SWC_L06=(100*SWC_L06 + 40*SWC_L05 + 30*SWC_L04 + 15*SWC_L03 + 10*SWC_L02 + 5*SWC_L01)/200' ;;
esac

# Define file name
FILE="${OUTDIR}/SWC_L${LAYER}.nc"
TMPFILE="${FILE%.nc}_compressed.nc"
OUTTXT="${FILE%.nc}_minmax.txt"

# Compute the cumulative SWC with the final variable name
cdo expr,"$FORMULA" "$CDO_INPUT" "$FILE"

# Compress the file
cdo -f nc4 -z zip_4 copy "$FILE" "$TMPFILE"
rm "$FILE"
mv "$TMPFILE" "$FILE"

# Extract min and max values
global_min=$(cdo -s output -fldmin -timmin -selname,"SWC_L${LAYER}" "$FILE")
global_max=$(cdo -s output -fldmax -timmax -selname,"SWC_L${LAYER}" "$FILE")

# Save min/max values to a text file
{
  echo "File       : $FILE"
  echo "Variable   : SWC_L${LAYER}"
  echo "Global Min : $global_min"
  echo "Global Max : $global_max"
} > "$OUTTXT"

# Log completion
echo "Task $SLURM_ARRAY_TASK_ID completed: Variable is SWC_L${LAYER} in $FILE."
echo "Min/max values saved in $OUTTXT."

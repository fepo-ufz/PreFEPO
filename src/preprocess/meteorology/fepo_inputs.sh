#!/bin/bash
#SBATCH --job-name=extract_years_embedded    # Job name
#SBATCH --output=logs/%A_%a.out              # Standard output and error log
#SBATCH --error=logs/%A_%a.err
#SBATCH --array=0-12                         # Adjust array range
#SBATCH -t 0-23:00:00
#SBATCH --mem-per-cpu=30G

module purge
module load Conda/24.3.0
source activate envRegular
module load foss/2022b CDO/2.2.2

# Define an array of NetCDF file paths
files=(
    "/gpfs1/data/climos/mhm_output/transfer_MinIO/Meteo/pet.nc"
    "/gpfs1/data/climos/mhm_output/transfer_MinIO/Meteo/pre.nc"
    "/gpfs1/data/climos/mhm_output/transfer_MinIO/Meteo/tavg.nc"
    "/gpfs1/data/climos/mhm_output/transfer_MinIO/Meteo/tmax.nc"
    "/gpfs1/data/climos/mhm_output/transfer_MinIO/Meteo/tmin.nc"
    "/gpfs1/data/climos/mhm_output/transfer_MinIO/Hydrology/V3/Standard/SWC_L01.nc"
    "/gpfs1/data/climos/mhm_output/transfer_MinIO/Hydrology/V3/Standard/SWC_L02.nc"
    "/gpfs1/data/climos/mhm_output/transfer_MinIO/Hydrology/V3/Standard/SWC_L03.nc"
    "/gpfs1/data/climos/mhm_output/transfer_MinIO/Hydrology/V3/Standard/SWC_L04.nc"
    "/gpfs1/data/climos/mhm_output/transfer_MinIO/Hydrology/V3/Standard/SWC_L05.nc"
    "/gpfs1/data/climos/mhm_output/transfer_MinIO/Hydrology/V3/Standard/SWC_L06.nc"
)

#output="/gpfs1/data/climos/mhm_output/fepo_inputs/"


# Determine the number of files defined in the array
NUM_FILES=${#files[@]}

# Validate that the SLURM_ARRAY_TASK_ID is within the range of our files array
if [ "$SLURM_ARRAY_TASK_ID" -ge "$NUM_FILES" ]; then
    echo "SLURM_ARRAY_TASK_ID ($SLURM_ARRAY_TASK_ID) exceeds the number of files ($NUM_FILES). Exiting."
    exit 1
fi

# Retrieve the input file based on the array index
INPUT_FILE="${files[$SLURM_ARRAY_TASK_ID]}"


# Construct output filename: append _2021_2022 before the .nc extension
BASENAME=$(basename "$INPUT_FILE" .nc)
OUTPUT_FILE="${BASENAME}_2021_2022.nc"

echo "Processing $INPUT_FILE -> $OUTPUT_FILE"

# Use CDO to select years 2021 to 2022 and compress the output
cdo -z zip selyear,2021/2022 "$INPUT_FILE" "$OUTPUT_FILE"

echo "Finished processing $INPUT_FILE"
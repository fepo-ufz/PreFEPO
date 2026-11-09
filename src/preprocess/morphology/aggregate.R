library(lubridate)
library(dplyr)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")

# 01 - run transforming scripts ==================================================
print(paste0("Extracting Morphological Features"))
print(paste0("Usually it takes almost 5 minutes to complete."))
print(paste0("--------------------------------------------------"))
print(paste0("Running the bash script..."))

cmd <- paste(
  "sbatch --wait",
  "src/FeExtracting/ExMorphology.sh",
  get_morphology_data_dir(),
  get_coordinate_path()
)
status <- system(cmd)
if (status != 0) stop("Bash script failed!")
print(paste0("Morphological Features Extraction Completed!"))
print(paste0("--------------------------------------------------"))
# 02 uniforming the data =========================================================
elevation <- read_morphology_data(name = "elevation", type = "processed")
aspect <- read_morphology_data(name = "aspect", type = "processed")
lc <- read_morphology_data(name = "lc", type = "processed")
slope <- read_morphology_data(name = "slope", type = "processed")
sand <- read_morphology_data(name = "sand", type = "processed")
clay <- read_morphology_data(name = "clay", type = "processed")
morph <- elevation %>%
    left_join(aspect, by = c("lat", "lon")) %>%
    left_join(lc, by = c("lat", "lon")) %>%
    left_join(slope, by = c("lat", "lon")) %>%
    left_join(sand, by = c("lat", "lon") ) %>%
    left_join(clay, by = c("lat", "lon") ) %>%
    dplyr::select(c("lat", "lon", "elevation", "aspect", "lc","slope","clay", "sand"))

# 03 write the data ==============================================================
print(paste0("--------------------------------------------------"))
write_morphology_data(morph, name = "morphology")
print(paste0("Morphological Features Aggregation Completed!"))
print(paste0("**************************************************"))


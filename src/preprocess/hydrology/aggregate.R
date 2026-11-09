library(lubridate)
library(dplyr)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
# 01 - Extracting the Meteorology Features ==================================================
print(paste0("Extracting Hydrological Features"))
print(paste0("Usually it takes almost 30 minutes to complete."))
print(paste0("--------------------------------------------------"))
print(paste0("Running the bash script..."))
cmd <- paste(
  "sbatch --wait",
  "src/FeExtracting/ExHydrology.sh",
  get_hydrology_data_dir(),
  get_coordinate_dates_path()
)
status <- system(cmd)
if (status != 0) stop("Bash script failed!")
print(paste0("Hydrological Features Extraction Completed!"))
print(paste0("--------------------------------------------------"))
# 02 - Extarcrting Long term Meteorology Features ==================================================
print(paste0("Extracting Long term Hydrological Features"))
print(paste0("Usually it takes almost 30 minutes to complete."))
print(paste0("--------------------------------------------------"))
print(paste0("Running the bash script..."))
cmd <- paste(
  "sbatch --wait",
  "src/FeExtracting/ExLongHydrology.sh",
  get_hydrology_data_dir(),
  get_coordinate_dates_path()
)
status <- system(cmd)
if (status != 0) stop("Bash script failed!")
print(paste0("Hydrological Long term Features Extraction Completed!"))
print(paste0("--------------------------------------------------"))
# 03 - Combining the Meteorology Features ==================================================
swc1 <- read_hydrology_data(name = "swc1", type = "processed")
swc2 <- read_hydrology_data(name = "swc2", type = "processed")
swc3 <- read_hydrology_data(name = "swc3", type = "processed")
swc4 <- read_hydrology_data(name = "swc4", type = "processed")
swc5 <- read_hydrology_data(name = "swc5", type = "processed")
swc6 <- read_hydrology_data(name = "swc6", type = "processed")
LM_swc1 <- read_hydrology_data(name = "LM_swc1", type = "processed")
LM_swc2 <- read_hydrology_data(name = "LM_swc2", type = "processed")
LM_swc3 <- read_hydrology_data(name = "LM_swc3", type = "processed")
LM_swc4 <- read_hydrology_data(name = "LM_swc4", type = "processed")
LM_swc5 <- read_hydrology_data(name = "LM_swc5", type = "processed")
LM_swc6 <- read_hydrology_data(name = "LM_swc6", type = "processed")
hydro <- swc1 %>%
  left_join(swc2, by = c("sdate", "lat", "lon")) %>%
  left_join(swc3, by = c("sdate", "lat", "lon")) %>%
  left_join(swc4, by = c("sdate", "lat", "lon")) %>%
  left_join(swc5, by = c("sdate", "lat", "lon")) %>%
  left_join(swc6, by = c("sdate", "lat", "lon")) %>%
  left_join(LM_swc1, by = c("sdate", "lat", "lon")) %>%
  left_join(LM_swc2, by = c("sdate", "lat", "lon")) %>%
  left_join(LM_swc3, by = c("sdate", "lat", "lon")) %>%
  left_join(LM_swc4, by = c("sdate", "lat", "lon")) %>%
  left_join(LM_swc5, by = c("sdate", "lat", "lon")) %>%
  left_join(LM_swc6, by = c("sdate", "lat", "lon")) %>%
  dplyr::select(
    sdate, lat, lon,
    dplyr::starts_with("swc1"),
    dplyr::starts_with("swc2"),
    dplyr::starts_with("swc3"),
    dplyr::starts_with("swc4"),
    dplyr::starts_with("swc5"),
    dplyr::starts_with("swc6"),
    dplyr::starts_with("LM_")
  )
# 04 - write the data ==============================================================
print(paste0("--------------------------------------------------"))
write_hydrology_data(hydro, name = "hydrology")
print(paste0("Hydrology Features Aggregation Completed!"))
print(paste0("**************************************************"))
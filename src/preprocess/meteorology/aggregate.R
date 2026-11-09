library(lubridate)
library(dplyr)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
# 01 - Extracting the Meteorology Features ==================================================
print(paste0("Extracting Meteorological Features"))
print(paste0("Usually it takes almost 15 minutes to complete."))
print(paste0("--------------------------------------------------"))
print(paste0("Running the bash script..."))
cmd <- paste(
  "sbatch --wait",
  "src/FeExtracting/ExMeteorology.sh",
  get_meteorology_data_dir(),
  get_coordinate_dates_path()
)
status <- system(cmd)
if (status != 0) stop("Bash script failed!")
print(paste0("Meteorological Features Extraction Completed!"))
print(paste0("--------------------------------------------------"))
# 02 - Extarcrting Long term Meteorology Features ==================================================
print(paste0("Extracting Long term Meteorological Features"))
print(paste0("Usually it takes almost 10 minutes to complete."))
print(paste0("--------------------------------------------------"))
print(paste0("Running the bash script..."))
cmd <- paste(
  "sbatch --wait",
  "src/FeExtracting/ExLongMeteorology.sh",
  get_meteorology_data_dir(),
  get_coordinate_dates_path()
)
status <- system(cmd)
if (status != 0) stop("Bash script failed!")
print(paste0("Meteorological Long term Features Extraction Completed!"))
print(paste0("--------------------------------------------------"))
# 03 Fix Nan values in tmin and tmax using ERA5 data ============================================
lags <- c(1, 7, 14, 21, 28, 35, 42, 49, 56, 63, 70, 90, 120, 150, 180, 210, 240, 270, 300, 330, 365)
fill_from_era <- function(tbl_main, tbl_era , prefix, lags) {
  for (lag in lags) {
    main_col <- paste0(prefix, "_", lag)
    era_col  <- paste0(prefix, "_era_", lag)
    na_idx   <- is.na(tbl_main[[main_col]])
    tbl_main[[main_col]][na_idx] <- tbl_era[[era_col]][na_idx]
  }
  tbl_main
}

# 05 - Aggregate all meteorology features ==================================================
tmax <- read_meteorology_data(name = "tmax", type = "processed")
tmin <- read_meteorology_data(name = "tmin", type = "processed")
tmax_era <- read_meteorology_data(name = "tmax_era", type = "processed")
tmin_era <- read_meteorology_data(name = "tmin_era", type = "processed")
pet <- read_meteorology_data(name = "pet", type = "processed")
pre <- read_meteorology_data(name = "pre", type = "processed")
tavg <- read_meteorology_data(name = "tavg", type = "processed")
LM_pet <- read_meteorology_data(name = "LM_pet", type = "processed")
LM_pre <- read_meteorology_data(name = "LM_pre", type = "processed")
LM_tavg <- read_meteorology_data(name = "LM_tavg", type = "processed")
tmin <- fill_from_era(tmin, tmin_era, "tmin", lags)
tmax <- fill_from_era(tmax, tmax_era, "tmax", lags)

meteo <- pet %>%
  left_join(pre, by = c("sdate", "lat", "lon")) %>%
  left_join(tavg, by = c("sdate", "lat", "lon")) %>%
  left_join(tmax, by = c("sdate", "lat", "lon")) %>%
  left_join(tmin, by = c("sdate", "lat", "lon")) %>%
  left_join(LM_pet, by = c("sdate", "lat", "lon")) %>%
  left_join(LM_pre, by = c("sdate", "lat", "lon")) %>%
  left_join(LM_tavg, by = c("sdate", "lat", "lon")) %>%
  dplyr::select(
    sdate, lat, lon,
    dplyr::starts_with("pet"),
    dplyr::starts_with("pre"),
    dplyr::starts_with("tavg"),
    dplyr::starts_with("tmax"),
    dplyr::starts_with("tmin"),
    dplyr::starts_with("LM_")
  )
# 04 - write the data ==============================================================
print(paste0("--------------------------------------------------"))
write_meteorology_data(meteo, name = "meteo")
print(paste0("Meteorology Features Aggregation Completed!"))
print(paste0("**************************************************"))
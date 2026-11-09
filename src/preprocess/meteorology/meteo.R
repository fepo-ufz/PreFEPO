# We extract meteorology data from EMO-1 dataset for coordinates of the sandflies.
# In some case we have Nan values for tmin and tmix, thus we need to fill them with the nearest values.
# We use the ERA5 dataset to fill the missing values.
# In this file we prepare the ERA5 extracted data for the filling process.
# 01 - import libraries =============================================================
library(lubridate)
library(dplyr)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")
# 02 read the data =========================================================

meteo <- read_meteorology_data(name = "meteo", type = "raw")

# How many rows include Nan values for tmin and tmax
nan_n1 <- nrow(meteo %>% dplyr::filter(is.na(tmin_1) | is.na(tmax_1)))


lags <- c(1, 7, 14, 21, 28, 35, 42, 49, 56, 63, 70, 90, 120, 150, 180, 210, 240, 270, 300, 330, 365)
for (lag in lags) {
  tmin <- paste0("tmin_", lag)
  tmax <- paste0("tmax_", lag)
  tmin_era5 <- paste0("tmin_era5_", lag)
  tmax_era5 <- paste0("tmax_era5_", lag)
  idx <- is.na(meteo[tmin])
  idx <- which(is.na(meteo[tmin]))
  meteo[[tmin]][idx] <- meteo[[tmin_era5]][idx]
  idx <- is.na(meteo[tmax])
  meteo[[tmax]][idx] <- meteo[[tmax_era5]][idx]
}

#remove irrelevant columns
cname <- colnames(meteo)
cname <- setdiff(cname, grep("^X", cname, value = TRUE))
cname <- cname[!grepl("era5", cname)]
meteo <- meteo[, cname]

# count how many records include Nan value yet
nan_n2 <- nrow(meteo %>% dplyr::filter(is.na(tmin_1) | is.na(tmax_1)))
paste("Number of records with Nan values before and after filling: ", nan_n1, "/", nan_n2)

write_meteorology_data(meteo, name = "meteo")

#meteo_emo1 <- read_meteorology_data(name = "meteo_emo1", type = "raw")
#meteo_era5 <- read_meteorology_data(name = "meteo_era5", type = "raw")

# remove irrelevant columns of meteo_era5
#irrelevant_columns <- c("swc1", "swc2", "swc3","swc3","swc5","swc6", "pet", "pre", "tavg", "tmax", "tmin", "X")
#meteo_era5 <- meteo_era5 %>% dplyr::select(-one_of(irrelevant_columns))

# if tmin in meteo_emo1 is NA, we should fill it with meteo_era5
# if tmax in meteo_emo1 is NA, we should fill it with meteo_era5

# join meteo_emo1 and meteo_era5 based on sdate, lat, lon such that all rows of meteo_emo1 are included
#meteo <- merge(meteo_emo1, meteo_era5, by = c("sdate", "lat", "lon"), all.x = TRUE)

# if tmin_1 is NA, fill it with tmin_era5_1, and if tmax_1 is NA, fill it with tmax_era5_1
# it should be done for all lag values lags = [1, 7, 14, 21, 28, 35, 42, 49, 56, 63, 70, 90, 120, 150, 180, 210, 240, 270, 300, 330, 365]


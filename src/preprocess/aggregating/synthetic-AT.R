# In this file we want to provide the absence data
# https://www.maps.ie/coordinates.html
#======= 01 - import libraries ============================================================
library(lubridate)
library(dplyr)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")
# 02 - load data ====================================================================
# synthetic data for location and species
data <- read_sandflies_data(name = "aggregated_pa",type = "processed")
colnames <- colnames(data)
data$sdate <- as.Date(data$sdate)
data$edate <- as.Date(data$edate)
data$smonth <- as.integer(month(data$sdate))
data$syear <- as.integer(year(data$sdate))

inactive_month <- c(1,2,12)
#location month
loc_smonth <- data %>% dplyr::group_by(lon,lat,smonth) %>% summarise(n = n(), nst = sum(nst), original = TRUE)

#location month
loc_inactive <- data %>% dplyr::select(lon, lat) %>% distinct()
loc_inactive <- loc_inactive  %>% merge(data.frame(smonth = inactive_month))
loc_inactive$smonth <- as.integer(loc_inactive$smonth)


# loc_inactive - loc_smonth
synth_temporal <- loc_inactive %>% merge(loc_smonth, by = c("lon", "lat", "smonth"), all.x = TRUE)
synth_temporal <- synth_temporal %>% filter(is.na(original))

# extract the last year of location/species which does not have zero value on inactive monthes.
sub_data <- data %>% merge(synth_temporal, by = c("lon", "lat"), all.x = TRUE)
sub_data <- sub_data %>% group_by(lon,lat) %>% summarise(year = max(syear))
synth_temporal <- synth_temporal %>% merge(sub_data, by = c("lon", "lat"), all.x = TRUE)


syn_spatial_lat <- c(
  52.4156, 52.4174, 52.7293, 52.5749,  52.8923, 53.0665, 53.0381, 53.6089,
  53.5489, 53.0973, 53.1658, 50.8267,  50.6314, 50.4861, 50.2221, 50.1659,
  50.0771, 50.5068, 53.3208, 53.9953,  53.9988, 53.9922, 53.9775, 53.9617,
  53.9859, 53.3903, 53.2617, 51.8126,  51.7200, 51.5665)

syn_spatial_lon <- c(
  13.3707, 13.2632, 11.4054, 10.0145,  7.7756,   7.0962,  6.2170, 7.9908,
  9.7159, -0.4377, -2.6893,  13.1099,  12.6504, 14.1761, 12.8895, 12.6706,
  12.3876, 15.6332, 13.8404, 15.0650,  15.1502, 14.8423, 14.8999, 14.7850,
  14.6798,  7.4397,  6.9333, 20.4655,  22.5286, 4.3169)

# Add set the random seed and generate synthetic data
set.seed(123)
# random latitudes
#Lat [51, 54], Lon [4, 30]
rnd_sp_lat <- round(runif(200, 51, 54), 4)
rnd_sp_lon <- round(runif(200, 4, 30), 4)

syn_spatial_lat <- c(syn_spatial_lat, rnd_sp_lat)
syn_spatial_lon <- c(syn_spatial_lon, rnd_sp_lon)


synthetic_month <- 1:12
synthetic_year <- 2020
synth_spatial <- data.frame(lon = rep(syn_spatial_lon, each = length(synthetic_month)),
                            lat = rep(syn_spatial_lat, each = length(synthetic_month)),
                            smonth = rep(synthetic_month, length(syn_spatial_lat)),
                            syear = rep(synthetic_year, length(synthetic_month)*length(syn_spatial_lat)),
                            sdate = as.Date(paste0(synthetic_year,"-",synthetic_month,"-15")),
                            edate = as.Date(paste0(synthetic_year,"-",synthetic_month,"-16")),
                            nst = 0,
                            ds = 'synthetic')

synth_spatial <- remove_coordinates_in_sea(synth_spatial)
synth_spatial <- remove_outof_domain(synth_spatial)
synth_spatial <- get_region_code(synth_spatial)

#================================================================================================
if (nrow(synth_temporal) > 0) {
  synth_temporal$sdate <- as.Date(paste0(synth_temporal$year, "-", synth_temporal$smonth, "-15"))
  synth_temporal$edate <- as.Date(paste0(synth_temporal$year, "-", synth_temporal$smonth, "-16"))
  synth_temporal$nst <- 0
  synth_temporal$ds <- 'synthetic'
  synth_temporal <- get_region_code(synth_temporal)

  synth_temporal <- synth_temporal[, colnames]
  synth_spatial <- synth_spatial[, colnames]
  data <- data[, colnames]
  ds_final <- rbind(data, synth_temporal, synth_spatial)
  ds_final <- ds_final %>% drop_na()
  write_sandflies_data(ds_final, name = "aggregated_pa")
}

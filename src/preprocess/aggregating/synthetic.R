# In this file we want to provide the absence data
#======= 01 - import libraries ============================================================
library(lubridate)
library(dplyr)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")
# 02 - load data ====================================================================
# synthetic data for ocation and species
data <- read_sandflies_data(name = "aggregated",type = "processed")
colnames <- colnames(data)
data$sdate <- as.Date(data$sdate)
data$edate <- as.Date(data$edate)
data$smonth <- as.integer(month(data$sdate))
data$syear <- as.integer(year(data$sdate))

inactive_month <- c(1,2,12)

#location species
loc_spec_smonth <- data %>% dplyr::group_by(lon,lat,spec,smonth) %>% summarise(n = n(), nst = sum(nst), original = TRUE)

#location month species
loc_spec_inactive <- data %>% dplyr::select(lon,lat,spec) %>% distinct()
loc_spec_inactive <- loc_spec_inactive  %>% merge(data.frame(smonth = inactive_month))
loc_spec_inactive$smonth <- as.integer(loc_spec_inactive$smonth)

# loc_spec_inactive - loc_spec_smonth
synth_temporal <- loc_spec_inactive %>% merge(loc_spec_smonth, by = c("lon", "lat", "spec", "smonth"), all.x = TRUE)
synth_temporal <- synth_temporal %>% filter(is.na(original))

# extract the last year of location/species which does not have zero value on inactive monthes.
sub_data <- data %>% merge(synth_temporal, by = c("lon", "lat", "spec"), all.x = TRUE)
sub_data <- sub_data %>% group_by(lon,lat,spec) %>% summarise(year = max(syear))
synth_temporal <- synth_temporal %>% merge(sub_data, by = c("lon", "lat", "spec"), all.x = TRUE)


# Spatial Synthetic
# We know in the north of Europe, the sandflies are not active whole year.
# We selected these cooordinates randomly, and check manually to be sure these coordinate are not in water on monuntain.
# Thus, in these coorinate for all species and all monthes, we will set the nst to zero.
syn_spatial_lat <- c(52.5, 53.1, 52.8, 53.61, 52.3383)
syn_spatial_lon <- c(12.3, 15.4, 18.2, 20.61, 25.6963)
syn_unique_species <- "others"
synthetic_month <- 1:12
synthetic_year <- 2020
synth_spatial <- data.frame(lon = rep(syn_spatial_lon, each = length(synthetic_month)),
                            lat = rep(syn_spatial_lat, each = length(synthetic_month)),
                            spec = rep(syn_unique_species, length(synthetic_month)*length(syn_spatial_lat)),
                            smonth = rep(synthetic_month, length(syn_spatial_lat)),
                            syear = rep(synthetic_year, length(synthetic_month)*length(syn_spatial_lat)),
                            sdate = as.Date(paste0(synthetic_year,"-",synthetic_month,"-15")),
                            edate = as.Date(paste0(synthetic_year,"-",synthetic_month,"-16")),
                            nt = 1,
                            nsm = 0,
                            nsf = 0,
                            nsu = 0,
                            nst = 0,
                            ds = 'synthetic')


#================================================================================================
# presence/absence data

# sub_sub <- ds_final %>% dplyr::group_by(lon,lat,sdate) %>% summarise(n = n(), min_nst = min(nst), max_nst = max(nst))
## if min_nst == 0 and max_nst == 0 then we will set the label to 0 else 1
# sub_sub$label <- ifelse(sub_sub$min_nst == 0 & sub_sub$max_nst == 0, 0, 1)
# sub_sub$label <- as.integer(sub_sub$label)
# table(sub_sub$label)

#sub_sub <- get_region_code(sub_sub)
#dd <- table(sub_sub$region_code, sub_sub$label)

#================================================================================================
if (nrow(synth_temporal) > 0) {
  synth_temporal$sdate <- as.Date(paste0(synth_temporal$year, "-", synth_temporal$smonth, "-15"))
  synth_temporal$edate <- as.Date(paste0(synth_temporal$year, "-", synth_temporal$smonth, "-16"))
  synth_temporal$nt <- 1
  synth_temporal$nsm <- 0
  synth_temporal$nsf <- 0
  synth_temporal$nsu <- 0
  synth_temporal$nst <- 0
  synth_temporal$ds <- 'synthetic'

  synth_temporal <- synth_temporal[, colnames]
  synth_spatial <- synth_spatial[, colnames]
  data <- data[, colnames]
  ds_final <- rbind(data, synth_temporal, synth_spatial)

  write_sandflies_data(ds_final, name = "aggregated")
}

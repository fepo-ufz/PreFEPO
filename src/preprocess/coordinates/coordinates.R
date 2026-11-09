# In this script, we will extract the coordinate and date information from the aggergated dataset.
# 01 - load data ------------------------------------------------------------------
library(lubridate)
library(dplyr)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")
# 02 - get coordinates and start and end date -------------------------------------

# define precision of the coordinates
precision <- 4

#data <- read_sandflies_data("aggregated", "processed")
data <- read_sandflies_data(name = "aggregated_pa",type = "processed")
cnames <- c("lon", "lat", "sdate", "edate")
coorddate <- data[, cnames]

coorddate <- coorddate %>% arrange(sdate, lat, lon)
coorddate$lat <- round(coorddate$lat, precision)
coorddate$lon <- round(coorddate$lon, precision)
coorddate <- coorddate[!duplicated(coorddate),]

coorddate <- expand_date(coorddate)
coorddate <- coorddate[, c("lat", "lon", "sdate")]
coorddate <- coorddate[!duplicated(coorddate),]

coordinates <- coorddate
coordinates <- coordinates[, c("lat", "lon")]
coordinates <- coordinates[!duplicated(coordinates),]

write_coordinates(coorddate, "coordinates_dates")
write_coordinates(coordinates, "coordinates")
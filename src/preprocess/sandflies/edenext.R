# 01 - import libraries =============================================================
library(lubridate)
library(dplyr)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")
# 01 Explanation of dataset =====================================================
# The records belong to tyrkish stations, are delived as Turkey dataset again thus we can remove
# all of them
##
# This data set has 67 unique coordinates.
# Altought 15 various species are collected, the 4 most common species are
# phlebotomus_papatasi, sergenotmyia_dentata, phlebotomus_tobbi, sergentomyia_minuta, phlebotomus_galilaeous, sergentomyia_sp
# Collecting methods are LT, SP



# 02 - global variables =========================================================
data <- read_sandflies_data(name ="edenext", type = "raw")
# 03 Summarizing of dataset =====================================================

#coordinates <- data %>% dplyr::select(latitude, longitude) %>% distinct()
#colnames(coordinates) <- c("lat", "lon")
#coordinates <- get_nuts_name(coordinates)
#
#species <- data %>% group_by(species) %>% summarise(n = n(), dst = sum(number_of_collected, na.rm = TRUE)) %>% arrange(desc(dst))
#
#clm <- data %>% group_by(collecting_methods) %>% summarise(n = n(), dst = sum(number_of_collected, na.rm = TRUE)) %>% arrange(desc(dst))
#
## count row with NA values
#print(paste("There are", sum(is.na(data$number_of_collected)), "NAs in number_of_collected"))
## join data with coordinates, and the region name to the data
#data <- data %>% left_join(coordinates, by = c("latitude" = "lat", "longitude" = "lon"))
## group NA values based on the region name
#na_values <- data %>% group_by(region_name) %>% summarise(n = sum(is.na(number_of_collected)))
#
#ita_data <- data %>% filter(stringr::str_detect(region_name, "IT, "))
## remove record include NA
## the itally record include NA, shows that species are not active in the region
## And also they want to show on the month 3 the sand flies are not active
#ita_data <- ita_data %>% filter(!is.na(number_of_collected))
#
#
#pt_data <- data %>% filter(stringr::str_detect(region_name, "PT, "))
#pt_data <- pt_data %>% filter(!is.na(number_of_collected))
#
#
#fr_data <- data %>% filter(stringr::str_detect(region_name, "FR, "))
#grp_key <- c("latitude", "longitude", "collecting_methods", "start_date", "end_date", "number_of_trap", "sex", "species") # required columns
#grp_count <- fr_data %>% group_by_at(grp_key) %>% summarise(n = n()) %>% filter(n > 1)
#fr_data <- fr_data %>% group_by_at(grp_key) %>% summarise(collecting_methods = first(collecting_methods), number_of_collected = max(number_of_collected)) %>% ungroup()
#fr_well <- well_form_dataset(fr_data)
#fr_summary <- annual_summarize(fr_well)
#
## Removing the Turkey records
#turkish_coordinates <- coordinates %>% filter(stringr::str_detect(region_name, "TR, "))
#data <- data %>% filter(!(latitude %in% turkish_coordinates$lat & longitude %in% turkish_coordinates$lon))
#
#
## 03 - Correction & Uniforming =========================================================
#
## 03-01 Appearntly, if the number_of_collected is Nan, it should be zero
#idx <- which(is.na(data$number_of_collected))
#if (length(idx) > 0) {
#  print(paste("There are", length(idx), "NAs in number_of_collected"))
#  data <- data[-idx,]
#}
#
### 03-02 Check coordinates are in the sea or not
#res <- check_coordinate_in_sea(get_unique_coordinates(data))
#
## 03-03 Check of the sex column, if it is not F or M, it should be Unknown
#idx <- which(data$sex != "F" & data$sex != "M")
#if ( length(idx) > 0){
#  print(paste0("There are", length(idx), "Unknown in sex column"))
#  data[idx,]$sex <- "Unknown"
#}
#
## 03-01 - Coordinates on Sea for tyurkish station -----------------------------------
## Appearntly the coordinates of
## Camili 5 - 37.342299° (lat) 35.614778° (long)
## Borgata Finocchio - 41.842778 (lat), 12.699167 (long).
#
## In the new version location code was removed, thus in the newversion we can use these lines
#
##find the index of the records with location code "Camili 5"
##longitude: 36.010000, latitude: 46.3424
#idx <- which(data$longitude == 36.010000 & data$latitude == 46.3424)
##idx <- which(tolower(data$location_code) == "camili5")
#data[idx,]$longitude <- 35.614778
#data[idx,]$latitude <- 37.342299
#
##find the index of the records with location code "Borgata Finocchio"
##longitude: 12.893800, latitude: 44.9646
#idx <- which(data$longitude == 12.893800 & data$latitude == 44.9646)
##idx <- which(tolower(data$location_code) == "borgata finocchio_2")
#data[idx,]$longitude <- 12.699167
#data[idx,]$latitude <- 41.842778
#
##
## 03-02 - Handling the coordinate with NA values ------------------------------------
## Appearntly, all records with NA values are related to turkish zone, and all of them has the zero values in
## number of sandflies (samples_collected).
##sub_data <- data %>% filter(is.na(lon) | is.na(lat)) %>% dplyr::select(lon, lat, location_code, samples_collected)
##
##
### This script illustrates the various number of sandflies
### table(sub_data$samples_collected) ==> (0, 82824)
##
### The name of location codes
##locations <- sub_data %>% dplyr::select(location_code) %>% unique() %>% mutate(lat= NA, lon = NA)
##
###find the lat and lon based on the other records
##for (i in seq_len(nrow(locations))){
##  code <- locations[i,1]
##  temp <- data %>% filter(tolower(location_code) == tolower(code))
##  temp <- temp %>% filter(!is.na(lon) & !is.na(lat))
##  temp <- temp %>% group_by(lon, lat) %>% summarise(n = n())
##  if (nrow(temp) > 0){
##    print(paste0("There are ", nrow(temp), " coordinates for a location code", code))
##    if (nrow(temp) > 1)
##      print(paste0("There are more than one coordinates for a location code", code))
##
##    locations[i,]$lon <- temp[1,]$lon
##    locations[i,]$lat <- temp[1,]$lat
##  }
##}
##
### insert the coordinates into the data
##for (i in seq_len(nrow(locations))){
##  code <- locations[i,1]
##  idx <- which(tolower(data$location_code) == tolower(code))
##  data[idx,]$lon <- locations[i,]$lon
##  data[idx,]$lat <- locations[i,]$lat
##}
### 03-03 - Handling the Otluk1_2 ----------------------------------------------------
### The coordinates of Otluk1_2 is not correct,
### Based on the Sergio's explanation, this location would belong to our Otluk1_1
##
##lat_lon_Otluk1 <- data %>% filter(tolower(location_code) == "otluk1") %>% dplyr::select(lon, lat) %>% unique()
##lat_lon_Otluk2 <- data %>% filter(tolower(location_code) == "otluk2") %>% dplyr::select(lon, lat) %>% unique()
##idx_Otluk1_2 <- which(data$location_code == "Otluk1_2")
##
##data[idx_Otluk1_2, c("lon", "lat")] <- lat_lon_Otluk1[1,]
##data[idx_Otluk1_2, c("location_code")] <- "Otluk1"
##
### 03-04 - Durtion of sampling is more than 25 days ----------------------------------
#### Appearntly, in the turkish station, the sampling was happened a day between 15-20 each month
#### but they forget the extact date, according the explanation, the duration of these records should be 2 day
#### so, we correct the sart and end date of sampling with duration more than 25 days
##
#sdate <- as.Date(data$start_date)
#edate <- as.Date(data$end_date)
#duration <- as.numeric(edate - sdate, units = "days")
#hist(duration)
#idx <- which(duration > 25)
#day(sdate[idx]) <- 15
#day(edate[idx]) <- 17
#
#data$start_date <- sdate
#data$end_date <- edate
##
### 03-05 - if start_date_of_sampling is biger than end_date_of_sampling, they should be swapped
#idx <- which(data$start_date > data$end_date)
#if (length(idx) > 0) {
#  print(paste("There are", length(idx), "start_date > end_date"))
#  sdate <- data[idx,]$start_date
#  edate <- data[idx,]$end_date
#  data[idx,]$start_date <- edate
#  data[idx,]$end_date <- sdate
#}
#
## The collecting methods should be one of these valid values: LT, SP, HC
## 02-04 Uniform the collection method, the original values are: "CDC", "CDC_CO2", "CO2" , for the sake of uniformity, we will change them to LT
## if collecting methos is empty string, it should be Nan
#idx <- which(data$collecting_methods == "")
#if (length(idx) > 0) {
#  print(paste("There are", length(idx), "empty strings in collecting_methods"))
#  data[idx,]$collecting_methods <- NA
#}
#unique(data$collecting_methods)
#
## 03-06 - Remove X_Id column ----------------------------------------------------------
#data <- data %>% dplyr::select(!c("X_id"))
#
# 04 - Save the data --------------------------------------------------------
data <- clean_dataset(data)
write_sandflies_data(data, "edenext")

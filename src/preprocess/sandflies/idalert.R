# 01 - import libraries =============================================================
library(lubridate)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")
# 02 - global variables =========================================================
data <- read_sandflies_data(name ="idalert", type = "raw")

## 02-01 - Remove other species -----------------------------------------------------------------------------------------
#data <- uniform_species_names(data)
#data <- data %>% filter(!(species %in% 'others'))
#
## 03 - Correction & Uniforming =========================================================
#
## 03-01 Appearntly, if the number_of_collected is Nan, it should be removed
#idx <- which(is.na(data$number_of_collected))
#if (length(idx) > 0) {
#  print(paste("There are", length(idx), "NAs in number_of_collected"))
#  data <- data[-idx,]
#}
#
## 03-02 Check coordinates are in the sea or not
#res <- check_coordinate_in_sea(get_unique_coordinates(data))
#
## 03-01 - species sex
## get index of records with species_sex NA
#idx <- which(is.na(data$species))
#if (length(idx) > 0) {
#  print(paste("There are", length(idx), "NAs in species"))
#  data[idx,]$species <- "Unknown"
#}
#
## 03-03
## There is not information of the species sex, thus we assuem that all records belong to the female
#idx <- which(data$sex != "F" & data$sex != "M")
#idx <- c(idx, which(is.na(data$sex)))
#
#if ( length(idx) > 0){
#  print(paste0("There are ", length(idx), " Unknown in sex column"))
#  data[idx,]$sex <- "Unknown"
#}
#
## 03-02 - samlpes collected
#
## The value of sandflies collected is categorized into 4 groups. we want to convert it to a single number
##15 instead of 1-30
##50 instead of 31-100
##100 instead of >100
##1000 instead of 1000
data <- data %>% mutate(number_of_collected = ifelse(number_of_collected == '1-30', 15, number_of_collected))
data <- data %>% mutate(number_of_collected = ifelse(number_of_collected == '31-100', 50, number_of_collected))
data <- data %>% mutate(number_of_collected = ifelse(number_of_collected == '>100', 100, number_of_collected))
data <- data %>% mutate(number_of_collected = ifelse(number_of_collected == '1000', 1000, number_of_collected))
#
## 03-03 - Coordinates on Sea for Greece
## Based on the title of dataset on CKAN, the data is related to Greece
## longitude: 23.90721, latitude: 37.75198 is on the sea, but appearntly it is simple mistake on order of longitude and latitude
## Thus we reverse the order of longitude and latitude, the coordinates would be on the land
thrshold <- 1e-5
idx <- which(abs(data$longitude - 23.90721) < thrshold &  abs( data$latitude - 37.75198) < thrshold)
data[idx,]$longitude <- 37.75198
data[idx,]$latitude <- 23.90721
#
## Same problem for the following coordinates
## 23.62030, 37.94956
idx <- which(abs(data$longitude - 23.62030) < thrshold &  abs( data$latitude - 37.94956) < thrshold)
data[idx,]$longitude <- 37.94956
data[idx,]$latitude <- 23.62030
#
#
## Same problem for the following coordinates
## 23.26437	37.70613
idx <- which(abs(data$longitude - 23.26437) < thrshold &  abs( data$latitude - 37.70613) < thrshold)
data[idx,]$longitude <- 37.70613
data[idx,]$latitude <- 23.26437
#
#
## for coordinate 24.59719 35.09033 we have a problem, but reverse order is not correct because it is on the sea near to Greec.
## This we should remove it
#idx <- which(abs(data$longitude - 24.59719) < thrshold &  abs( data$latitude - 35.09033) < thrshold)
#data <- data[-idx,]
#
#
## ====================================================================================================
## 03-04 - if start_date_of_sampling is biger than end_date_of_sampling, they should be swapped
#idx <- which(data$start_date > data$end_date)
#if (length(idx) > 0) {
#  print(paste("There are", length(idx), "records with start_date > end_date"))
#  sdate <- data[idx,]$start_date
#  edate <- data[idx,]$end_date
#  data[idx,]$start_date <- edate
#  data[idx,]$end_date <- sdate
#}
#
## The collecting methods should be one of these valid values: LT, SP, HC
## 02-04 Uniform the collection method, the original values are: "BGLCO2"   "NOBGLCO2"
## These type of trap is not a kind of light trap, but we can assume that they are similar to LT
#data <- data %>% mutate(collecting_methods = ifelse(collecting_methods == 'BGLCO2', 'LT', collecting_methods))
#data <- data %>% mutate(collecting_methods = ifelse(collecting_methods == 'NOBGLCO2', 'LT', collecting_methods))
## if collecting methos is empty string, it should be Nan
#idx <- which(data$collecting_methods == "")
#if (length(idx) > 0) {
#  print(paste("There are", length(idx), "empty strings in collecting_methods"))
#  data[idx,]$collecting_methods <- NA
#}
#unique(data$collecting_methods)

# 04 - Save the data =========================================================
data <- clean_dataset(data)
write_sandflies_data(data, name = "idalert")
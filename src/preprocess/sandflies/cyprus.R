# 01 - import libraries =============================================================
library(lubridate)
library(dplyr)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")
##
# This data set has 5 unique coordinates.
# Altought 15 various species are collected, the 4 most common species are
# phlebotomus_papatasi, sergenotmyia_dentata, phlebotomus_tobbi, sergentomyia_minuta, phlebotomus_galilaeous, sergentomyia_sp
# Collecting methods are LT, SP

# 02 - global variables =========================================================
data <- read_sandflies_data(name ="cyprus", type = "raw")
#data <- uniform_species_names(data)
#
## 01 - Remove other species
#data <- data %>% filter(!(species %in% 'others'))
#
## 02- Remove the rows that have NA in the number_of_collected column
#data <- data %>% filter(!is.na(number_of_collected))
#
## 03 - Remove zero values in the number_of_collected column in active months
#active_months <- c(5, 6, 7, 8, 9, 10)
#data$smonth <- month(data$start_date)
#data$smonth <- as.integer(data$smonth)
#zero_active <- data %>% filter((smonth %in% active_months & number_of_collected == 0))
#
## 02 00 - Summarizing the data
## coordinates <- data %>% dplyr::select(latitude, longitude) %>% distinct()
## colnames(coordinates) <- c("lat", "lon")
## coordinates <- get_nuts_name(coordinates)
##
## species <- data %>% group_by(species) %>% summarise(n = n(), dst = sum(number_of_collected, na.rm = TRUE)) %>% arrange(desc(dst))
##
## clm <- data %>% group_by(collecting_methods) %>% summarise(n = n(), dst = sum(number_of_collected, na.rm = TRUE)) %>% arrange(desc(dst))
#
## rename latitude and longitude to lat and lon
#
## 02-01 Appearntly, if the number_of_collected is Nan, it should be zero
##idx <- which(is.na(data$number_of_collected))
##if (length(idx) > 0) {
##  print(paste("There are", length(idx), "NAs in number_of_collected"))
##  data[idx,]$number_of_collected <- 0
##}
## 02-02 Check coordinates are in the sea or not
#
#res <- check_coordinate_in_sea(get_unique_coordinates(data))
#
## 02-03 Check of the sex column, if it is not F or M, it should be Unknown
#idx <- which(data$sex != "F" & data$sex != "M")
#if ( length(idx) > 0){
#  print(paste0("There are", length(idx), "Unknown in sex column"))
#  data[idx,]$sex <- "Unknown"
#}
#
## The collecting methods should be one of these valid values: LT, SP, HC
## 02-04 Uniform the collection method, the original values are: "CDC", "CDC_CO2", "CO2" , for the sake of uniformity, we will change them to LT
#
## if collecting methos is empty string, it should be Nan
#idx <- which(data$collecting_methods == "")
#if (length(idx) > 0) {
#  print(paste("There are", length(idx), "empty strings in collecting_methods"))
#  data[idx,]$collecting_methods <- NA
#}
#unique(data$collecting_methods)
#
## 03 - Checking duplicate rows. --------------------------------------------------------
## In this dataset they record collecting number in a different maps
## then we group them and get the maximum values.
#
#grp_key <- c("latitude", "longitude", "collecting_methods", "start_date", "end_date", "number_of_trap", "sex", "species") # required columns
#grp_count <- data %>% group_by_at(grp_key) %>% summarise(n = n()) %>% filter(n > 1)
#print(paste0(nrow(grp_count), " records are based on the different traps in a same place and same time.: "))
#data <- data %>% group_by_at(grp_key) %>% summarise(collecting_methods = first(collecting_methods), number_of_collected = max(number_of_collected)) %>% ungroup()
#
## as summarize
#well <- well_form_dataset(data)
#annual_summary <- annual_summarize(well)
# 04 - Save the data --------------------------------------------------------
data <- clean_dataset(data)
write_sandflies_data(data, "cyprus")

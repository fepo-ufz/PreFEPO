# 01 - import libraries =============================================================
library(lubridate)
library(dplyr)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")

# 02 - global variables =========================================================
data <- read_sandflies_data(name ="portugal", type = "raw")

# 02-00 Correct Formattings --------------------------------------------------------------------------------------------
##data$start_date <- as.Date(data$start_date)
##data$end_date <- as.Date(data$end_date)
##
### 02-01 - Remove other species -----------------------------------------------------------------------------------------
##data <- uniform_species_names(data)
##data <- data %>% filter(!(species %in% 'others'))
##
### 02-03- Remove the rows that have NA in the number_of_collected column ------------------------------------------------
##keys <- c("latitude", "longitude", "collecting_methods", "start_date", "number_of_collected")
##data <- data %>% drop_na(all_of(keys))
##
### 02-04 - Remove zero values in the number_of_collected column in active months ----------------------------------------
##active_months <- c(5, 6, 7, 8, 9, 10)
##data$smonth <- month(data$start_date)
##data$smonth <- as.integer(data$smonth)
##zero_active <- data %>% filter((smonth %in% active_months & number_of_collected == 0))
##data <- data %>% filter(!(smonth %in% active_months & number_of_collected == 0))
##
### 02-05 - Uniform Collection Method to LT, SP, HC ----------------------------------------------------------------------
### Uniform the collection method, the original values are: "CDC", "CDC_CO2", "CO2" , for the sake of uniformity, we will change them to LT
##
##data$collecting_methods <- ifelse(grepl("CDC|CO2", data$collecting_methods), "LT", data$collecting_methods)
##idx <- which(data$collecting_methods == "")
##if (length(idx) > 0) {
##  print(paste("There are", length(idx), "empty strings in collecting_methods"))
##  data[idx,]$collecting_methods <- NA
##}
##table(data$collecting_methods)
##
### 02-06 Check of the sex column, if it is not F or M, it should be Unknown ---------------------------------------------
##idx <- which(data$sex != "F" & data$sex != "M")
##if ( length(idx) > 0){
##  print(paste0("There are", length(idx), "Unknown in sex column"))
##  data[idx,]$sex <- "Unknown"
##}
##
### 02-07 Check the coordinates are in the sea or not,a nd also get the NUTS name ----------------------------------------
##coordinates <- check_coordinate_in_sea(get_unique_coordinates(data))
##coordinates <- get_nuts_name(coordinates)
##
### 02-08 Check the duplicate rows ---------------------------------------------------------------------------------------
##
##grp_key <- c("latitude", "longitude", "collecting_methods",
##             "start_date", "end_date", "number_of_trap", "sex", "species") # required columns
##grp_count <- data %>% group_by_at(grp_key) %>% summarise(n = n()) %>% filter(n > 1)
##print(paste0("The number of duplicated rows: ", abs(nrow(data) - nrow(grp_count))))
##data <- data %>% group_by_at(grp_key) %>% summarise(number_of_collected = max(number_of_collected)) %>% ungroup()

# 04 - Save the data --------------------------------------------------------
data <- clean_dataset(data)
write_sandflies_data(data, "portugal")

# 01 - import libraries =============================================================
library(lubridate)
library(dplyr)
library(dotenv)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")
# 02 - global variables =========================================================
data <- read_sandflies_data(name ="bulgaria", type = "raw")

### 02-01 - Remove other species
##data <- uniform_species_names(data)
##data <- data %>% filter(!(species %in% 'others'))
##
### 02-03- Remove the rows that have NA in the number_of_collected column
##keys <- c("latitude", "longitude", "collecting_methods", "start_date", "number_of_collected")
##data <- data %>% drop_na(all_of(keys))
##
### 02-04 - Remove zero values in the number_of_collected column in active months
##active_months <- c(5, 6, 7, 8, 9, 10)
##data$smonth <- month(data$start_date)
##data$smonth <- as.integer(data$smonth)
##zero_active <- data %>% filter((smonth %in% active_months & number_of_collected == 0))
##data <- data %>% filter(!(smonth %in% active_months & number_of_collected == 0))
##
### 02 - 05 - Uniform Collection Method to LT, SP, HC
##data$collecting_methods <- ifelse(grepl("CDC|CO2", data$collecting_methods), "LT", data$collecting_methods)
##
### 02-01 Appearntly, if the number_of_collected is Nan, it should be zero, <-- this is a mistake, we should not change the NA values to zero
### based on the last investigation, they put lots of Nan to show the some species does not exist in some places.
### thus instead of changing the Nan to zero, we should remove the nan values.
##
###idx <- which(is.na(data$number_of_collected))
###if (length(idx) > 0) {
###  print(paste("There are", length(idx), "NAs in number_of_collected"))
###  data[idx,]$number_of_collected <- 0
###}
##
##
### 02-02 Check coordinates are in the sea or not
##res <- check_coordinate_in_sea(get_unique_coordinates(data))
##
### 02-06 Check of the sex column, if it is not F or M, it should be Unknown
##idx <- which(data$sex != "F" & data$sex != "M")
##if ( length(idx) > 0){
##  print(paste0("There are", length(idx), "Unknown in sex column"))
##  data[idx,]$sex <- "Unknown"
##}
##
### Zero values in the number_of_collected column
### Yoni mentioned that this dataset prepared for a survery and the main object was comparing different niches
### Because of this this dataset cover large area and the number of collected sandflies might be less than actual.
### in another point Yoni mention that 'do not use points that have 0 sum of collected sandflies (unless 0 is the sum for the entire region).'
### it means the zero value in the midlle of time series data probably is not correct.
##
### 03 - Checking duplicate rows.
### In this dataset they record indoor and outdoor, we should aggregate the them
### then we group them and get the maximum values.
##
##grp_key <- c("latitude", "longitude", "collecting_methods", "start_date", "end_date", "number_of_trap", "sex", "species") # required columns
##grp_count <- data %>% group_by_at(grp_key) %>% summarise(n = n()) %>% filter(n > 1)
##print(paste0("The number of duplicated rows: ", abs(nrow(data) - nrow(grp_count))))
##data <- data %>% group_by_at(grp_key) %>% summarise(number_of_collected = max(number_of_collected)) %>% ungroup()
##
##
### if collecting methos is empty string, it should be Nan
##idx <- which(data$collecting_methods == "")
##if (length(idx) > 0) {
##  print(paste("There are", length(idx), "empty strings in collecting_methods"))
##  data[idx,]$collecting_methods <- NA
##}
##unique(data$collecting_methods)
##
### 04 - chech validity of the data -------------------------------------------
##well <- well_form_dataset(data)
##annual_sum <- annual_summarize(well)
##
### The result of the annual_summarize function shows that this dataset  collect the samples
### once in a year, thus it shows that these data prepared for a survey of the sandflies species in Bulgaria, not for the monitoring their popultion
### Based on the Yoni's comment, we should not use the points that have 0 collected sandflies
##
### My concern is that they did not enough traps to get the sandflies, thus the number of collected sandflies is understimates.
### thus I prefer to use just some record that have the number of collected sandflies (Male + Female) more than 5
##
###data <- well
###data <- data %>% filter(dst >= 5)     # <----- We should think about it
##
### This dataset is not so relaiable my idea is that we should remove all the record that sum of observation (F + M) is less than 5

# 04 - Save the data --------------------------------------------------------
data <- clean_dataset(data)
write_sandflies_data(data, "bulgaria")

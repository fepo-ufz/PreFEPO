# 01 - import libraries =============================================================
library(lubridate)
library(dplyr)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")
### General Explanation for this dataset ###
# In this data set, the genereal quality for data is very good.
# They gather informatio just for three coordinates.
# The collecting methods is LT  usually, and after 2020 they change to LT_CO2
# The species they focused is phlebotomus_mascittii


# 02 - global variables =========================================================
data <- read_sandflies_data(name ="austria", type = "raw")

### 02-01 Appearntly, if the number_of_collected is Nan, it should be zero
##idx <- which(is.na(data$number_of_collected))
##if (length(idx) > 0) {
##  print(paste("There are", length(idx), "NAs in number_of_collected"))
##  data[idx,]$number_of_collected <- 0
##}
### 02-02 Check coordinates are in the sea or not
##res <- check_coordinate_in_sea(get_unique_coordinates(data))
##
### 02-03 Check of the sex column, if it is not F or M, it should be Unknown
##idx <- which(data$sex != "F" & data$sex != "M")
##if ( length(idx) > 0){
##  print(paste0("There are", length(idx), " Unknown in sex column"))
##  data[idx,]$sex <- "Unknown"
##}
##
### 02-04 Uniform the collection method, the original values are: LT and LT_CO2, for the sake of uniformity, we will change them to LT
##data[, "collecting_methods"] <- ifelse(data$collecting_methods == "LT_CO2", "LT", data$collecting_methods)
### if collecting methos is empty string, it should be Nan
##idx <- which(data$collecting_methods == "")
##if (length(idx) > 0) {
##  print(paste("There are", length(idx), "empty strings in collecting_methods"))
##  data[idx,]$collecting_methods <- NA
##}
##unique(data$collecting_methods)
### 03 check duplicate rows --------------------------------------------------------
### We did not find any duplicate rows in this dataset
##grp_key <- c("latitude", "longitude", "collecting_methods", "start_date", "end_date", "number_of_trap", "sex", "species") # required columns
##grp <- data %>% group_by_at(grp_key) %>% summarise(number_of_collected = max(number_of_collected)) %>% ungroup()
##print(paste0("The number of duplicated rows", abs(nrow(data) - nrow(grp))))
##
### 04 - chech validity of the data -------------------------------------------
##well <- well_form_dataset(data)
##annual_sum <- annual_summarize(well)

# 04 - Save the data --------------------------------------------------------
data <- clean_dataset(data)
write_sandflies_data(data, "austria")


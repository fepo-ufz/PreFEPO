# 01 - import libraries =============================================================
library(lubridate)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")
# 02 - global variables =========================================================
data <- read_sandflies_data(name ="me3", type = "raw")

# 02-00 Correct Formattings --------------------------------------------------------------------------------------------
#ata$start_date <- as.Date(data$start_date)
#ata$end_date <- as.Date(data$end_date)

# 02-01 - Remove other species -----------------------------------------------------------------------------------------
#ata <- uniform_species_names(data)
#ata <- data %>% filter(!(species %in% 'others'))

# 02-03- Remove the rows that have NA in the number_of_collected column ------------------------------------------------
#eys <- c("latitude", "longitude", "collecting_methods", "start_date", "number_of_collected")
#ata <- data %>% drop_na(all_of(keys))

# 02-04 - Remove zero values in the number_of_collected column in active months ----------------------------------------
#ctive_months <- c(5, 6, 7, 8, 9, 10)
#ata$smonth <- month(data$start_date)
#ata$smonth <- as.integer(data$smonth)
#ero_active <- data %>% filter((smonth %in% active_months & number_of_collected == 0))
#ata <- data %>% filter(!(smonth %in% active_months & number_of_collected == 0))

# 02-05 - Uniform Collection Method to LT, SP, HC ----------------------------------------------------------------------
# Uniform the collection method, the original values are: "CDC", "CDC_CO2", "CO2" , for the sake of uniformity, we will change them to LT

#ata$collecting_methods <- ifelse(grepl("CDC|CO2", data$collecting_methods), "LT", data$collecting_methods)
#dx <- which(data$collecting_methods == "")
#f (length(idx) > 0) {
# print(paste("There are", length(idx), "empty strings in collecting_methods"))
# data[idx,]$collecting_methods <- NA
#
#able(data$collecting_methods)

# 02-06 Check of the sex column, if it is not F or M, it should be Unknown ---------------------------------------------
#dx <- which(data$sex != "F" & data$sex != "M")
#f ( length(idx) > 0){
# print(paste0("There are", length(idx), "Unknown in sex column"))
# data[idx,]$sex <- "Unknown"
#

# 02-07 Check the coordinates are in the sea or not,a nd also get the NUTS name ----------------------------------------
#oordinates <- check_coordinate_in_sea(get_unique_coordinates(data))
#oordinates <- get_nuts_name(coordinates)

# 02-08 Check the duplicate rows ---------------------------------------------------------------------------------------

#rp_key <- c("latitude", "longitude", "collecting_methods",
#            "start_date", "end_date", "number_of_trap", "sex", "species") # required columns
#rp_count <- data %>% group_by_at(grp_key) %>% summarise(n = n()) %>% filter(n > 1)
#rint(paste0("The number of duplicated rows: ", abs(nrow(data) - nrow(grp_count))))
#ata <- data %>% group_by_at(grp_key) %>% summarise(number_of_collected = max(number_of_collected)) %>% ungroup()

# 04 - Save the data =========================================================
data <- clean_dataset(data)
write_sandflies_data(data, name = "me3")


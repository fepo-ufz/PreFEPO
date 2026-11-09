# 01 - import libraries =============================================================
library(lubridate)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")
# 01 - global variables =========================================================
data <- read_sandflies_data(name ="vector", type = "raw")

### 02 - Filter by Expert idea ==========================================
###id_status, These are codes that eduardo has put up to see how much we can believe the data,
### he recommends that we only work with 001A, 002A, 003A
#data <- data %>% filter(id_status %in% c("NAT001A"))
### filter data if langitude and latitude are grather than 90
##data <- data %>% filter(!(latitude > 90 | latitude < -90 | longitude > 180 | longitude < -180))


##dd1 <- clean_dataset(data)
### 02-00 Correct Formattings --------------------------------------------------------------------------------------------
##data$start_date <- as.Date(data$start_date)
##data$end_date <- as.Date(data$end_date)

### Swap start_date and end_date if start_date is greater than end_date
##data <- data %>% mutate(start_date = pmin(start_date, end_date), end_date = pmax(start_date, end_date) )

##data <- data %>%  mutate(
##  latitude = if_else(latitude < -90 | latitude > 90, latitude / 1000, latitude),
##  longitude = if_else(longitude < -180 | longitude > 180, longitude / 1000, longitude),
##)

##data <- data %>% mutate(end_date = if_else(start_date == end_date, end_date + 1, end_date))

### 02-01 - Remove other species -----------------------------------------------------------------------------------------
##data <- uniform_species_names(data)
##table(data$species)
##data <- data %>% filter(!(species %in% 'others'))


##dd2 <- species_presence(data)


### 02-05 - Uniform Collection Method to LT, SP, HC ----------------------------------------------------------------------
### Uniform the collection method, the original values are: "CDC", "CDC_CO2", "CO2" , for the sake of uniformity, we will change them to LT

##data$collecting_methods <- ifelse(grepl("CDC|CO2|LTCO2", data$collecting_methods), "LT", data$collecting_methods)
##data$collecting_methods <- ifelse(grepl("ST|LST", data$collecting_methods), "SP", data$collecting_methods)
##data$collecting_methods <- ifelse(grepl("LT|SP|HC", data$collecting_methods), data$collecting_methods, "OTH")
##table(data$collecting_methods)

### 02-03- Remove the rows that have NA in the number_of_collected column ------------------------------------------------
##keys <- c("latitude", "longitude", "collecting_methods", "start_date", "number_of_collected")
##data <- data %>% drop_na(all_of(keys))
###if collecting method is LT, and trap_number is Nan, it should be removed

##idx <- which(data$collecting_methods == "LT" & (is.na(data$number_of_trap) | data$number_of_trap == 0 | data$number_of_trap > 20))
##if (length(idx) > 0)
##  data <- data[-idx,]

### 02-04 - Remove zero values in the number_of_collected column in active months ----------------------------------------
##active_months <- c(5, 6, 7, 8, 9, 10)
##data$smonth <- as.integer(month(data$start_date))
##zero_active <- data %>% filter((smonth %in% active_months & number_of_collected == 0))
##data <- data %>% filter(!(smonth %in% active_months & number_of_collected == 0))

### 02-06 Check of the sex column, if it is not F or M, it should be Unknown ---------------------------------------------
##data$sex <- ifelse(grepl("F|M", data$sex), data$sex, "Unknown")

### 02-08 - remove the records with duration more than 10 days
##data <- data %>%
##  mutate(duration = as.numeric(as.Date(end_date) - as.Date(start_date), units = "days")) %>%
##  filter(duration <= 10)

### 02-09 Check the coordinates are in the sea or not,a nd also get the NUTS name ----------------------------------------
##coordinates <- check_coordinate_in_sea(get_unique_coordinates(data))
##coordinates <- get_nuts_name(coordinates)

### 02-10 Check the duplicate rows ---------------------------------------------------------------------------------------

##grp_key <- c("latitude", "longitude", "collecting_methods",
##             "start_date", "end_date", "number_of_trap", "sex", "species") # required columns
##grp_count <- data %>% group_by_at(grp_key) %>% summarise(n = n()) %>% filter(n > 1)
##print(paste0("The number of duplicated rows: ", abs(nrow(data) - nrow(grp_count))))
##data <- data %>% group_by_at(grp_key) %>% summarise(number_of_collected = max(number_of_collected)) %>% ungroup()

# 04 - Save the data =========================================================
data <- clean_dataset(data)
write_sandflies_data(data, name = "vector")

# 01 - import libraries =============================================================
library(lubridate)
library(dplyr)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")
# 02 read the data =========================================================
flies <- read_sandflies_data(name = "aggregated_pa", type = "processed")
morphology <- read_morphology_data(name = "morphology", type = "processed")
meteo <- read_meteorology_data(name = "meteo", type = "processed")
meteo$sdate <- as.Date(meteo$sdate)
flies$sdate <- as.Date(flies$sdate)
flies$edate <- as.Date(flies$edate)
flies$dst <- as.integer(ifelse(flies$nst > 0, 1, 0))
flies <- expand_date(flies)

# 03 - Round coordinates =========================================================
precision <- 4
flies$lat <- round(flies$lat, precision)
flies$lon <- round(flies$lon, precision)
morphology$lat <- round(morphology$lat, precision)
morphology$lon <- round(morphology$lon, precision)
meteo$lat <- round(meteo$lat, precision)
meteo$lon <- round(meteo$lon, precision)

# 04- Join with morphology and meteo data =========================================================

data <- flies %>%
  left_join(morphology, by = c("lat", "lon")) %>%
  left_join(meteo, by = c("lat", "lon", "sdate")) %>%
  drop_na()


#column dst, and lables should be the last columns
colnames <- colnames(data)
colnames <- setdiff(colnames, c("dst", "edate", "nst", "ds", "expanded", "region_code"))
colnames <- c(colnames, "dst", "ds", "expanded", "region_code")
data <- data[, colnames]

numeric_columns <- colnames(data)[sapply(data, is.numeric)]
numeric_columns <- setdiff(numeric_columns, c("dst", "lc"))
data[numeric_columns] <- round(data[numeric_columns], 4)

# 05 Handle duplication of data =========================================================
group_keys <- c("swc1_1", "swc1_7", "swc1_90", "swc1_365", "pet_1", "pet_90")
data <- data %>%
  group_by(across(all_of(group_keys))) %>%
  slice_max(order_by = dst, n = 1, with_ties = FALSE) %>%  # Selects the row with max dst per group
  ungroup()

# 06 - Check the all continous columns shoould have between 0 and 1 =========================
min_values <- sapply(data, min, na.rm = TRUE)
max_values <- sapply(data, max, na.rm = TRUE)
min_max <- data.frame(min_values, max_values)
print(min_max)

# 07 - Save the data =========================================================
write_training_data(data, "trainingAT")

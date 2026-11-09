# 01 - import libraries =============================================================
library(lubridate)
library(dplyr)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")
# 02 read the data =========================================================
column_names <- c("lat", "lon", "cm", "sdate", "edate", "nt", "sex", "species", "nc", "ds", "region_code")
flies <- read_sandflies_data(name = "aggregated_as", type = "processed")
morphology <- read_morphology_data(name = "morphology", type = "processed")
meteo <- read_meteorology_data(name = "meteo", type = "processed")
hydro <- read_hydrology_data(name = "hydrology", type = "processed")
meteo$sdate <- as.Date(meteo$sdate)
hydro$sdate <- as.Date(hydro$sdate)
flies$sdate <- as.Date(flies$sdate)
flies$edate <- as.Date(flies$edate)
flies$duration <- as.numeric(flies$edate - flies$sdate, units = "days")
flies$dst <- flies$nst/flies$nt/flies$duration

# 02 - Flies data =========================================================

# We can make three division of training.
# 1: Without Species, and Without Collecting mmethod --> Presense/Absence
# 2: Without Species, and Collecing method of Light Trap --> Aggregation (Without Species)
# 3: With Species, and Collecing method of Light Trap --> Aggregation (With Species)

# Presence/Absence
group_keys <- c("lat", "lon", "sdate", "edate")
flies_pa <- flies %>%
  group_by_at(group_keys) %>%
  slice_max(order_by = dst, n = 1, with_ties = FALSE) %>%  # Selects the row with max dst per group
  mutate(dst = as.integer(ifelse(nst > 0, 1, 0))) %>%
  ungroup()

# We should not that, owing to use slice_max, the data is sorted by dst, and the first row is selected.
# because of these we have all columns such that collecting method, and species are not important.

# LT and Regression
flies_as <- flies %>%
  filter(cm == "LT") %>%
  group_by_at(group_keys) %>%
  slice_max(order_by = dst, n = 1, with_ties = FALSE) %>%  # Selects the row with max dst per group
  mutate(dst = log(dst + 1)) %>%
  ungroup()

# LT, Species and Regression
flies_ws <- flies %>%
  filter(cm == "LT") %>%
  group_by_at(c(group_keys, "species")) %>%
  slice_max(order_by = dst, n = 1, with_ties = FALSE) %>%  # Selects the row with max dst per group
  mutate(dst = log(dst + 1)) %>%
  ungroup()

# 03 Remove irrelevant columns =========================================================
cnames <- c(group_keys, "dst", "ds")
flies_pa <- flies_pa[, cnames]

cnames <- c(group_keys, "species", "dst", "ds")
flies_as <- flies_as[, cnames]
flies_ws <- flies_ws[, cnames]

flies_pa <- expand_date(flies_pa)
flies_as <- expand_date(flies_as)
flies_ws <- expand_date(flies_ws)

flies_pa <- get_region_code(flies_pa)
flies_as <- get_region_code(flies_as)
flies_ws <- get_region_code(flies_ws)

species_dict <- c(papatasi = 0, perniciosus = 1, sergenti = 2, tobbi = 3,
                  alexandri = 4, ariasi = 5, major_sl = 6, mascittii = 7, neglectus = 8,
                  perfiliewi = 9, similis = 10, others = 11)

flies_as <- flies_as %>% mutate(spec_code = as.integer(species_dict[species]))
flies_ws <- flies_ws %>% mutate(spec_code = as.integer(species_dict[species]))


# Remove invalid situations
flies_ws <- flies_ws %>% group_by(species) %>% filter(sum(dst > 0) > 50) %>%  ungroup()
flies_ws <- flies_ws %>% filter(species != "others")
# if lat < 35 and sdate month is 1,2,12 an ddst is not 0 shoul dbe removed
flies_ws <- flies_ws %>% filter(!(lat > 35 & month(sdate) %in% c(1, 2, 12) & dst > 0))



# 04 - Round coordinates =========================================================
precision <- 4
flies$lat <- round(flies$lat, precision)
flies$lon <- round(flies$lon, precision)
morphology$lat <- round(morphology$lat, precision)
morphology$lon <- round(morphology$lon, precision)
meteo$lat <- round(meteo$lat, precision)
meteo$lon <- round(meteo$lon, precision)
hydro$lat <- round(hydro$lat, precision)
hydro$lon <- round(hydro$lon, precision)

# 04- Join with morphology and meteo data =========================================================

data_pa <- flies_pa %>%
  left_join(morphology, by = c("lat", "lon")) %>%
  left_join(meteo, by = c("lat", "lon", "sdate")) %>%
  left_join(hydro, by = c("lat", "lon", "sdate")) %>%
  drop_na()

data_as <- flies_as %>%
  left_join(morphology, by = c("lat", "lon")) %>%
  left_join(meteo, by = c("lat", "lon", "sdate")) %>%
  left_join(hydro, by = c("lat", "lon", "sdate")) %>%
  drop_na()

data_ws <- flies_ws %>%
  left_join(morphology, by = c("lat", "lon")) %>%
  left_join(meteo, by = c("lat", "lon", "sdate")) %>%
  left_join(hydro, by = c("lat", "lon", "sdate")) %>%
  drop_na()

#column dst, and lables should be the last columns
colnames <- colnames(data_pa)
colnames <- setdiff(colnames, c("dst", "edate", "nst", "ds", "expid" ,"expanded", "region_code"))
colnames <- c(colnames, "dst", "ds", "expid", "region_code")

data_pa <- data_pa[, colnames]

colnames <- colnames(data_as)
colnames <- setdiff(colnames, c("dst", "edate", "nst", "ds", "expid" ,"expanded", "region_code", "species", "spec_code"))
colnames <- c(colnames, "species", "spec_code", "dst", "ds", "expid", "region_code")

data_as <- data_as[, colnames]
data_ws <- data_ws[, colnames]

numeric_columns <- colnames(data_pa)[sapply(data_pa, is.numeric)]
numeric_columns <- setdiff(numeric_columns, c("dst", "lc"))

data_pa[numeric_columns] <- round(data_pa[numeric_columns], 4)
data_as[numeric_columns] <- round(data_as[numeric_columns], 4)
data_ws[numeric_columns] <- round(data_ws[numeric_columns], 4)
# 05 Handle duplication of data =========================================================
group_keys <- setdiff(colnames(meteo),c("lat", "lon", "sdate"))
data_pa <- data_pa %>%
  group_by(across(all_of(group_keys))) %>%
  slice_max(order_by = dst, n = 1, with_ties = FALSE) %>%  # Selects the row with max dst per group
  ungroup()

data_as <- data_as %>%
  group_by(across(all_of(group_keys))) %>%
  slice_max(order_by = dst, n = 1, with_ties = FALSE) %>%  # Selects the row with max dst per group
  ungroup()

group_keys <- c(group_keys, "species")
data_ws <- data_ws %>%
    group_by(across(all_of(group_keys))) %>%
    slice_max(order_by = dst, n = 1, with_ties = FALSE) %>%  # Selects the row with max dst per group
    ungroup()

# 06 - Check the all continous columns shoould have between 0 and 1 =========================
min_values <- sapply(data_pa, min, na.rm = TRUE)
max_values <- sapply(data_pa, max, na.rm = TRUE)
min_max <- data.frame(min_values, max_values)
print(min_max)

# 07 - Save the data =========================================================
write_training_data(data_pa, "trainingPA")
write_training_data(data_as, "trainingAS")
write_training_data(data_ws, "trainingWS")

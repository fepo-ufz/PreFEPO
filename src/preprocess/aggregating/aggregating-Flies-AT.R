# Aggregating Flies with All Trap types/collecting methods
# Makig a presence/absence dataset
# collecting_mthod and species are ingored
# 01 - import libraries =============================================================
library(lubridate)
library(dplyr)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")

# 02 - global variables =========================================================
ds_final <- data.frame(
  lat = numeric(),  # latitude
  lon = numeric(),  # longitude
  sdate = character(), # start date
  edate = character(), # end date
  nst = numeric(), # number of sandflies Total
  ds = character(), # dataset name
  stringsAsFactors = FALSE)

column_names <- c("lat", "lon", "sdate", "edate", "nst", "ds")
group_keys <- c("latitude", "longitude", "start_date", "end_date")
# 03 - Ednext dataset ===============================================================
data_edenext <- read_sandflies_data(name = "edenext", type = "processed")
data_edenext <- data_edenext %>% group_by_at(group_keys) %>% summarise(nst = max(number_of_collected)) %>% ungroup()
data_edenext$ds <- "edenext"
colnames(data_edenext) <- column_names
# 04 - IDAlert dataset ===============================================================
data_idalert <- read_sandflies_data(name = "idalert", type = "processed")
data_idalert <- data_idalert %>% group_by_at(group_keys) %>% summarise(nst = max(number_of_collected)) %>% ungroup()
data_idalert$ds <- "idalert"
colnames(data_idalert) <- column_names
# 05 - ME1 the data ===============================================================
data_me1 <- read_sandflies_data("ME1", type = "processed")
data_me1 <- data_me1 %>% group_by_at(group_keys) %>% summarise(nst = max(number_of_collected)) %>% ungroup()
data_me1$ds <- "ME1"
colnames(data_me1) <- column_names
# 06 - ME2 the data ===============================================================
data_me2 <- read_sandflies_data("ME2", type = "processed")
data_me2 <- data_me2 %>% group_by_at(group_keys) %>% summarise(nst = max(number_of_collected)) %>% ungroup()
data_me2$ds <- "ME2"
colnames(data_me2) <- column_names
# 07 - ME3 the data ===============================================================
data_me3 <- read_sandflies_data("ME3", type = "processed")
data_me3 <- data_me3 %>% group_by_at(group_keys) %>% summarise(nst = max(number_of_collected)) %>% ungroup()
data_me3$ds <- "ME3"
colnames(data_me3) <- column_names
# 08 - ME4 the data ===============================================================
data_me4 <- read_sandflies_data("ME4", type = "processed")
data_me4 <- data_me4 %>% group_by_at(group_keys) %>% summarise(nst = max(number_of_collected)) %>% ungroup()
data_me4$ds <- "ME4"
colnames(data_me4) <- column_names
## 09 - VectorNet  the data ============================================================
data_vectornet <- read_sandflies_data("vector", type = "processed")
data_vectornet <- data_vectornet %>% group_by_at(group_keys) %>% summarise(nst = max(number_of_collected)) %>% ungroup()
data_vectornet$ds <- "vector"
colnames(data_vectornet) <- column_names
## 10 - Crete  the data ============================================================
data_crete <- read_sandflies_data("crete", type = "processed")
data_crete <- data_crete %>% group_by_at(group_keys) %>% summarise(nst = max(number_of_collected)) %>% ungroup()
data_crete$ds <- "crete"
colnames(data_crete) <- column_names
## 11 - Cyprus  the data ============================================================
data_cyprus <- read_sandflies_data("cyprus", type = "processed")
data_cyprus <- data_cyprus %>% group_by_at(group_keys) %>% summarise(nst = max(number_of_collected)) %>% ungroup()
data_cyprus$ds <- "cyprus"
colnames(data_cyprus) <- column_names
## 12 - Israel  the data ============================================================
data_israel <- read_sandflies_data("israel", type = "processed")
data_israel <- data_israel %>% group_by_at(group_keys) %>% summarise(nst = max(number_of_collected)) %>% ungroup()
data_israel$ds <- "israel"
colnames(data_israel) <- column_names
## 13 - Italy  the data ============================================================
data_italy <- read_sandflies_data("italy", type = "processed")
data_italy <- data_italy %>% group_by_at(group_keys) %>% summarise(nst = max(number_of_collected)) %>% ungroup()
data_italy$ds <- "italy"
colnames(data_italy) <- column_names
## 14 - Madrid  the data ============================================================
data_madrid <- read_sandflies_data("madrid", type = "processed")
data_madrid <- data_madrid %>% group_by_at(group_keys) %>% summarise(nst = max(number_of_collected)) %>% ungroup()
data_madrid$ds <- "madrid"
colnames(data_madrid) <- column_names
## 15 - Slovenia  the data ============================================================
data_slovenia <- read_sandflies_data("slovenia", type = "processed")
data_slovenia <- data_slovenia %>% group_by_at(group_keys) %>% summarise(nst = max(number_of_collected)) %>% ungroup()
data_slovenia$ds <- "slovenia"
colnames(data_slovenia) <- column_names
## 16 - Turkey  the data ============================================================
data_turkey <- read_sandflies_data("turkey", type = "processed")
data_turkey <- data_turkey %>% group_by_at(group_keys) %>% summarise(nst = max(number_of_collected)) %>% ungroup()
data_turkey$ds <- "turkey"
colnames(data_turkey) <- column_names
## 17 - Austeria  the data ============================================================
data_austria <- read_sandflies_data("austria", type = "processed")
data_austria <- data_austria %>% group_by_at(group_keys) %>% summarise(nst = max(number_of_collected)) %>% ungroup()
data_austria$ds <- "austria"
colnames(data_austria) <- column_names
## 18 - Bulgarie  the data ============================================================
data_bulgaria <- read_sandflies_data("bulgaria", type = "processed")
data_bulgaria <- data_bulgaria %>% group_by_at(group_keys) %>% summarise(nst = max(number_of_collected)) %>% ungroup()
data_bulgaria$ds <- "bulgaria"
colnames(data_bulgaria) <- column_names
## 19 - France the data ============================================================
data_france <- read_sandflies_data("france", type = "processed")
data_france <- data_france %>% group_by_at(group_keys) %>% summarise(nst = max(number_of_collected)) %>% ungroup()
data_france$ds <- "france"
colnames(data_france) <- column_names
## 20 - Mugla the data ============================================================
data_mugla <- read_sandflies_data("mugla", type = "processed")
data_mugla <- data_mugla %>% group_by_at(group_keys) %>% summarise(nst = max(number_of_collected)) %>% ungroup()
data_mugla$ds <- "mugla"
colnames(data_mugla) <- column_names
## 21 - Portugal the data ============================================================
data_portugal <- read_sandflies_data("portugal", type = "processed")
data_portugal <- data_portugal %>% group_by_at(group_keys) %>% summarise(nst = max(number_of_collected)) %>% ungroup()
data_portugal$ds <- "portugal"
colnames(data_portugal) <- column_names
## 22 - Sicily the data ============================================================
data_sicily <- read_sandflies_data("sicily", type = "processed")
data_sicily <- data_sicily %>% group_by_at(group_keys) %>% summarise(nst = max(number_of_collected)) %>% ungroup()
data_sicily$ds <- "sicily"
colnames(data_sicily) <- column_names

## 23 - RowBind datset =================================================================
ds_final <- rbind(ds_final, data_edenext)
ds_final <- rbind(ds_final, data_idalert)
ds_final <- rbind(ds_final, data_me1)
ds_final <- rbind(ds_final, data_me2)
ds_final <- rbind(ds_final, data_me3)
ds_final <- rbind(ds_final, data_me4)
ds_final <- rbind(ds_final, data_vectornet)
ds_final <- rbind(ds_final, data_crete)
ds_final <- rbind(ds_final, data_cyprus)
ds_final <- rbind(ds_final, data_israel)
ds_final <- rbind(ds_final, data_italy)
ds_final <- rbind(ds_final, data_madrid)
ds_final <- rbind(ds_final, data_slovenia)
ds_final <- rbind(ds_final, data_turkey)
ds_final <- rbind(ds_final, data_austria)
ds_final <- rbind(ds_final, data_bulgaria)
ds_final <- rbind(ds_final, data_france)
ds_final <- rbind(ds_final, data_mugla)
ds_final <- rbind(ds_final, data_portugal)
ds_final <- rbind(ds_final, data_sicily)

ds_final <- remove_coordinates_in_sea(ds_final)
ds_final <- remove_outof_domain(ds_final)
ds_final <- get_region_code(ds_final)

# 24 - Save the data =================================================================
write_sandflies_data(ds_final, name = "aggregated_pa")
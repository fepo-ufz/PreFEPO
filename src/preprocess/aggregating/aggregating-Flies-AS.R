# Aggregating Flies with All Species.
# The species is not important, and for a given coordinates and date we consder the max collecting number
# It means we focus on dominant species.
# 01 - import libraries =============================================================
library(lubridate)
library(dplyr)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")
# 02 - global variables =========================================================
#define data frame with these columns 'lat', 'lon', 'date', 'ns', 'ds'
ds_final <- data.frame(
  lat = numeric(),  # latitude
  lon = numeric(),  # longitude
  sdate = character(), # start date
  edate = character(), # end date
  species = character(), # species name
  nt = numeric(), # number of traps
  nsm = numeric(), # number of sandflies Male
  nsf = numeric(), # number of sandflies Female
  nsu = numeric(), # number of sandflies Unknown
  nst = numeric(), # number of sandflies Total
  ds = character(), # dataset name
  stringsAsFactors = FALSE)


#column_names <- c("lat", "lon", "sdate", "edate", "species", "nt", "nsm", "nsf", "nsu", "nst")
#column_names <- c("lat", "lon", "sdate", "edate", "species", "dst")

# 03 - Ednext dataset ===============================================================
data_edenext <- read_sandflies_data(name = "edenext", type = "processed")
data_edenext$ds <- "edenext"
# 04 - IDAlert dataset ===============================================================
data_idalert <- read_sandflies_data(name = "idalert", type = "processed")
data_idalert$ds <- "idalert"
# 05 - ME1 the data ===============================================================
data_me1 <- read_sandflies_data("ME1", type = "processed")
data_me1$ds <- "ME1"
# 06 - ME2 the data ===============================================================
data_me2 <- read_sandflies_data("ME2", type = "processed")
data_me2$ds <- "ME2"
# 07 - ME3 the data ===============================================================
data_me3 <- read_sandflies_data("ME3", type = "processed")
data_me3$ds <- "ME3"
# 08 - ME4 the data ===============================================================
data_me4 <- read_sandflies_data("ME4", type = "processed")
data_me4$ds <- "ME4"
## 09 - VectorNet  the data ============================================================
data_vectornet <- read_sandflies_data("vector", type = "processed")
data_vectornet$ds <- "vector"
## 10 - Crete  the data ============================================================
data_crete <- read_sandflies_data("crete", type = "processed")
data_crete$ds <- "crete"
## 11 - Cyprus  the data ============================================================
data_cyprus <- read_sandflies_data("cyprus", type = "processed")
data_cyprus$ds <- "cyprus"
## 12 - Israel  the data ============================================================
data_israel <- read_sandflies_data("israel", type = "processed")
data_israel$ds <- "israel"
## 13 - Italy  the data ============================================================
data_italy <- read_sandflies_data("italy", type = "processed")
data_italy$ds <- "italy"
## 14 - Madrid  the data ============================================================
data_madrid <- read_sandflies_data("madrid", type = "processed")
data_madrid$ds <- "madrid"
## 15 - Slovenia  the data ============================================================
data_slovenia <- read_sandflies_data("slovenia", type = "processed")
data_slovenia$ds <- "slovenia"
## 16 - Turkey  the data ============================================================
data_turkey <- read_sandflies_data("turkey", type = "processed")
data_turkey$ds <- "turkey"
## 17 - Austeria  the data ============================================================
data_austria <- read_sandflies_data("austria", type = "processed")
data_austria$ds <- "austria"
## 18 - Bulgarie  the data ============================================================
data_bulgaria <- read_sandflies_data("bulgaria", type = "processed")
data_bulgaria$ds <- "bulgaria"
## 19 - France the data ============================================================
data_france <- read_sandflies_data("france", type = "processed")
data_france$ds <- "france"
## 20 - Mugla the data ============================================================
data_mugla <- read_sandflies_data("mugla", type = "processed")
data_mugla$ds <- "mugla"
## 21 - Portugal the data ============================================================
data_portugal <- read_sandflies_data("portugal", type = "processed")
data_portugal$ds <- "portugal"
## 22 - Sicily the data ============================================================
data_sicily <- read_sandflies_data("sicily", type = "processed")
data_sicily$ds <- "sicily"

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


# if collecting_method is not LT, number_of_trap should be 1
ds_final <- ds_final %>% mutate(number_of_trap = ifelse(toupper(collecting_methods) != "LT", 1, number_of_trap))
ds_final <- remove_coordinates_in_sea(ds_final)
ds_final <- remove_outof_domain(ds_final)
#ds_final <- get_region_code(ds_final)

# 24 - Save the data =================================================================
# cm : collecting method, nt: number of trap, ns  : number of collected, ds: dataset name

column_names <- c("lat", "lon", "cm", "sdate", "edate", "nt", "sex", "species", "ns", "ds")
colnames(ds_final) <- column_names

ds_final <- ds_final %>%
  group_by(lat, lon, cm, sdate, edate, nt, species, ns, ds) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

column_names <- setdiff(column_names,c('ns', 'ds', 'nsm', 'nsf', 'nsu', 'sex'))
column_names <- c(column_names, 'nst', 'ds')
ds_final <- ds_final[, column_names]
write_sandflies_data(ds_final, name = "aggregated_as")

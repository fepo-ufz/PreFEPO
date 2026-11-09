library(lubridate)
library(dplyr)
source("src/base.R")
# 02 uniforming the data =========================================================
#morph <- read_morphology_data(name = "sc01", type = "raw")
##morph <- morph %>% dplyr::select(c("lat", "lon", "soil_class_horizon_01_13"))
#soildef <- read_morphology_data(name = "scdef", type = "raw")
#
#data <- morph %>%
#    left_join(soildef, by = c("soil_class_horizon_01_1" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_2" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_3" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_4" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_5" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_6" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_7" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_8" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_9" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_10" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_11" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_12" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_13" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_14" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_15" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_16" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_17" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_18" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_19" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_20" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_21" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_22" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_23" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_24" = "ID")) %>%
#    left_join(soildef, by = c("soil_class_horizon_01_25" = "ID"))
#
##select columns which their name include "SAND", average them and add them to the data
#sand <- data %>% dplyr::select(contains("SAND")) %>% rowMeans(na.rm = TRUE)
#data <- data %>% mutate(sand = sand * 0.01)
#clay <- data %>% dplyr::select(contains("CLAY")) %>% rowMeans(na.rm = TRUE)
#data <- data %>% mutate(clay = clay * 0.01)
## selct columns lat, lon, sand, clay and write them to a csv file
#data <- data %>% dplyr::select(c("lat", "lon", "sand", "clay"))
#write_morphology_data(data = data, name = "sc")


sand <- read_morphology_data(name = "sand", type = "raw")
sand <- sand %>% dplyr::select(c("lat", "lon", "sand_13")) %>% mutate(sand = sand_13 * 0.01)
sand <- sand %>% dplyr::select(c("lat", "lon", "sand"))
clay <- read_morphology_data(name = "clay", type = "raw")
clay <- clay %>% dplyr::select(c("lat", "lon", "clay_13"))%>% mutate(clay = clay_13 * 0.01)
clay <- clay %>% dplyr::select(c("lat", "lon", "clay"))

data <- sand %>%
    left_join(clay, by = c("lat", "lon"))

write_morphology_data(data = data, name = "sc")
# In this file all species among the observation dataset are gathered.
# The type of trapping method is not considered in this file, because we want just to know whcih species are observed in the CLIMOS domain.
# The species are gathered from the following datasets:
# 01 - import libraries =============================================================
library(lubridate)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")
source("src/preprocess/aggregating/species.R")
# 02 - global variables =============================================================
ds_species <- data.frame(
  lat = numeric(),  # latitude
  lon = numeric(),  # longitude
  species = character(), # species name
  spec_code = numeric(), # species code
  ds = character(), # dataset name
  stringsAsFactors = FALSE)
# 03 - read data ====================================================================

# 03 - Ednext dataset ===============================================================
data_edenext <- read_sandflies_data(name = "edenext", type = "raw")
data_edenext <- remove_NA_coordinates(data_edenext)
data_edenext <- remove_coordinates_in_sea(data_edenext)
# if there is any sandflies is observed.
data_edenext <- data_edenext %>% filter(!is.na(number_of_collected) & number_of_collected > 0)
# select the columns lat, lon, species
data_edenext <- data_edenext %>% dplyr::select(latitude, longitude, species)
data_edenext <- data_edenext %>% rename(spec = species)
data_edenext <- species_uniforming(data_edenext, coding = TRUE)
freq <- data_edenext %>% group_by(spec) %>% summarise(n = n())
data_edenext <- data_edenext %>% distinct()
data_edenext$ds <- "edenext"
# 04 - IDAlert dataset ===============================================================
data_idalert <- read_sandflies_data(name = "idalert", type = "raw")
data_idalert <- remove_NA_coordinates(data_idalert)
data_idalert <- remove_coordinates_in_sea(data_idalert)
# if there is any sandflies is observed.
data_idalert <- data_idalert %>% filter(!is.na(number_of_collected) & number_of_collected > 0)
data_idalert <- data_idalert %>% dplyr::select(latitude, longitude, species)
data_idalert <- data_idalert %>% rename(spec = species)
data_idalert <- species_uniforming(data_idalert, coding = TRUE)
freq <- data_idalert %>% group_by(spec) %>% summarise(n = n())
data_idalert <- data_idalert %>% distinct()
data_idalert$ds <- "idalert"
# 05 - ME1 the data ===============================================================
data_me1 <- read_sandflies_data("ME1", type = "raw")
data_me1 <- remove_NA_coordinates(data_me1)
data_me1 <- remove_coordinates_in_sea(data_me1)
# if there is any sandflies is observed.
data_me1 <- data_me1 %>% filter(!is.na(number_of_collected) & number_of_collected > 0)
data_me1 <- data_me1 %>% dplyr::select(latitude, longitude, species)
data_me1 <- data_me1 %>% rename(spec = species)
data_me1 <- species_uniforming(data_me1, coding = TRUE)
freq <- data_me1 %>% group_by(spec) %>% summarise(n = n())
data_me1 <- data_me1 %>% distinct()
data_me1$ds <- "ME1"
# 06 - ME2 the data ===============================================================
data_me2 <- read_sandflies_data("ME2", type = "raw")
data_me2 <- remove_NA_coordinates(data_me2)
data_me2 <- remove_coordinates_in_sea(data_me2)
# if there is any sandflies is observed.
data_me2 <- data_me2 %>% filter(!is.na(number_of_collected) & number_of_collected > 0)
data_me2 <- data_me2 %>% dplyr::select(latitude, longitude, species)
data_me2 <- data_me2 %>% rename(spec = species)
data_me2 <- species_uniforming(data_me2, coding = TRUE)
freq <- data_me2 %>% group_by(spec) %>% summarise(n = n())
data_me2 <- data_me2 %>% distinct()
data_me2$ds <- "ME2"
# 07 - ME3 the data ===============================================================
data_me3 <- read_sandflies_data("ME3", type = "raw")
data_me3 <- remove_NA_coordinates(data_me3)
data_me3 <- remove_coordinates_in_sea(data_me3)
# if there is any sandflies is observed.
data_me3 <- data_me3 %>% filter(!is.na(number_of_collected) & number_of_collected > 0)
data_me3 <- data_me3 %>% dplyr::select(latitude, longitude, species)
data_me3 <- data_me3 %>% rename(spec = species)
data_me3 <- species_uniforming(data_me3, coding = TRUE)
freq <- data_me3 %>% group_by(spec) %>% summarise(n = n())
data_me3 <- data_me3 %>% distinct()
data_me3$ds <- "ME3"
# 07 - ME4 the data ===============================================================
data_me4 <- read_sandflies_data("ME4", type = "raw")
data_me4 <- remove_NA_coordinates(data_me4)
data_me4 <- remove_coordinates_in_sea(data_me4)
# if there is any sandflies is observed.
data_me4 <- data_me4 %>% filter(!is.na(number_of_collected) & number_of_collected > 0)
data_me4 <- data_me4 %>% dplyr::select(latitude, longitude, species)
data_me4 <- data_me4 %>% rename(spec = species)
data_me4 <- species_uniforming(data_me4, coding = TRUE)
freq <- data_me4 %>% group_by(spec) %>% summarise(n = n())
data_me4 <- data_me4 %>% distinct()
data_me4$ds <- "ME4"
## 08 - VectorNet the data ===============================================================
data_vector <- read_sandflies_data("vector", type = "raw")
data_vector <- data_vector %>%
  filter(id_status %in% c("NAT001A", "NAT002A")) # NAT001A: denoting presence
#"NAT001A", "NAT002A", "NAT003A"

data_vector <- remove_NA_coordinates(data_vector)
data_vector <- remove_coordinates_in_sea(data_vector)
# if there is any sandflies is observed.
data_vector <- data_vector %>% filter(!is.na(number_of_collected) & number_of_collected > 0)
data_vector <- data_vector %>% dplyr::select(latitude, longitude, species)
data_vector <- data_vector %>% rename(spec = species)
data_vector <- species_uniforming(data_vector, coding = TRUE)
freq <- data_vector %>% group_by(spec) %>% summarise(n = n())
data_vector <- data_vector %>% distinct()
data_vector$ds <- "vector"
## 09 - Crete  the data ============================================================
data_crete <- read_sandflies_data("crete", type = "raw")
data_crete <- remove_NA_coordinates(data_crete)
data_crete <- remove_coordinates_in_sea(data_crete)
# if there is any sandflies is observed.
data_crete <- data_crete %>% filter(!is.na(number_of_collected) & number_of_collected > 0)
data_crete <- data_crete %>% dplyr::select(latitude, longitude, species)
data_crete <- data_crete %>% rename(spec = species)
data_crete <- species_uniforming(data_crete, coding = TRUE)
freq <- data_crete %>% group_by(spec) %>% summarise(n = n())
data_crete <- data_crete %>% distinct()
data_crete$ds <- "crete"
## 10 - Cyprus  the data ============================================================
data_cyprus <- read_sandflies_data("cyprus", type = "raw")
data_cyprus <- remove_NA_coordinates(data_cyprus)
data_cyprus <- remove_coordinates_in_sea(data_cyprus)
# if there is any sandflies is observed.
data_cyprus <- data_cyprus %>% filter(!is.na(number_of_collected) & number_of_collected > 0)
data_cyprus <- data_cyprus %>% dplyr::select(latitude, longitude, species)
data_cyprus <- data_cyprus %>% rename(spec = species)
data_cyprus <- species_uniforming(data_cyprus, coding = TRUE)
freq <- data_cyprus %>% group_by(spec) %>% summarise(n = n())
data_cyprus <- data_cyprus %>% distinct()
data_cyprus$ds <- "cyprus"
## 11 - Israel  the data ============================================================
data_israel <- read_sandflies_data("israel", type = "raw")
data_israel <- remove_NA_coordinates(data_israel)
data_israel <- remove_coordinates_in_sea(data_israel)
# if there is any sandflies is observed
data_israel <- data_israel %>% filter(!is.na(number_of_collected) & number_of_collected > 0)
data_israel <- data_israel %>% dplyr::select(latitude, longitude, species)
data_israel <- data_israel %>% rename(spec = species)
data_israel <- species_uniforming(data_israel, coding = TRUE)
freq <- data_israel %>% group_by(spec) %>% summarise(n = n())
data_israel <- data_israel %>% distinct()
data_israel$ds <- "israel"
## 12 - Italy  the data ============================================================
data_italy <- read_sandflies_data("italy", type = "raw")
sub_data_italy <- remove_NA_coordinates(data_italy)
data_italy <- remove_coordinates_in_sea(data_italy)
# if there is any sandflies is observed
data_italy <- data_italy %>% filter(!is.na(number_of_collected) & number_of_collected > 0)
data_italy <- data_italy %>% dplyr::select(latitude, longitude, species)
data_italy <- data_italy %>% rename(spec = species)
data_italy <- species_uniforming(data_italy, coding = TRUE)
freq <- data_italy %>% group_by(spec) %>% summarise(n = n())
data_italy <- data_italy %>% distinct()
data_italy$ds <- "italy"
## 13 - Madrid  the data ============================================================
data_madrid <- read_sandflies_data("madrid", type = "raw")
data_madrid <- remove_NA_coordinates(data_madrid)
data_madrid <- remove_coordinates_in_sea(data_madrid)
# if there is any sandflies is observed
data_madrid <- data_madrid %>% filter(!is.na(number_of_collected) & number_of_collected > 0)
data_madrid <- data_madrid %>% dplyr::select(latitude, longitude, species)
data_madrid <- data_madrid %>% rename(spec = species)
data_madrid <- species_uniforming(data_madrid, coding = TRUE)
freq <- data_madrid %>% group_by(spec) %>% summarise(n = n())
data_madrid <- data_madrid %>% distinct()
data_madrid$ds <- "madrid"
## 14 - Slovenia  the data ============================================================
data_slovenia <- read_sandflies_data("slovenia", type = "raw")
data_slovenia <- remove_NA_coordinates(data_slovenia)
data_slovenia <- remove_coordinates_in_sea(data_slovenia)
# if there is any sandflies is observed
data_slovenia <- data_slovenia %>% filter(!is.na(number_of_collected) & number_of_collected > 0)
data_slovenia <- data_slovenia %>% dplyr::select(latitude, longitude, species)
data_slovenia <- data_slovenia %>% rename(spec = species)
data_slovenia <- species_uniforming(data_slovenia, coding = TRUE)
freq <- data_slovenia %>% group_by(spec) %>% summarise(n = n())
data_slovenia <- data_slovenia %>% distinct()
data_slovenia$ds <- "slovenia"
## 15 - Turkey  the data ============================================================
data_turkey <- read_sandflies_data("turkey", type = "raw")
data_turkey <- remove_NA_coordinates(data_turkey)
data_turkey <- remove_coordinates_in_sea(data_turkey)
# if there is any sandflies is observed
data_turkey <- data_turkey %>% filter(!is.na(number_of_collected) & number_of_collected > 0)
data_turkey <- data_turkey %>% dplyr::select(latitude, longitude, species)
data_turkey <- data_turkey %>% rename(spec = species)
data_turkey <- species_uniforming(data_turkey, coding = TRUE)
freq <- data_turkey %>% group_by(spec) %>% summarise(n = n())
data_turkey <- data_turkey %>% distinct()
data_turkey$ds <- "turkey"

## 16 Austria  the data ============================================================
data_austria <- read_sandflies_data("austria", type = "raw")
data_austria <- remove_NA_coordinates(data_austria)
data_austria <- remove_coordinates_in_sea(data_austria)
# if there is any sandflies is observed
data_austria <- data_austria %>% filter(!is.na(number_of_collected) & number_of_collected > 0)
data_austria <- data_austria %>% dplyr::select(latitude, longitude, species)
data_austria <- data_austria %>% rename(spec = species)
data_austria <- species_uniforming(data_austria, coding = TRUE)
freq <- data_austria %>% group_by(spec) %>% summarise(n = n())
data_austria <- data_austria %>% distinct()
data_austria$ds <- "austria"
## 17 - Portugal  the data ============================================================
data_portugal <- read_sandflies_data("portugal", type = "raw")
data_portugal <- remove_NA_coordinates(data_portugal)
data_portugal <- remove_coordinates_in_sea(data_portugal)
# if there is any sandflies is observed
data_portugal <- data_portugal %>% filter(!is.na(number_of_collected) & number_of_collected > 0)
data_portugal <- data_portugal %>% dplyr::select(latitude, longitude, species)
data_portugal <- data_portugal %>% rename(spec = species)
data_portugal <- species_uniforming(data_portugal, coding = TRUE)
freq <- data_portugal %>% group_by(spec) %>% summarise(n = n())
data_portugal <- data_portugal %>% distinct()
data_portugal$ds <- "portugal"
## 18 - Sicily  the data ============================================================
data_sicily <- read_sandflies_data("sicily", type = "raw")
data_sicily <- remove_NA_coordinates(data_sicily)
data_sicily <- remove_coordinates_in_sea(data_sicily)
# if there is any sandflies is observed
data_sicily <- data_sicily %>% filter(!is.na(number_of_collected) & number_of_collected > 0)
data_sicily <- data_sicily %>% dplyr::select(latitude, longitude, species)
data_sicily <- data_sicily %>% rename(spec = species)
data_sicily <- species_uniforming(data_sicily, coding = TRUE)
freq <- data_sicily %>% group_by(spec) %>% summarise(n = n())
data_sicily <- data_sicily %>% distinct()
data_sicily$ds <- "sicily"
## 19 - Mugla  the data ============================================================
data_mugla <- read_sandflies_data("mugla", type = "raw")
data_mugla <- remove_NA_coordinates(data_mugla)
data_mugla <- remove_coordinates_in_sea(data_mugla)
# if there is any sandflies is observed
data_mugla <- data_mugla %>% filter(!is.na(number_of_collected) & number_of_collected > 0)
data_mugla <- data_mugla %>% dplyr::select(latitude, longitude, species)
data_mugla <- data_mugla %>% rename(spec = species)
data_mugla <- species_uniforming(data_mugla, coding = TRUE)
freq <- data_mugla %>% group_by(spec) %>% summarise(n = n())
data_mugla <- data_mugla %>% distinct()
data_mugla$ds <- "mugla"
## 20 - France  the data ============================================================
data_france <- read_sandflies_data("france", type = "raw")
data_france <- remove_NA_coordinates(data_france)
data_france <- remove_coordinates_in_sea(data_france)
# if there is any sandflies is observed
data_france <- data_france %>% filter(!is.na(number_of_collected) & number_of_collected > 0)
data_france <- data_france %>% dplyr::select(latitude, longitude, species)
data_france <- data_france %>% rename(spec = species)
data_france <- species_uniforming(data_france, coding = TRUE)
freq <- data_france %>% group_by(spec) %>% summarise(n = n())
data_france <- data_france %>% distinct()
data_france$ds <- "france"
## 21 - Bulgaria  the data ============================================================
data_bulgaria <- read_sandflies_data("bulgaria", type = "raw")
data_bulgaria <- remove_NA_coordinates(data_bulgaria)
data_bulgaria <- remove_coordinates_in_sea(data_bulgaria)
# if there is any sandflies is observed
data_bulgaria <- data_bulgaria %>% filter(!is.na(number_of_collected) & number_of_collected > 0)
data_bulgaria <- data_bulgaria %>% dplyr::select(latitude, longitude, species)
data_bulgaria <- data_bulgaria %>% rename(spec = species)
data_bulgaria <- species_uniforming(data_bulgaria, coding = TRUE)
freq <- data_bulgaria %>% group_by(spec) %>% summarise(n = n())
data_bulgaria <- data_bulgaria %>% distinct()
data_bulgaria$ds <- "bulgaria"

## 16 Row bind all the data ============================================================
ds_species <- rbind(data_edenext, data_idalert, data_me1, data_me2, data_me3, data_me4, data_crete, data_cyprus,
  data_israel, data_italy, data_madrid, data_slovenia, data_turkey, data_austria, data_portugal, data_sicily, data_mugla, data_france, data_bulgaria, data_vector)

precision <- 4

colnames(ds_species) <- c("lat", "lon", "spec", "spec_code", "ds")
ds_species$lat <- round(ds_species$lat, precision)
ds_species$lon <- round(ds_species$lon, precision)



# group by lat, lon, and spec
#dd <- ds_species[, c("lat", "lon", "spec")]
#dd <- dd %>% distinct()
#dd <- dd %>% group_by(spec) %>% summarise(n = n())


## ds_species <- ds_species[,c('lat', 'lon', 'spec', 'spec_code')]
ds_species <- ds_species %>% distinct()
ds_species <- ds_species %>% filter(!is.na(spec_code))

# remove spec_code = 18
# ds_species <- ds_species %>% filter(spec_code != 18)

# remove the duplicated rows
#ds_species <- ds_species %>% distinct()
#
#species <- as.matrix(table(ds_species$spec))

#dd <- ds_species
#group by lat, lon, and spec
#dd <- ds_species[, c("lat", "lon", "spec")]
#unique the data
#dd <- dd %>% distinct()
#dd <- dd %>% group_by(spec) %>% summarise(n = n())

# 17 - save the data ============================================================
write_sandflies_data(ds_species, "species")
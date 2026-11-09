# 01 - import libraries ------------------------------------------------------------
library(ggplot2)
library(lubridate)
library(dbplyr)
library(tidyverse)
library(leaflet)
library(dotenv)
load_dot_env(".env")

DATA_VERSION <- Sys.getenv("DATA_VERSION")
RAW_DATA_DIR <- Sys.getenv("RAW_DATA_DIR")
PROCESSED_DATA_DIR <- Sys.getenv("PROCESSED_DATA_DIR")

# 02 - Basic Functions =========================================================
read_sandflies_data <- function(name, type = "raw")
{
  if (type == "raw")
    base_Address <- paste0(RAW_DATA_DIR, DATA_VERSION, "/sandflies/")
  else
    base_Address <- paste0(getwd(), PROCESSED_DATA_DIR, DATA_VERSION, "/sandflies/")

  if (tolower(name) == "edenext")
    file_name <- paste0(base_Address, "EDENext/", "samples.csv")
  else if (tolower(name) == "idalert")
    file_name <- paste0(base_Address, "IDAlert/", "samples.csv")
  else if (tolower(name) == "vector")
    file_name <- paste0(base_Address, "VectorNet/", "samples.csv")
  else if (tolower(name) == 'me1')
    file_name <- paste0(base_Address, "ME1/", "samples.csv")
  else if (tolower(name) == 'me2')
    file_name <- paste0(base_Address, "ME2/", "samples.csv")
  else if (tolower(name) == 'me3')
    file_name <- paste0(base_Address, "ME3/", "samples.csv")
  else if (tolower(name) == 'me4')
    file_name <- paste0(base_Address, "ME4/", "samples.csv")
  else if (tolower(name) == 'meteo')
    file_name <- paste0(base_Address, "meteorology/", "meteo.csv")
  else if (tolower(name) == 'crete') # add this if else structur for the new dataset crete, cyprus, israel, italy, madrid, slovenia, turkey
    file_name <- paste0(base_Address, "Crete/", "samples.csv")
  else if (tolower(name) == 'cyprus')
     file_name <- paste0(base_Address, "Cyprus/", "samples.csv")
  else if (tolower(name) == 'israel')
    file_name <- paste0(base_Address, "Israel/", "samples.csv")
  else if (tolower(name) == 'italy')
    file_name <- paste0(base_Address, "Italy/", "samples.csv")
  else if (tolower(name) == 'madrid')
    file_name <- paste0(base_Address, "Madrid/", "samples.csv")
  else if (tolower(name) == 'slovenia')
    file_name <- paste0(base_Address, "Slovenia/", "samples.csv")
  else if (tolower(name) == 'turkey')
    file_name <- paste0(base_Address, "Turkey/", "samples.csv")
  else if (tolower(name) == 'austria')
    file_name <- paste0(base_Address, "Austria/", "samples.csv")
  else if (tolower(name) == 'bulgaria')
    file_name <- paste0(base_Address, "Bulgaria/", "samples.csv")
  else if (tolower(name) == 'france')
    file_name <- paste0(base_Address, "France/", "samples.csv")
  else if (tolower(name) == 'mugla')
    file_name <- paste0(base_Address, "Mugla/", "samples.csv")
  else if (tolower(name) == 'portugal')
    file_name <- paste0(base_Address, "Portugal/", "samples.csv")
  else if (tolower(name) == 'sicily')
    file_name <- paste0(base_Address, "Sicily/", "samples.csv")
  else if (tolower(name) == 'slovenia')
    file_name <- paste0(base_Address, "Slovenia/", "samples.csv")
  else if (tolower(name) == 'aggregated')
    file_name <- paste0(base_Address, "aggregated/", "samples_origin_species.csv")
  else if (tolower(name) == 'aggregated_species')
    file_name <- paste0(base_Address, "aggregated/", "samples_uniformed_species.csv")
  else if (tolower(name) == 'aggregated_pa')
    file_name <- paste0(base_Address, "aggregated/", "samples_pa.csv")
  else if (tolower(name) == 'aggregated_as')
    file_name <- paste0(base_Address, "aggregated/", "samples_as.csv")
  else if (tolower(name) == 'species')
    file_name <- paste0(base_Address, "species/", "samples.csv")


  data <- read.csv(file_name, header = TRUE, sep = ",")
  print(paste0("The data of ", name, " is loaded. Rows: ", nrow(data), " Columns: ", ncol(data)))
  return(data)
}

write_sandflies_data <- function(data, name)
{
  base_Address <- paste0(getwd(), PROCESSED_DATA_DIR, DATA_VERSION, "/sandflies/")

  if (tolower(name) == "edenext")
    file_name <- paste0(base_Address, "EDENext/", "samples.csv")
  else if (tolower(name) == "idalert")
    file_name <- paste0(base_Address, "IDAlert/", "samples.csv")
  else if (tolower(name) == "vector")
    file_name <- paste0(base_Address, "VectorNet/", "samples.csv")
  else if (tolower(name) == 'me1')
    file_name <- paste0(base_Address, "ME1/", "samples.csv")
  else if (tolower(name) == 'me2')
    file_name <- paste0(base_Address, "ME2/", "samples.csv")
  else if (tolower(name) == 'me3')
    file_name <- paste0(base_Address, "ME3/", "samples.csv")
  else if (tolower(name) == 'me4')
    file_name <- paste0(base_Address, "ME4/", "samples.csv")
  else if (tolower(name) == 'crete')
    file_name <- paste0(base_Address, "Crete/", "samples.csv")
  else if (tolower(name) == 'cyprus')
    file_name <- paste0(base_Address, "Cyprus/", "samples.csv")
  else if (tolower(name) == 'israel')
    file_name <- paste0(base_Address, "Israel/", "samples.csv")
  else if (tolower(name) == 'italy')
    file_name <- paste0(base_Address, "Italy/", "samples.csv")
  else if (tolower(name) == 'madrid')
    file_name <- paste0(base_Address, "Madrid/", "samples.csv")
  else if (tolower(name) == 'slovenia')
    file_name <- paste0(base_Address, "Slovenia/", "samples.csv")
  else if (tolower(name) == 'turkey')
    file_name <- paste0(base_Address, "Turkey/", "samples.csv")
  else if (tolower(name) == 'austria')
    file_name <- paste0(base_Address, "Austria/", "samples.csv")
  else if (tolower(name) == 'bulgaria')
    file_name <- paste0(base_Address, "Bulgaria/", "samples.csv")
  else if (tolower(name) == 'france')
    file_name <- paste0(base_Address, "France/", "samples.csv")
  else if (tolower(name) == 'mugla')
    file_name <- paste0(base_Address, "Mugla/", "samples.csv")
  else if (tolower(name) == 'portugal')
    file_name <- paste0(base_Address, "Portugal/", "samples.csv")
  else if (tolower(name) == 'slovenia')
    file_name <- paste0(base_Address, "Slovenia/", "samples.csv")
  else if (tolower(name) == 'sicily')
    file_name <- paste0(base_Address, "Sicily/", "samples.csv")
  else if (tolower(name) == 'species')
    file_name <- paste0(base_Address, "species/", "samples.csv")
  else if (tolower(name) == 'aggregated')
    file_name <- paste0(base_Address, "aggregated/", "samples_origin_species.csv")
  else if (tolower(name) == 'aggregated_species')
    file_name <- paste0(base_Address, "aggregated/", "samples_uniformed_species.csv")
  else if (tolower(name) == 'aggregated_pa')
    file_name <- paste0(base_Address, "aggregated/", "samples_pa.csv")
  else if (tolower(name) == 'aggregated_as')
    file_name <- paste0(base_Address, "aggregated/", "samples_as.csv")

  dir_path <- dirname(file_name)
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE)
    print(paste0("The directory ", dir_path, " is created."))
  }

  write.csv(data, file_name, row.names = FALSE)
  print(paste0("The data of ", name, " is saved. Rows: ", nrow(data), " Columns: ", ncol(data)))
}

read_morphology_data <- function(name, type = "raw")
{
    if (type == "raw")
      base_Address <- paste0(RAW_DATA_DIR, DATA_VERSION, "/morphology/")
    else
      base_Address <- paste0(getwd(), PROCESSED_DATA_DIR, DATA_VERSION, "/morphology/")

    if (tolower(name) == "elevation")
        file_name <- paste0(base_Address, "elevation.csv")
    else if (tolower(name) == "aspect")
      file_name <- paste0(base_Address, "aspect.csv")
    else if (tolower(name) == 'lc')
        file_name <- paste0(base_Address, "lc.csv")
    else if (tolower(name) == 'slope')
        file_name <- paste0(base_Address, "slope.csv")
    else if (tolower(name) == 'sand')
      file_name <- paste0(base_Address, "sand.csv")
    else if (tolower(name) == 'clay')
      file_name <- paste0(base_Address, "clay.csv")
    else if (tolower(name) == 'morphology')
        file_name <- paste0(base_Address, "morphology.csv")

    data <- read.csv(file_name, header = TRUE, sep = ",")
    print(paste0("The data of ", name, " is loaded. Rows: ", nrow(data), " Columns: ", ncol(data)))
    return(data)
}

write_morphology_data <- function(data, name)
{
    base_Address <- paste0(getwd(), PROCESSED_DATA_DIR, DATA_VERSION, "/morphology/")

    if (tolower(name) == "dem")
        file_name <- paste0(base_Address, "coordinate_morphology_dem.csv")
    else if (tolower(name) == "aspect")
      file_name <- paste0(base_Address, "coordinate_morphology_aspect.csv")
    else if (tolower(name) == "facc")
        file_name <- paste0(base_Address, "coordinate_morphology_facc.csv")
    else if (tolower(name) == 'fdir')
        file_name <- paste0(base_Address, "coordinate_morphology_fdir.csv")
    else if (tolower(name) == 'geology')
        file_name <- paste0(base_Address, "coordinate_morphology_geology_class.csv")
    else if (tolower(name) == 'lc')
        file_name <- paste0(base_Address, "coordinate_morphology_lc.csv")
    else if (tolower(name) == 'slope')
        file_name <- paste0(base_Address, "coordinate_morphology_slope.csv")
    else if (tolower(name) == 'sc01')
        file_name <- paste0(base_Address, "coordinate_morphology_soil_class_horizon_01.csv")
    else if (tolower(name) == 'sc02')
        file_name <- paste0(base_Address, "coordinate_morphology_soil_class_horizon_02.csv")
    else if (tolower(name) == 'sc03')
        file_name <- paste0(base_Address, "coordinate_morphology_soil_class_horizon_03.csv")
    else if (tolower(name) == 'sc04')
        file_name <- paste0(base_Address, "coordinate_morphology_soil_class_horizon_04.csv")
    else if (tolower(name) == 'sc05')
        file_name <- paste0(base_Address, "coordinate_morphology_soil_class_horizon_05.csv")
    else if (tolower(name) == 'sc06')
        file_name <- paste0(base_Address, "coordinate_morphology_soil_class_horizon_06.csv")
    else if (tolower(name) == 'sc')
      file_name <- paste0(base_Address, "sc.csv")
    else if (tolower(name) == 'morphology')
        file_name <- paste0(base_Address, "morphology.csv")

    dir_path <- dirname(file_name)
    if (!dir.exists(dir_path)) {
      dir.create(dir_path, recursive = TRUE)
      print(paste0("The directory ", dir_path, " is created."))
    }

    write.csv(data, file_name, row.names = FALSE)
    print(paste0("The data of ", name, " is saved. Rows: ", nrow(data), " Columns: ", ncol(data)))
}

read_meteorology_data <- function(name, type = "raw")
{
  if (type == "raw")
    base_Address <- paste0(RAW_DATA_DIR, DATA_VERSION, "/meteorology/")
  else
    base_Address <- paste0(getwd(), PROCESSED_DATA_DIR, DATA_VERSION, "/meteorology/")

  if (tolower(name) == "meteo_emo1")  ## Should be removed
    file_name <- paste0(base_Address, "meteo_emo1.csv")
  else if (tolower(name) == "meteo_era5")  ## Should be removed
    file_name <- paste0(base_Address, "meteo_era5.csv")
  else if (tolower(name) == "meteo")
    file_name <- paste0(base_Address, "meteo.csv")
  else if (tolower(name) == "monthly")
    file_name <- paste0(base_Address, "meteo_monthly.csv")
  else if (tolower(name) == "pet")
    file_name <- paste0(base_Address, "pet.csv")
  else if (tolower(name) == "pre")
    file_name <- paste0(base_Address, "pre.csv")
  else if (tolower(name) == "tavg")
    file_name <- paste0(base_Address, "tavg.csv")
  else if (tolower(name) == "tmax")
    file_name <- paste0(base_Address, "tmax.csv")
  else if (tolower(name) == "tmax_era")
    file_name <- paste0(base_Address, "tmax_era.csv")
  else if (tolower(name) == "tmin")
    file_name <- paste0(base_Address, "tmin.csv")
  else if (tolower(name) == "tmin_era")
    file_name <- paste0(base_Address, "tmin_era.csv")
  else if (tolower(name) == "lm_pet")
    file_name <- paste0(base_Address, "LM_pet.csv")
  else if (tolower(name) == "lm_pre")
    file_name <- paste0(base_Address, "LM_pre.csv")
  else if (tolower(name) == "lm_tavg")
    file_name <- paste0(base_Address, "LM_tavg.csv")

  data <- read.csv(file_name, header = TRUE, sep = ",")
  print(paste0("The data of ", name, " is loaded. Rows: ", nrow(data), " Columns: ", ncol(data)))
  return(data)
}

write_meteorology_data <- function(data, name)
{
  base_Address <- paste0(getwd(), PROCESSED_DATA_DIR, DATA_VERSION, "/meteorology/")

  if (tolower(name) == "meteo_emo1") ## Should be removed
    file_name <- paste0(base_Address, "meteo_emo1.csv") ## Should be removed
  else if (tolower(name) == "meteo_era5")
    file_name <- paste0(base_Address, "meteo_era5.csv")
  else if (tolower(name) == "meteo")
    file_name <- paste0(base_Address, "meteo.csv")
  else if (tolower(name) == "monthly")
    file_name <- paste0(base_Address, "meteo_monthly.csv")

  dir_path <- dirname(file_name)
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE)
    print(paste0("The directory ", dir_path, " is created."))
  }

  write.csv(data, file_name, row.names = FALSE)
  print(paste0("The data of ", name, " is saved. Rows: ", nrow(data), " Columns: ", ncol(data)))
}

read_hydrology_data <- function(name, type = "raw")
{
    if (type == "raw")
      base_Address <- paste0(RAW_DATA_DIR, DATA_VERSION, "/hydrology/")
    else
      base_Address <- paste0(getwd(), PROCESSED_DATA_DIR, DATA_VERSION, "/hydrology/")

    if (tolower(name) == "hydrology")
        file_name <- paste0(base_Address, "hydrology.csv")
    else if (tolower(name) == "swc1")
        file_name <- paste0(base_Address, "swc1.csv")
    else if (tolower(name) == "swc2")
        file_name <- paste0(base_Address, "swc2.csv")
    else if (tolower(name) == "swc3")
        file_name <- paste0(base_Address, "swc3.csv")
    else if (tolower(name) == "swc4")
        file_name <- paste0(base_Address, "swc4.csv")
    else if (tolower(name) == "swc5")
        file_name <- paste0(base_Address, "swc5.csv")
    else if (tolower(name) == "swc6")
        file_name <- paste0(base_Address, "swc6.csv")
    else if (tolower(name) == "lm_swc1")
        file_name <- paste0(base_Address, "LM_swc1.csv")
    else if (tolower(name) == "lm_swc2")
        file_name <- paste0(base_Address, "LM_swc2.csv")
    else if (tolower(name) == "lm_swc3")
        file_name <- paste0(base_Address, "LM_swc3.csv")
    else if (tolower(name) == "lm_swc4")
        file_name <- paste0(base_Address, "LM_swc4.csv")
    else if (tolower(name) == "lm_swc5")
        file_name <- paste0(base_Address, "LM_swc5.csv")
    else if (tolower(name) == "lm_swc6")
        file_name <- paste0(base_Address, "LM_swc6.csv")

    data <- read.csv(file_name, header = TRUE, sep = ",")
    print(paste0("The data of ", name, " is loaded. Rows: ", nrow(data), " Columns: ", ncol(data)))
    return(data)
}

write_hydrology_data <- function(data, name)
{
    base_Address <- paste0(getwd(), PROCESSED_DATA_DIR, DATA_VERSION, "/hydrology/")

    if (tolower(name) == "hydrology")
        file_name <- paste0(base_Address, "hydrology.csv")

    dir_path <- dirname(file_name)
    if (!dir.exists(dir_path)) {
      dir.create(dir_path, recursive = TRUE)
      print(paste0("The directory ", dir_path, " is created."))
    }

    write.csv(data, file_name, row.names = FALSE)
    print(paste0("The data of ", name, " is saved. Rows: ", nrow(data), " Columns: ", ncol(data)))
}
read_training_data <- function(type="ns")
{
    base_Address <- paste0(getwd(), PROCESSED_DATA_DIR, DATA_VERSION, "/training/")
    if (tolower(type) == "ws")
        file_name <- paste0(base_Address, "trainingWS.csv")
    else if (tolower(type) == "ns")
        file_name <- paste0(base_Address, "trainingNS.csv")

    data <- read.csv(file_name, header = TRUE, sep = ",")
    print(paste0("The data of training is loaded. Rows: ", nrow(data), " Columns: ", ncol(data)))
    return(data)
}

write_training_data <- function(data, name="training")
{
    base_Address <- paste0(getwd(), PROCESSED_DATA_DIR, DATA_VERSION, "/training/")
    file_name <- paste0(base_Address, name,".csv")

    dir_path <- dirname(file_name)
    if (!dir.exists(dir_path)) {
      dir.create(dir_path, recursive = TRUE)
      print(paste0("The directory ", dir_path, " is created."))
    }
    write.csv(data, file_name, row.names = FALSE)
    print(paste0("The data of training is saved. Rows: ", nrow(data), " Columns: ", ncol(data)))
}

write_coordinates <- function(data, name="coordinates")
{
    base_Address <- paste0(getwd(), PROCESSED_DATA_DIR, DATA_VERSION, "/coordinates/")
    if (tolower(name) == "coordinates_dates")
        file_name <- paste0(base_Address, "coordinates_dates.csv")
    else if (tolower(name) == "coordinates")
        file_name <- paste0(base_Address, "coordinates.csv")

    #file_name <- paste0(base_Address, name,".csv")

    dir_path <- dirname(file_name)
    if (!dir.exists(dir_path)) {
      dir.create(dir_path, recursive = TRUE)
      print(paste0("The directory ", dir_path, " is created."))
    }
    write.csv(data, file_name, row.names = FALSE)
    print(paste0("The data of ", name, " is saved. Rows: ", nrow(data), " Columns: ", ncol(data)))
}

read_coordinates <- function(name="coordinates")
{
  base_Address <- paste0(getwd(), PROCESSED_DATA_DIR, DATA_VERSION, "/coorddates/")
  if (tolower(name) == "coorddate")
    file_name <- paste0(base_Address, "coorddate.csv")
  else if (tolower(name) == "coordinates")
    file_name <- paste0(base_Address, "coordinates.csv")

  #file_name <- paste0(base_Address, name,".csv")

  data <- read.csv(file_name, header = TRUE, sep = ",")
  print(paste0("The data of ", name, " is loaded. Rows: ", nrow(data), " Columns: ", ncol(data)))
  return(data)
}

read_regions_data <- function(){
  path <- "/Volumes/Researches/CHS/CLIMOS/FeData/raw/v3/murcia/regional_coordinates.csv"
  data <- read.csv(path, header = TRUE, sep = ",")
  print(paste0("The data of regions is loaded. Rows: ", nrow(data), " Columns: ", ncol(data)))
  return(data)
}

read_unit_test_data <- function(name)
{
    name <- "data_reg"
    base_Address <- paste0(getwd(), "/resources/data/unit_test/measurements/")
    file_name <- paste0(base_Address, name,".csv")
    data <- read.csv(file_name, header = TRUE, sep = ",")
    print(paste0("The data of ", name, " is loaded. Rows: ", nrow(data), " Columns: ", ncol(data)))
    return(data)
}

get_coordinate_path <- function(){
  base_Address <- paste0(getwd(), PROCESSED_DATA_DIR, DATA_VERSION, "/coordinates/")
  file_name <- paste0(base_Address, "coordinates.csv")
  return (file_name)
}
get_coordinate_dates_path <- function(){
  base_Address <- paste0(getwd(), PROCESSED_DATA_DIR, DATA_VERSION, "/coordinates/")
  file_name <- paste0(base_Address, "coordinates_dates.csv")
  return (file_name)
}
get_morphology_data_dir <- function(){
  base_Address <- paste0(getwd(), PROCESSED_DATA_DIR, DATA_VERSION, "/morphology/")
  return (base_Address)
}
get_meteorology_data_dir <- function(){
  base_Address <- paste0(getwd(), PROCESSED_DATA_DIR, DATA_VERSION, "/meteorology/")
  return (base_Address)
}
get_hydrology_data_dir <- function(){
  base_Address <- paste0(getwd(), PROCESSED_DATA_DIR, DATA_VERSION, "/hydrology/")
  return (base_Address)
}
get_training_data_dir <- function(){
  base_Address <- paste0(getwd(), PROCESSED_DATA_DIR, DATA_VERSION, "/training/")
  return (base_Address)
}
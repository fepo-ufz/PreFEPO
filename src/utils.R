# 01 - import libraries =============================================================
library(leaflet)
library(raster)
library(rnaturalearth)
#library(rgeos)
library(sf)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(lubridate)
library(scales)
library(sf)
library(dplyr)
library(geosphere)
library(countrycode)
library(dotenv)
load_dot_env(".env")

# 02 - Basic Functions =========================================================
RAW_DATA_DIR <- Sys.getenv("RAW_DATA_DIR")
dsn <- paste0(RAW_DATA_DIR, "/landshape/WB_Land_10m.shp")
field <- st_read(dsn)

get_unique_coordinates <- function(data, coords = c("longitude", "latitude")){
  #coordinates <- data.frame(longitude = data$longitude, latitude = data$latitude)
  coordinates <- data %>% dplyr::select(all_of(coords))
  n1 <- nrow(coordinates)
  coordinates <- na.omit(coordinates)
  n2 <- n1 - nrow(coordinates)
  print(paste0("There are ", n2, " rows with NA coordinates."))
  coordinates <- unique(coordinates)
  print(paste0("There are ", nrow(coordinates), " Unique coordinates."))
  return(coordinates)
}

remove_NA_coordinates <- function(data){
  data <- data %>% filter(!is.na(latitude) & !is.na(longitude) & latitude != 0 & longitude != 0)
  return (data)
}

remove_outof_domain <- function (data){
  # lat[31, 54]
  # lon[-10, 42]
  if (all(c("lat", "lon") %in% names(data))){
    coords <- c("lon", "lat")
  }else if (all(c("longitude", "latitude") %in% names(data))){
    coords <- c("longitude", "latitude")
  }else
    stop("The data frame must contain 'lat' and 'lon' or 'latitude' and 'longitude' columns.")

  #spatial domain
  domain <- c(-10, 42, 31, 54)
  idx <- which(data[[coords[1]]] >= domain[1] & data[[coords[1]]] <= domain[2] & data[[coords[2]]] >= domain[3] & data[[coords[2]]] <= domain[4])
  data <- data[idx,]

  # temporal domain
  sdate <- if ("sdate" %in% names(data)) "sdate" else "start_date"
  data[[sdate]] <- as.Date(data[[sdate]], format = "%Y-%m-%d")
  data <- data %>%
    filter(.data[[sdate]] >= as.Date("2000-01-01"))

  return(data)
}

remove_coordinates_in_sea <- function(data){

  if (all(c("lat", "lon") %in% names(data))){
    coords <- c("lon", "lat")
  }else if (all(c("longitude", "latitude") %in% names(data))){
    coords <- c("longitude", "latitude")
  }else
    stop("The data frame must contain 'lat' and 'lon' or 'latitude' and 'longitude' columns.")

  # The latitude and longitude are not in the sea
  coordinates <- get_unique_coordinates(data, coords)
  valid_coordinate <- check_coordinate_in_sea(coordinates, coords = coords)
  #print(valid_coordinate)
  valid_coordinate <- valid_coordinate %>% filter(in_field == TRUE)
  data <- semi_join(data, valid_coordinate, by = coords)
  return (data)
}

check_coordinate_in_sea_old <- function(coordinates){
  coordinates$in_field <- apply(coordinates, 1, function(x) is_in_field(x[1], x[2]))
  print(paste0("There are ", sum(is.na(coordinates$in_field) | !coordinates$in_field), " coordinates which are not the filed."))
  return(coordinates)
}

check_coordinate_in_sea <- function(coordinates, coords = c("longitude", "latitude")){
  field <- st_read(dsn)

  if (!all(coords %in% names(coordinates))) {
    stop("The coordinates data frame must contain 'longitude' and 'latitude' columns.")
  }

  points_sf <- st_as_sf(coordinates, coords = coords, crs = st_crs(field))
  joined <- st_join(points_sf, field, join = st_within, left = TRUE)
  coordinates$in_field <- !is.na(joined[[1]])  # Assumes the first column in 'field' is non-NA if contained

  num_not_in_field <- sum(is.na(coordinates$in_field) | !coordinates$in_field)
  message("There are ", num_not_in_field, " coordinates which are not in the field.")

  return(coordinates)
}

check_coordinates_in_domain <- function(coordinates){

  coordinates <- get_unique_coordinates(data)
  coordinates$in_domain <- apply(coordinates, 1, function(x) in_domain(x[1], x[2], domain))
  print(paste0("There are ", sum(is.na(coordinates$in_domain) | !coordinates$in_domain), " coordinates which are not in the domain."))
  return(coordinates)
}

is_in_field <- function(longitude, latitude) {
  point <- st_point(c(longitude, latitude))
  is_inside <- st_contains(field, point)
  return (sum(unlist(is_inside)) > 0 )
}

expand_date <- function(data){
  data$expid <- seq.int(nrow(data))
  data$sdate <- as.Date(data$sdate)
  data$edate <- as.Date(data$edate)
  data$duration <- as.numeric(data$edate - data$sdate, units = "days")
  data <- data[rep(row.names(data), data$duration),]
  data <- data %>%
    group_by(expid) %>%
    mutate(sdate = sdate + (row_number() - 1),
       expanded = ifelse(row_number() == 1, FALSE, TRUE)) %>%
    ungroup() %>%
    mutate(edate = sdate + 1) %>%
    dplyr::select(-duration)

  return(data)
}

clean_dataset <- function(data){

  precise <- 4
  # 01 - Uniforming format of the date columns ----------------------------------------------------------
  data$start_date <- as.Date(data$start_date)
  data$end_date <- as.Date(data$end_date)

  # If the start date is greater than the end date, we need to swap them
  data <- data %>% mutate(start_date = pmin(start_date, end_date), end_date = pmax(start_date, end_date) )

  # If the latitude and longitude are not in the correct range, we need to fix them
  data <- data %>%  mutate(
    latitude = if_else(latitude < -90 | latitude > 90, latitude / 1000, latitude),
    longitude = if_else(longitude < -180 | longitude > 180, longitude / 1000, longitude),
  )

  # latitude and longitude should be rounded to 4 decimal places
  data$latitude <- round(data$latitude, precise)
  data$longitude <- round(data$longitude, precise)

  # If the start date is equal to the end date, we need to add one day to the end date, because the duration should be at least one day
  data <- data %>% mutate(end_date = if_else(start_date == end_date, end_date + 1, end_date))

  # Uniforming the sex of the sandflies
  data$sex <- ifelse(grepl("F|M", data$sex), data$sex, "Unknown")
  data$sex <- ifelse(grepl("M/F", data$sex), "Unknown", data$sex)

  # The valid collection methods are LT, SP, and HC, and some other methods are considered as OTH
  data$collecting_methods <- ifelse(grepl("CDC|CO2|LTCO2", data$collecting_methods), "LT", data$collecting_methods)
  data$collecting_methods <- ifelse(grepl("ST|LST", data$collecting_methods), "SP", data$collecting_methods)

  print("Based on the below table we could not detect the collecting methods, thus we set them as OTH")
  print(table(data$collecting_methods))

  data$collecting_methods <- ifelse(grepl("LT|SP|HC", data$collecting_methods), data$collecting_methods, "OTH")
  print(table(data$collecting_methods))

  # 02 - Remove the rows that have NA in essential columns ------------------------------------------------
  keys <- c("latitude", "longitude", "collecting_methods", "start_date", "number_of_collected")
  data <- data %>% drop_na(all_of(keys))

  # if collecting method is LT, and trap_number is NaN, it should be removed,
  data <- data %>% filter(!(collecting_methods == "LT" & (is.na(number_of_trap) | number_of_trap == 0)))

  # 03 - Uniforming the species names ---------------------------------------------------------------------------------
  data <- uniform_species_names(data)

  # report which species are set as others
  print("The species that are set as others:")
  report <- data %>% filter(species_uniform == "others") %>% dplyr::select(species)
  print(table(report$species))
  print("The species that are not set as others:")
  data$species <- as.character(data$species_uniform)
  print(table(data$species))
  #data <- data %>% filter(!(species %in% 'others'))

  # 04 - Remove zero values in the number_of_collected column in active months ----------------------------------------
  active_months <- c(5, 6, 7, 8, 9, 10)
  data$smonth <- as.integer(month(data$start_date))
  zero_active <- data %>% filter((smonth %in% active_months & number_of_collected == 0))
  print(paste0("There are ", nrow(zero_active), " rows with zero values in the number_of_collected column in active months."))
  data <- data %>% filter(!(smonth %in% active_months & number_of_collected == 0))

  # 05- Remove wierd situations --------------------------------------------------------------------------------------
  # In some case we have duration time for example whole year, which is not possible
  data <- data %>%
    mutate(duration = as.numeric(as.Date(end_date) - as.Date(start_date), units = "days")) %>%
    filter(duration <= 10)

  # In some case we have number_of_trap wierd values such as 560, 380, etc
  data <- data %>% filter(!(collecting_methods == "LT" & number_of_trap > 20 ))

  # 06 - Duplicate rows ---------------------------------------------------------------------------------------

  grp_key <- c("latitude", "longitude", "collecting_methods",
               "start_date", "end_date", "number_of_trap", "sex", "species") # required columns
  grp_count <- data %>% group_by_at(grp_key) %>% summarise(n = n()) %>% filter(n > 1)
  print(paste0("The number of duplicated rows: ", abs(nrow(data) - nrow(grp_count))))
  data <- data %>% group_by_at(grp_key) %>% summarise(number_of_collected = max(number_of_collected)) %>% ungroup()

 return(data)
}

round_coordinates <- function(data, digits = 4) {
  coord_cols <- c("latitude", "longitude", "lat", "lon")

  # Only keep column names that exist in the data
  cols_to_round <- intersect(coord_cols, names(data))

  # Round them
  for (col in cols_to_round) {
    data[[col]] <- round(data[[col]], digits)
  }

  return(data)
}

well_form_dataset <- function(data){
  data <- data %>% filter(toupper(collecting_methods) == "LT")
  data <- remove_NA_coordinates(data)
  data <- remove_coordinates_in_sea(data)
  data <- data %>%
    mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap == 0) & number_of_collected == 0), 1, number_of_trap))
  data <- data %>% filter(!is.na(number_of_trap) & number_of_trap != 0)
  data <- data %>% filter(!is.na(number_of_collected))
  data <- data %>%
    group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
    summarise(ns = sum(number_of_collected, na.rm = TRUE))
  data <- data %>%
    group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
    summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
              nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
              nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
              nst = sum(ns, na.rm = TRUE))
  data <- data  %>% filter(!is.na(nst))
  colnames(data) <- c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
  data$sdate <- as.Date(data$sdate)
  data$edate <- as.Date(data$edate)
  data$duration <- as.numeric(data$edate - data$sdate, units = "days")
  data$dst <- data$nst/data$nt/data$duration
  return(data)
}

annual_summarize <- function(data){
  data$syear <- year(data$sdate)
  data$syear <- as.integer(data$syear)
  data <- data %>% group_by(lat, lon, syear, spec) %>% summarise(n = n(), min= min(dst), max = max(dst), sum = sum(dst))
  return(data)
}

uniform_species_names <- function(df, name_column='species', postfix='_uniform') {
  # Ensure the input data frame contains the specified column
  if (!name_column %in% names(df)) {
    stop(paste("The data frame does not contain the column:", name_column))
  }

  new_column <- paste0(name_column, postfix)
  df[[new_column]] <- df[[name_column]] %>% tolower() %>%
    gsub("[_.-]", " ", .) %>%
    gsub("\\s+", " ", ., perl = TRUE) %>%
    gsub("[^a-zA-Z\\s]", "", ., perl = TRUE) %>% trimws()


  df <- df %>%
    mutate(
      !!new_column := case_when(
        grepl("alexandri", tolower(.data[[new_column]])) ~ "alexandri",
        grepl("ariasi", tolower(.data[[new_column]])) ~ "ariasi",
        grepl("balcanicus", tolower(.data[[new_column]])) ~ "balcanicus",
        grepl("halepensis", tolower(.data[[new_column]])) ~ "halepensis",
        grepl("kandelakii", tolower(.data[[new_column]])) ~ "kandelakii",
        grepl("langeroni", tolower(.data[[new_column]])) ~ "langeroni",
        grepl("major\\s*s\\s*l", tolower(.data[[new_column]])) ~ "major_sl",
        grepl("major\\s*s\\s*s", tolower(.data[[new_column]])) ~ "major_ss",
        grepl("neglectus", tolower(.data[[new_column]])) ~ "neglectus",
        grepl("\\bmasci?t{1,2}i{1,2}\\b", tolower(.data[[new_column]])) ~ "mascittii",
        grepl("papatasi", tolower(.data[[new_column]])) ~ "papatasi",
        grepl("perfiliewi", tolower(.data[[new_column]])) ~ "perfiliewi",
        grepl("perniciosus", tolower(.data[[new_column]])) ~ "perniciosus",
        grepl("sergenti", tolower(.data[[new_column]])) ~ "sergenti",
        grepl("similis", tolower(.data[[new_column]])) ~ "similis",
        grepl("tobbi", tolower(.data[[new_column]])) ~ "tobbi",
        TRUE ~ "others"  # Default category
      )
    )

  return(df)
}

get_species_presence <- function(){
  path <- "/Volumes/Researches/CHS/CLIMOS/FeData/raw/Eduardo/species_presence.csv"
  data <- read.csv(path, header = TRUE, sep = ",")
  data <- data %>% dplyr::select(-rowid_, -Parasite_vectors)
  species_names <- colnames(data)[6:21]
  species_names <- as.data.frame(species_names)
  species_names <- uniform_species_names(species_names, name_column = 'species_names')
  colnames(data)[6:21] <- species_names$species_names
  data <- data[, 1:21]
  # I should have a dataset such that the name of soecies

  path <- "/Volumes/Researches/CHS/CLIMOS/FeData/raw/Eduardo/spatial_presence.csv"
  write.csv(data, path, row.names = FALSE)

}

species_presence <- function(data, name_column='species'){
  spatial_presence <- read.csv("/Volumes/Researches/CHS/CLIMOS/FeData/raw/Eduardo/spatial_presence.csv")
  dd <- spatial_presence %>% filter(str_length(mappingcode) > 5)
  valid_species <- colnames(spatial_presence)[6:21]

  distance_matrix <- distm(
    data[, c("longitude", "latitude")],
    spatial_presence[, c("longitude", "latitude")],
    fun = distHaversine       # Haversine distance
  )
  min_indices <- apply(distance_matrix, 1, which.min)
  query_species <- data[[name_column]]

  valid_query <- match(query_species, valid_species, nomatch = 0)
  sub_spatial_presence <- spatial_presence[, valid_species]
  valid_flags <- valid_query > 0
  vs <- numeric(length(min_indices))
  vs[valid_flags] <- sub_spatial_presence[cbind(min_indices[valid_flags], valid_query[valid_flags])]
  vs <- vs > 0
  data$species_presence <- vs
  return (data)
}

get_region_code <- function(df){
  data <- df
  data <- get_nuts_name(data)
  data <- get_gaul_name(data)
  data$region_code <- ifelse(!is.na(data$NUTS_ID), data$NUTS_ID, data$gaul_code)
  data <- data %>% dplyr::select(-c("NUTS_ID", "gaul_code"))
  return(data)
}

get_nuts_name <- function(df) {

  # Check if required columns are present
  if (all(c("lat", "lon") %in% names(df)))
    coords <- c("lon", "lat")
  else if (all(c("longitude", "latitude") %in% names(df)))
    coords <- c("longitude", "latitude")
  else
    stop("The data frame must contain 'lat' and 'lon' or 'latitude' and 'longitude' columns.")

  #country_mapping <- data.frame(
  #  CNTR_CODE = c(
  #    "AT", "BE", "BG", "CY", "CZ", "DE", "DK", "EE", "EL", "ES", "FI", "FR", "HR", "HU", "IE", "IT", "LT",
  #    "LU", "LV", "MT", "NL", "PL", "PT", "RO", "SE", "SI", "SK"
  #  ),
  #  Country_Name = c(
  #    "Austria", "Belgium", "Bulgaria", "Cyprus", "Czechia", "Germany", "Denmark", "Estonia", "Greece",
  #    "Spain", "Finland", "France", "Croatia", "Hungary", "Ireland", "Italy", "Lithuania", "Luxembourg",
  #    "Latvia", "Malta", "Netherlands", "Poland", "Portugal", "Romania", "Sweden", "Slovenia", "Slovakia"
  #  )
  #)

  nuts3_shapefile <- paste0(RAW_DATA_DIR, "/NUTS3/2024/ref-nuts-2024-01m.shp/NUTS_RG_01M_2024_4326_LEVL_3.shp/NUTS_RG_01M_2024_4326_LEVL_3.shp")
  nuts3_data <- st_read(nuts3_shapefile)
  nuts3_data <- st_transform(nuts3_data, crs = 4326)
  df <- df %>%
    st_as_sf(coords = coords, crs = 4326, remove = FALSE)
  df <- st_join(df, nuts3_data, join = st_within, left = TRUE)

  irrelevant_features <- c("LEVL_CODE", "CNTR_CODE", "NAME_LATN", "MOUNT_TYPE", "URBN_TYPE", "COAST_TYPE", "geometry", "NUTS_NAME")
  df <- df %>% dplyr::select(-one_of(irrelevant_features))
  df <- st_set_geometry(df, NULL)
  return(df)

}

get_gaul_name <- function(df){

  # All coordinate use this templare
  # country name + G + 1/2 + Gaul code

  if (all(c("lat", "lon") %in% names(df))) {
    dim <- c("lon", "lat")
  } else if (all(c("latitude", "longitude") %in% names(df))) {
    dim <- c("longitude", "latitude")
  } else {
    stop("The data frame must contain either 'lat' and 'lon' or 'latitude' and 'longitude' columns.")
  }

  gaul_shapefile <- paste0(RAW_DATA_DIR, "/GAUL/2014/g2015_2014_2.shx")

  sf_use_s2(FALSE)
  gaul_data <- st_read(gaul_shapefile)
  gaul_data <- st_set_crs(gaul_data, 3857)
  #gaul_data <- st_set_crs(gaul_data, 4326)
  #gaul_data <- st_make_valid(gaul_data)
  #st_write(gaul_data, corrected_shapefile)
  #invalid_after_repair <- st_is_valid(gaul_data)
  #table(invalid_after_repair)


  coordinates <- df %>%
    st_as_sf(coords = dim, crs = 3857, remove = FALSE)
  coordinates <- st_join(coordinates, gaul_data, join = st_within, left = TRUE)

  country_names <- coordinates$ADM0_NAME
  country_codes <- countrycode(sourcevar = country_names, origin = "country.name", destination = "iso2c")
  coordinates$ccode <- country_codes
  coordinates$gaul_code1 <- paste0(coordinates$ccode, "G1", as.integer(coordinates$ADM1_CODE))
  coordinates$gaul_code2 <- paste0(coordinates$ccode, "G2", as.integer(coordinates$ADM2_CODE))

  df$gaul_code <- ifelse(coordinates$ccode == "MA", coordinates$gaul_code2, coordinates$gaul_code1)

  return(df)

}

# 03 - Charts and Graphs ==============================================================
# Define the plotting function
plot_importance_feature <- function(data, title , top = 10){
  ord <- order(data$weight, decreasing = TRUE)
  data <- data[ord, ]
  data <- data[1:top, ]

  plt <- ggplot(data, aes(x = weight, y = reorder(name, weight), fill = weight)) +
    geom_bar(stat = "identity") +
    labs(title = "Importance of Factors", x = "Weight", y = "Name") +
    scale_fill_gradient(low = theme_color_4, high = theme_color_5) +  # Use theme_color_4 and theme_color_5 from style.R
    ggtitle(title) +
    theme_classic() +
    theme(axis.text.x = element_text(angle = 0, hjust = 0.5))

  return(plt)
}

plot_sandflies_density <- function(data, title){
  # plot ggplot such that histogram of sandflies density
  plt <- ggplot(data, aes(x = dst)) +
    geom_histogram(binwidth = 0.1) +
    labs(title = "Sandflies Density", x = "Density", y = "Frequency") +
    ggtitle(title) +
    theme_classic() +
    scale_x_continuous(breaks = 1:8)
  return(plt)
}

plot_sandflies_density_month <- function(data, title){
  data[, "sdate"] <- as.Date(data[, "sdate"])
  data[, "month"] <- month(data[, "sdate"])
  data <- data %>% group_by(month) %>% summarise(dst = sum(dst))
  all_months <- tibble(month = factor(1:12, labels = month.abb[1:12]), dst = 0)
  all_months$dst[data$month] <- data$dst

  plt <- ggplot(all_months, aes(x = month, y = dst)) +
    geom_bar(stat = "identity") +
    labs(title = "Sandflies Density", x = "Month", y = "Density") +
    ggtitle(title) +
    theme_classic() +
    theme(axis.text.x = element_text(angle = 0, hjust = 0.5)) +
    scale_x_discrete(labels = month.abb[1:12])  # Add month names to x-axis

  return(plt)
}


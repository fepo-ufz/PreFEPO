# 01 - import libraries =============================================================
library(lubridate)
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

#1 Select recods with light trap collection method (LT & CO2, CDC)
#2 Remove records with Coordinates = NA
#3 Remove records with Coordinate is the sea
#4 Remove records with start_date > end_date
#5 Remove record number of traps is 0 while number of sandflies is not 0
#6 remove recors with number_of_collected is nan
#7 Aggeggate based on, species, and Bioptope, and have a single number of sandflies per record
#8 Select the columns that we need
#9 Append the data to the final dataset

# 03 - Ednext dataset ===============================================================

data_edenext <- read_sandflies_data(name = "edenext", type = "processed")
sub_data_edenext <- data_edenext %>% filter(toupper(collecting_methods) == "LT")
sub_data_edenext <- remove_NA_coordinates(sub_data_edenext)
sub_data_edenext <- remove_coordinates_in_sea(sub_data_edenext)

# replace number of traps with 1 if it is NA or 0 while number_of_collected is 0
sub_data_edenext <- sub_data_edenext %>%
  mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap == 0) & number_of_collected == 0), 1, number_of_trap))

sub_data_edenext <- sub_data_edenext %>% filter(!is.na(number_of_trap) & number_of_trap != 0)
sub_data_edenext <- sub_data_edenext %>% filter(!is.na(number_of_collected))

sub_data_edenext <- sub_data_edenext %>%
  group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
  summarise(ns = sum(number_of_collected, na.rm = TRUE))

sub_data_edenext <- sub_data_edenext %>%
  group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

## 03.7 The number of sandflies should not be NA, but zero is ok
# The number of sandflies is not NAn
sub_data_edenext <- sub_data_edenext  %>% filter(!is.na(nst))

## 03.8 - Select the columns that we need
#sub_data_edenext <- sub_data_edenext %>% select(latitude, longitude, start_date, end_date, number_of_trap, nsm, nsf, nst)
colnames(sub_data_edenext) <- c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
sub_data_edenext$ds <- "edenext"

# 04 - IDAlert dataset ===============================================================
data_idalert <- read_sandflies_data(name = "idalert", type = "processed")
#sub_data_idalert <- data_idalert %>% filter(grepl("co2", tolower(data_idalert$collecting_methods)))
sub_data_idalert <- data_idalert %>% filter(toupper(collecting_methods) == "LT")
sub_data_idalert <- remove_NA_coordinates(sub_data_idalert)
sub_data_idalert <- remove_coordinates_in_sea(sub_data_idalert)
sub_data_idalert <- sub_data_idalert %>%
  mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap == 0) & number_of_collected == 0), 1, number_of_trap))

sub_data_idalert <- sub_data_idalert %>% filter(!is.na(number_of_trap) & number_of_trap != 0)
sub_data_idalert <- sub_data_idalert %>% filter(!is.na(number_of_collected))

sub_data_idalert <- sub_data_idalert %>%
  group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
  summarise(ns = sum(number_of_collected, na.rm = TRUE))

sub_data_idalert <- sub_data_idalert %>%
  group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

## 03.7 The number of sandflies should not be NA, but zero is ok
# The number of sandflies is not NAn
sub_data_idalert <- sub_data_idalert  %>% filter(!is.na(nst))

## 03.8 - Select the columns that we need
#sub_data_edenext <- sub_data_edenext %>% select(latitude, longitude, start_date, end_date, number_of_trap, nsm, nsf, nst)
colnames(sub_data_idalert) <- c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
sub_data_idalert$ds <- "idalert"

# 05 - ME1 the data ===============================================================
data_me1 <- read_sandflies_data("ME1", type = "processed")

## 05.1 - Select recods with light trap collection method
sub_data_me1 <- data_me1 %>% filter(collecting_methods == "LT")
sub_data_me1 <- remove_NA_coordinates(sub_data_me1)
sub_data_me1 <- remove_coordinates_in_sea(sub_data_me1)

# replace number of traps with 1 if it is NA or 0 while number_of_collected is 0
sub_data_me1 <- sub_data_me1 %>%
  mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap == 0) & number_of_collected == 0), 1, number_of_trap))

## 05.2 - Remove record number of traps is 0
sub_data_me1 <- sub_data_me1 %>% filter(!is.na(number_of_trap) & number_of_trap != 0)

## 08.6 - remove records with number_of_collected is nan
sub_data_me1 <- sub_data_me1 %>% filter(!is.na(number_of_collected))

## 06.6 Aggeggate
# In this dataset we have the column for total number of sandflies
sub_data_me1 <- sub_data_me1 %>%
  group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
  summarise(ns = sum(number_of_collected, na.rm = TRUE))

sub_data_me1 <- sub_data_me1 %>%
  group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

## 06.7 The number of sandflies should not be NA, but zero is ok
# The number of sandflies is not NA
sub_data_me1 <- sub_data_me1 %>% filter(!is.na(nst))

## 06.8 - Select the columns that we need
#sub_data_me1 <- sub_data_me1 %>% select(latitude, longitude, start_date, end_date, number_of_trap, nsm, nsf, nst)
colnames(sub_data_me1) <-c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
sub_data_me1$ds <- "ME1"
# 06 - ME2 the data ===============================================================
data_me2 <- read_sandflies_data("ME2", type = "processed")
## 06.1 - Select recods with light trap collection method
sub_data_me2 <- data_me2 %>% filter(collecting_methods == "LT")
sub_data_me2 <- remove_NA_coordinates(sub_data_me2)
sub_data_me2 <- remove_coordinates_in_sea(sub_data_me2)

# replace number of traps with 1 if it is NA or 0 while number_of_collected is 0
sub_data_me2 <- sub_data_me2 %>%
  mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap == 0) & number_of_collected == 0), 1, number_of_trap))

## 06.2 - Remove record number of traps is 0
sub_data_me2 <- sub_data_me2 %>% filter(!is.na(number_of_trap) & number_of_trap != 0)

## 06.3 - remove records with number_of_collected is nan
sub_data_me2 <- sub_data_me2 %>% filter(!is.na(number_of_collected))

## 06.4 if sex is no, it is not reliable, we should remove it
#sub_data_me2 <- sub_data_me2 %>% filter(tolower(sex) != "no")

## 06.5 Aggeggate
# In this dataset we have the column for total number of sandflies
sub_data_me2 <- sub_data_me2 %>%
  group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
  summarise(ns = sum(number_of_collected, na.rm = TRUE))

sub_data_me2 <- sub_data_me2 %>%
  group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

## 06.6 The number of sandflies should not be NA, but zero is ok
# The number of sandflies is not NA
sub_data_me2 <- sub_data_me2 %>% filter(!is.na(nst))

## 06.8 - Select the columns that we need
#sub_data_me1 <- sub_data_me1 %>% select(latitude, longitude, start_date, end_date, number_of_trap, nsm, nsf, nst)
colnames(sub_data_me2) <- c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
sub_data_me2$ds <- "ME2"

# 07 - ME3 the data ===============================================================
data_me3 <- read_sandflies_data("ME3", type = "processed")
## 07.1 - Select recods with light trap collection method
sub_data_me3 <- data_me3 %>% filter(toupper(collecting_methods) == "LT")
sub_data_me3 <- remove_NA_coordinates(sub_data_me3)
sub_data_me3 <- remove_coordinates_in_sea(sub_data_me3)

# replace number of traps with 1 if it is NA or 0 while number_of_collected is 0
sub_data_me3 <- sub_data_me3 %>%
  mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap == 0) & number_of_collected == 0), 1, number_of_trap))

## 07.2 - Remove record number of traps is 0
sub_data_me3 <- sub_data_me3 %>% filter(!is.na(number_of_trap) & number_of_trap != 0)

## 07.3 - remove records with number_of_collected is nan
sub_data_me3 <- sub_data_me3 %>% filter(!is.na(number_of_collected))

sub_data_me3 <- sub_data_me3 %>%
  group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
  summarise(ns = sum(number_of_collected, na.rm = TRUE))

sub_data_me3 <- sub_data_me3 %>%
  group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

## 06.6 The number of sandflies should not be NA, but zero is ok
# The number of sandflies is not NA
sub_data_me3 <- sub_data_me3 %>% filter(!is.na(nst))

## 06.8 - Select the columns that we need
#sub_data_me1 <- sub_data_me1 %>% select(latitude, longitude, start_date, end_date, number_of_trap, nsm, nsf, nst)
colnames(sub_data_me3) <- c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
sub_data_me3$ds <- "ME3"


# 07 - ME4 the data ===============================================================
data_me4 <- read_sandflies_data("ME4", type = "processed")
## 07.1 - Select recods with light trap collection method
sub_data_me4 <- data_me4 %>% filter(toupper(collecting_methods) == "LT")
sub_data_me4 <- remove_NA_coordinates(sub_data_me4)
sub_data_me4 <- remove_coordinates_in_sea(sub_data_me4)

# replace number of traps with 1 if it is NA or 0 while number_of_collected is 0
sub_data_me4 <- sub_data_me4 %>%
  mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap == 0) & number_of_collected == 0), 1, number_of_trap))

## 07.2 - Remove record number of traps is 0
sub_data_me4 <- sub_data_me4 %>% filter(!is.na(number_of_trap) & number_of_trap != 0)

## 07.3 - remove records with number_of_collected is nan
sub_data_me4 <- sub_data_me4 %>% filter(!is.na(number_of_collected))

sub_data_me4 <- sub_data_me4 %>%
  group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
  summarise(ns = sum(number_of_collected, na.rm = TRUE))

sub_data_me4 <- sub_data_me4 %>%
  group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

## 06.6 The number of sandflies should not be NA, but zero is ok
# The number of sandflies is not NA
sub_data_me4 <- sub_data_me4 %>% filter(!is.na(nst))

## 06.8 - Select the columns that we need
#sub_data_me1 <- sub_data_me1 %>% select(latitude, longitude, start_date, end_date, number_of_trap, nsm, nsf, nst)
colnames(sub_data_me4) <- c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
sub_data_me4$ds <- "ME4"
## 08 - VectorNet  the data ============================================================
data_vector <- read_sandflies_data("vector", type = "processed")

sub_data_vector <- data_vector %>% filter(toupper(collecting_methods) == "LT" )
sub_data_vector <- remove_NA_coordinates(sub_data_vector)
sub_data_vector <- remove_coordinates_in_sea(sub_data_vector)

# replace number of traps with 1 if it is NA or less than 1 while number_of_collected is 0
sub_data_vector <- sub_data_vector %>%
  mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap < 1) & number_of_collected == 0), 1, number_of_trap))

## 08.2 - Remove record number of traps is 0
sub_data_vector <- sub_data_vector %>% filter(!is.na(number_of_trap) & number_of_trap != 0)

## 08.3 - remove records with number_of_collected is nan
sub_data_vector <- sub_data_vector %>% filter(!is.na(number_of_collected))

sub_data_vector <- sub_data_vector %>%
  group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
  summarise(ns = sum(number_of_collected, na.rm = TRUE))

sub_data_vector <- sub_data_vector %>%
  group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

## 08.4 The number of sandflies should not be NA, but zero is ok
# The number of sandflies is not NA
sub_data_vector <- sub_data_vector %>% filter(!is.na(nst))

## 08.5 - Select the columns that we need
#sub_data_vector <- sub_data_vector %>% select(latitude, longitude, start_date, end_date, number_of_trap, nsm, nsf, nst)
colnames(sub_data_vector) <- c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
sub_data_vector$ds <- "vector"
## 09 - Crete  the data ============================================================
data_crete <- read_sandflies_data("crete", type = "processed")

sub_data_crete <- data_crete %>% filter(toupper(collecting_methods) == "LT" )
sub_data_crete <- remove_NA_coordinates(sub_data_crete)
sub_data_crete <- remove_coordinates_in_sea(sub_data_crete)

# replace number of traps with 1 if it is NA or less than 1 while number_of_collected is 0
sub_data_crete <- sub_data_crete %>%
  mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap < 1) & number_of_collected == 0), 1, number_of_trap))

## 08.2 - Remove record number of traps is 0
sub_data_crete <- sub_data_crete %>% filter(!is.na(number_of_trap) & number_of_trap != 0)

## 08.3 - remove records with number_of_collected is nan
sub_data_crete <- sub_data_crete %>% filter(!is.na(number_of_collected))

sub_data_crete <- sub_data_crete %>%
  group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
  summarise(ns = sum(number_of_collected, na.rm = TRUE))

sub_data_crete <- sub_data_crete %>%
  group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

## 08.4 The number of sandflies should not be NA, but zero is ok
# The number of sandflies is not NA
sub_data_crete <- sub_data_crete %>% filter(!is.na(nst))

## 08.5 - Select the columns that we need
#sub_data_vector <- sub_data_vector %>% select(latitude, longitude, start_date, end_date, number_of_trap, nsm, nsf, nst)
colnames(sub_data_crete) <- c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
sub_data_crete$ds <- "crete"
## 09 - Cyprus  the data ============================================================
data_cyprus <- read_sandflies_data("cyprus", type = "processed")

sub_data_cyprus <- data_cyprus %>% filter(toupper(collecting_methods) == "LT" )
sub_data_cyprus <- remove_NA_coordinates(sub_data_cyprus)
sub_data_cyprus <- remove_coordinates_in_sea(sub_data_cyprus)

# replace number of traps with 1 if it is NA or less than 1 while number_of_collected is 0
sub_data_cyprus <- sub_data_cyprus %>%
  mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap < 1) & number_of_collected == 0), 1, number_of_trap))

## 08.2 - Remove record number of traps is 0
sub_data_cyprus <- sub_data_cyprus %>% filter(!is.na(number_of_trap) & number_of_trap != 0)

## 08.3 - remove records with number_of_collected is nan
sub_data_cyprus <- sub_data_cyprus %>% filter(!is.na(number_of_collected))

sub_data_cyprus <- sub_data_cyprus %>%
  group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
  summarise(ns = sum(number_of_collected, na.rm = TRUE))

sub_data_cyprus <- sub_data_cyprus %>%
  group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

## 08.4 The number of sandflies should not be NA, but zero is ok
# The number of sandflies is not NA
sub_data_cyprus <- sub_data_cyprus %>% filter(!is.na(nst))

## 08.5 - Select the columns that we need
#sub_data_vector <- sub_data_vector %>% select(latitude, longitude, start_date, end_date, number_of_trap, nsm, nsf, nst)
colnames(sub_data_cyprus) <- c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
sub_data_cyprus$ds <- "cyprus"
## 10 - Israel  the data ============================================================
data_israel <- read_sandflies_data("israel", type = "processed")

sub_data_israel <- data_israel %>% filter(toupper(collecting_methods) == "LT" )
sub_data_israel <- remove_NA_coordinates(sub_data_israel)
sub_data_israel <- remove_coordinates_in_sea(sub_data_israel)

# replace number of traps with 1 if it is NA or less than 1 while number_of_collected is 0
sub_data_israel <- sub_data_israel %>%
  mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap < 1) & number_of_collected == 0), 1, number_of_trap))

## 08.2 - Remove record number of traps is 0
sub_data_israel <- sub_data_israel %>% filter(!is.na(number_of_trap) & number_of_trap != 0)

## 08.3 - remove records with number_of_collected is nan
sub_data_israel <- sub_data_israel %>% filter(!is.na(number_of_collected))

sub_data_israel <- sub_data_israel %>%
  group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
  summarise(ns = sum(number_of_collected, na.rm = TRUE))

sub_data_israel <- sub_data_israel %>%
  group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

## 08.4 The number of sandflies should not be NA, but zero is ok
# The number of sandflies is not NA
sub_data_israel <- sub_data_israel %>% filter(!is.na(nst))

## 08.5 - Select the columns that we need
#sub_data_vector <- sub_data_vector %>% select(latitude, longitude, start_date, end_date, number_of_trap, nsm, nsf, nst)
colnames(sub_data_israel) <- c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
sub_data_israel$ds <- "israel"
## 10 - Italy  the data ============================================================
data_italy <- read_sandflies_data("italy", type = "processed")

sub_data_italy <- data_italy %>% filter(toupper(collecting_methods) == "LT" )
sub_data_italy <- remove_NA_coordinates(sub_data_italy)
sub_data_italy <- remove_coordinates_in_sea(sub_data_italy)

# replace number of traps with 1 if it is NA or less than 1 while number_of_collected is 0
sub_data_italy <- sub_data_italy %>%
  mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap < 1) & number_of_collected == 0), 1, number_of_trap))

## 08.2 - Remove record number of traps is 0
sub_data_italy <- sub_data_italy %>% filter(!is.na(number_of_trap) & number_of_trap != 0)

## 08.3 - remove records with number_of_collected is nan
sub_data_italy <- sub_data_italy %>% filter(!is.na(number_of_collected))

sub_data_italy <- sub_data_italy %>%
  group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
  summarise(ns = sum(number_of_collected, na.rm = TRUE))


sub_data_italy <- sub_data_italy %>%
  group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

## 08.4 The number of sandflies should not be NA, but zero is ok
# The number of sandflies is not NA
sub_data_italy <- sub_data_italy %>% filter(!is.na(nst))

## 08.5 - Select the columns that we need
#sub_data_vector <- sub_data_vector %>% select(latitude, longitude, start_date, end_date, number_of_trap, nsm, nsf, nst)
colnames(sub_data_italy) <- c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
sub_data_italy$ds <- "italy"

## 10 - Madrid  the data ============================================================
data_madrid <- read_sandflies_data("madrid", type = "processed")

sub_data_madrid <- data_madrid %>% filter(toupper(collecting_methods) == "LT" )
sub_data_madrid <- remove_NA_coordinates(sub_data_madrid)
sub_data_madrid <- remove_coordinates_in_sea(sub_data_madrid)

# replace number of traps with 1 if it is NA or less than 1 while number_of_collected is 0
sub_data_madrid <- sub_data_madrid %>%
  mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap < 1) & number_of_collected == 0), 1, number_of_trap))

## 08.2 - Remove record number of traps is 0
sub_data_madrid <- sub_data_madrid %>% filter(!is.na(number_of_trap) & number_of_trap != 0)

## 08.3 - remove records with number_of_collected is nan
sub_data_madrid <- sub_data_madrid %>% filter(!is.na(number_of_collected))

sub_data_madrid <- sub_data_madrid %>%
  group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
  summarise(ns = sum(number_of_collected, na.rm = TRUE))

sub_data_madrid <- sub_data_madrid %>%
  group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

## 08.4 The number of sandflies should not be NA, but zero is ok
# The number of sandflies is not NA
sub_data_madrid <- sub_data_madrid %>% filter(!is.na(nst))

## 08.5 - Select the columns that we need
#sub_data_vector <- sub_data_vector %>% select(latitude, longitude, start_date, end_date, number_of_trap, nsm, nsf, nst)
colnames(sub_data_madrid) <- c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
sub_data_madrid$ds <- "madrid"
## 11 - Slovenia  the data ============================================================
data_slovenia <- read_sandflies_data("slovenia", type = "processed")

sub_data_slovenia <- data_slovenia %>% filter(toupper(collecting_methods) == "LT" )
sub_data_slovenia <- remove_NA_coordinates(sub_data_slovenia)
sub_data_slovenia <- remove_coordinates_in_sea(sub_data_slovenia)

# replace number of traps with 1 if it is NA or less than 1 while number_of_collected is 0
sub_data_slovenia <- sub_data_slovenia %>%
  mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap < 1) & number_of_collected == 0), 1, number_of_trap))

## 08.2 - Remove record number of traps is 0
sub_data_slovenia <- sub_data_slovenia %>% filter(!is.na(number_of_trap) & number_of_trap != 0)

## 08.3 - remove records with number_of_collected is nan
sub_data_slovenia <- sub_data_slovenia %>% filter(!is.na(number_of_collected))

sub_data_slovenia <- sub_data_slovenia %>%
  group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
  summarise(ns = sum(number_of_collected, na.rm = TRUE))

sub_data_slovenia <- sub_data_slovenia %>%
  group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

## 08.4 The number of sandflies should not be NA, but zero is ok
# The number of sandflies is not NA
sub_data_slovenia <- sub_data_slovenia %>% filter(!is.na(nst))

## 08.5 - Select the columns that we need
#sub_data_vector <- sub_data_vector %>% select(latitude, longitude, start_date, end_date, number_of_trap, nsm, nsf, nst)
colnames(sub_data_slovenia) <- c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
sub_data_slovenia$ds <- "slovenia"
## 11 - Turkey  the data ============================================================
data_turkey <- read_sandflies_data("turkey", type = "processed")

sub_data_turkey <- data_turkey %>% filter(toupper(collecting_methods) == "LT" )
sub_data_turkey <- remove_NA_coordinates(sub_data_turkey)
sub_data_turkey <- remove_coordinates_in_sea(sub_data_turkey)

# replace number of traps with 1 if it is NA or less than 1 while number_of_collected is 0
sub_data_turkey <- sub_data_turkey %>%
  mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap < 1) & number_of_collected == 0), 1, number_of_trap))

## 08.2 - Remove record number of traps is 0
sub_data_turkey <- sub_data_turkey %>% filter(!is.na(number_of_trap) & number_of_trap != 0)

## 08.3 - remove records with number_of_collected is nan
sub_data_turkey <- sub_data_turkey %>% filter(!is.na(number_of_collected))

sub_data_turkey <- sub_data_turkey %>%
  group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
  summarise(ns = sum(number_of_collected, na.rm = TRUE))

sub_data_turkey <- sub_data_turkey %>%
  group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

## 08.4 The number of sandflies should not be NA, but zero is ok
# The number of sandflies is not NA
sub_data_turkey <- sub_data_turkey %>% filter(!is.na(nst))

## 08.5 - Select the columns that we need
#sub_data_vector <- sub_data_vector %>% select(latitude, longitude, start_date, end_date, number_of_trap, nsm, nsf, nst)
colnames(sub_data_turkey) <- c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
sub_data_turkey$ds <- "turkey"

## 12 - Austeria  the data ============================================================
data_austria <- read_sandflies_data("austria", type = "processed")
unique((data_austria$collecting_methods))

sub_data_austria <- data_austria %>% filter(toupper(collecting_methods) == "LT" )
sub_data_austria <- remove_NA_coordinates(sub_data_austria)
sub_data_austria <- remove_coordinates_in_sea(sub_data_austria)

# replace number of traps with 1 if it is NA or less than 1 while number_of_collected is 0
sub_data_austria <- sub_data_austria %>%
  mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap < 1) & number_of_collected == 0), 1, number_of_trap))

## 08.2 - Remove record number of traps is 0
sub_data_austria <- sub_data_austria %>% filter(!is.na(number_of_trap) & number_of_trap != 0)

## 08.3 - remove records with number_of_collected is nan
sub_data_austria <- sub_data_austria %>% filter(!is.na(number_of_collected))

sub_data_austria <- sub_data_austria %>%
  group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
  summarise(ns = sum(number_of_collected, na.rm = TRUE))

sub_data_austria <- sub_data_austria %>%
  group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

## 08.4 The number of sandflies should not be NA, but zero is ok
# The number of sandflies is not NA
sub_data_austria <- sub_data_austria %>% filter(!is.na(nst))

## 08.5 - Select the columns that we need
#sub_data_vector <- sub_data_vector %>% select(latitude, longitude, start_date, end_date, number_of_trap, nsm, nsf, nst)
colnames(sub_data_austria) <- c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
sub_data_austria$ds <- "austria"

## 13 - Bulgarie  the data ============================================================
data_bulgaria <- read_sandflies_data("bulgaria", type = "processed")
unique((data_bulgaria$collecting_methods))

sub_data_bulgaria <- data_bulgaria %>% filter(toupper(collecting_methods) == "LT" )
sub_data_bulgaria <- remove_NA_coordinates(sub_data_bulgaria)
sub_data_bulgaria <- remove_coordinates_in_sea(sub_data_bulgaria)

# replace number of traps with 1 if it is NA or less than 1 while number_of_collected is 0
sub_data_bulgaria <- sub_data_bulgaria %>%
  mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap < 1) & number_of_collected == 0), 1, number_of_trap))

## 08.2 - Remove record number of traps is 0
sub_data_bulgaria <- sub_data_bulgaria %>% filter(!is.na(number_of_trap) & number_of_trap != 0)

## 08.3 - remove records with number_of_collected is nan
sub_data_bulgaria <- sub_data_bulgaria %>% filter(!is.na(number_of_collected))

sub_data_bulgaria <- sub_data_bulgaria %>%
  group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
  summarise(ns = sum(number_of_collected, na.rm = TRUE))

sub_data_bulgaria <- sub_data_bulgaria %>%
  group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

## 08.4 The number of sandflies should not be NA, but zero is ok
# The number of sandflies is not NA
sub_data_bulgaria <- sub_data_bulgaria %>% filter(!is.na(nst))

## 08.5 - Select the columns that we need
#sub_data_vector <- sub_data_vector %>% select(latitude, longitude, start_date, end_date, number_of_trap, nsm, nsf, nst)
colnames(sub_data_bulgaria) <- c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
sub_data_bulgaria$ds <- "bulgaria"

## 14 - France the data ============================================================
data_france <- read_sandflies_data("france", type = "processed")
unique((data_france$collecting_methods))

sub_data_france <- data_france %>% filter(toupper(collecting_methods) == "LT" )
sub_data_france <- remove_NA_coordinates(sub_data_france)
sub_data_france <- remove_coordinates_in_sea(sub_data_france)

# replace number of traps with 1 if it is NA or less than 1 while number_of_collected is 0
sub_data_france <- sub_data_france %>%
  mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap < 1) & number_of_collected == 0), 1, number_of_trap))

## 08.2 - Remove record number of traps is 0
sub_data_france <- sub_data_france %>% filter(!is.na(number_of_trap) & number_of_trap != 0)

## 08.3 - remove records with number_of_collected is nan
sub_data_france <- sub_data_france %>% filter(!is.na(number_of_collected))

sub_data_france <- sub_data_france %>%
  group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
  summarise(ns = sum(number_of_collected, na.rm = TRUE))

sub_data_france <- sub_data_france %>%
  group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

## 08.4 The number of sandflies should not be NA, but zero is ok
# The number of sandflies is not NA
sub_data_france <- sub_data_france %>% filter(!is.na(nst))

## 08.5 - Select the columns that we need
#sub_data_vector <- sub_data_vector %>% select(latitude, longitude, start_date, end_date, number_of_trap, nsm, nsf, nst)
colnames(sub_data_france) <- c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
sub_data_france$ds <- "france"

## 15 - Mugla the data ============================================================
data_mugla <- read_sandflies_data("mugla", type = "processed")
unique((data_mugla$collecting_methods))

sub_data_mugla <- data_mugla %>% filter(toupper(collecting_methods) == "LT" )
sub_data_mugla <- remove_NA_coordinates(sub_data_mugla)
sub_data_mugla <- remove_coordinates_in_sea(sub_data_mugla)

# replace number of traps with 1 if it is NA or less than 1 while number_of_collected is 0
sub_data_mugla <- sub_data_mugla %>%
  mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap < 1) & number_of_collected == 0), 1, number_of_trap))

## 08.2 - Remove record number of traps is 0
sub_data_mugla <- sub_data_mugla %>% filter(!is.na(number_of_trap) & number_of_trap != 0)

## 08.3 - remove records with number_of_collected is nan
sub_data_mugla <- sub_data_mugla %>% filter(!is.na(number_of_collected))

sub_data_mugla <- sub_data_mugla %>%
  group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
  summarise(ns = sum(number_of_collected, na.rm = TRUE))

sub_data_mugla <- sub_data_mugla %>%
  group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

## 08.4 The number of sandflies should not be NA, but zero is ok
# The number of sandflies is not NA
sub_data_mugla <- sub_data_mugla %>% filter(!is.na(nst))

## 08.5 - Select the columns that we need
#sub_data_vector <- sub_data_vector %>% select(latitude, longitude, start_date, end_date, number_of_trap, nsm, nsf, nst)
colnames(sub_data_mugla) <- c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
sub_data_mugla$ds <- "mugla"

## 16 - Portugal the data ============================================================
data_portugal <- read_sandflies_data("portugal", type = "processed")
unique((data_portugal$collecting_methods))

sub_data_portugal <- data_portugal %>% filter(toupper(collecting_methods) == "LT" )
sub_data_portugal <- remove_NA_coordinates(sub_data_portugal)
sub_data_portugal <- remove_coordinates_in_sea(sub_data_portugal)

# replace number of traps with 1 if it is NA or less than 1 while number_of_collected is 0
sub_data_portugal <- sub_data_portugal %>%
  mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap < 1) & number_of_collected == 0), 1, number_of_trap))

## 08.2 - Remove record number of traps is 0
sub_data_portugal <- sub_data_portugal %>% filter(!is.na(number_of_trap) & number_of_trap != 0)

## 08.3 - remove records with number_of_collected is nan
sub_data_portugal <- sub_data_portugal %>% filter(!is.na(number_of_collected))

sub_data_portugal <- sub_data_portugal %>%
  group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
  summarise(ns = sum(number_of_collected, na.rm = TRUE))

sub_data_portugal <- sub_data_portugal %>%
  group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

## 08.4 The number of sandflies should not be NA, but zero is ok
# The number of sandflies is not NA
sub_data_portugal <- sub_data_portugal %>% filter(!is.na(nst))

## 08.5 - Select the columns that we need
#sub_data_vector <- sub_data_vector %>% select(latitude, longitude, start_date, end_date, number_of_trap, nsm, nsf, nst)
colnames(sub_data_portugal) <- c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
sub_data_portugal$ds <- "portugal"

## 17 - Sicily the data ============================================================
data_sicily <- read_sandflies_data("sicily", type = "processed")
unique((data_sicily$collecting_methods))

sub_data_sicily <- data_sicily %>% filter(toupper(collecting_methods) == "LT" )
sub_data_sicily <- remove_NA_coordinates(sub_data_sicily)
sub_data_sicily <- remove_coordinates_in_sea(sub_data_sicily)

# replace number of traps with 1 if it is NA or less than 1 while number_of_collected is 0
sub_data_sicily <- sub_data_sicily %>%
  mutate(number_of_trap = ifelse(((is.na(number_of_trap) | number_of_trap < 1) & number_of_collected == 0), 1, number_of_trap))

## 08.2 - Remove record number of traps is 0
sub_data_sicily <- sub_data_sicily %>% filter(!is.na(number_of_trap) & number_of_trap != 0)

## 08.3 - remove records with number_of_collected is nan
sub_data_sicily <- sub_data_sicily %>% filter(!is.na(number_of_collected))

sub_data_sicily <- sub_data_sicily %>%
  group_by(latitude, longitude, start_date, end_date, species, sex, number_of_trap) %>%
  summarise(ns = sum(number_of_collected, na.rm = TRUE))

sub_data_sicily <- sub_data_sicily %>%
  group_by(latitude, longitude, start_date, end_date, species, number_of_trap) %>%
  summarise(nsm = sum(ns[tolower(sex) == 'm'], na.rm = TRUE),
            nsf = sum(ns[tolower(sex) == 'f'], na.rm = TRUE),
            nsu = sum(ns[tolower(sex) == 'unknown'], na.rm = TRUE),
            nst = sum(ns, na.rm = TRUE))

## 08.4 The number of sandflies should not be NA, but zero is ok
# The number of sandflies is not NA
sub_data_sicily <- sub_data_sicily %>% filter(!is.na(nst))

## 08.5 - Select the columns that we need
#sub_data_vector <- sub_data_vector %>% select(latitude, longitude, start_date, end_date, number_of_trap, nsm, nsf, nst)
colnames(sub_data_sicily) <- c("lat", "lon", "sdate", "edate", "spec", "nt", "nsm", "nsf", "nsu",  "nst")
sub_data_sicily$ds <- "sicily"
## 19 - RowBind datset =================================================================
ds_final <- rbind(ds_final, sub_data_edenext)
#ds_final <- rbind(ds_final, sub_data_idalert)
ds_final <- rbind(ds_final, sub_data_me1)
ds_final <- rbind(ds_final, sub_data_me2)
ds_final <- rbind(ds_final, sub_data_me3)
ds_final <- rbind(ds_final, sub_data_me4)
ds_final <- rbind(ds_final, sub_data_vector)
ds_final <- rbind(ds_final, sub_data_crete)
ds_final <- rbind(ds_final, sub_data_cyprus)
ds_final <- rbind(ds_final, sub_data_israel)
ds_final <- rbind(ds_final, sub_data_italy)
ds_final <- rbind(ds_final, sub_data_madrid)
ds_final <- rbind(ds_final, sub_data_slovenia)
ds_final <- rbind(ds_final, sub_data_turkey)
ds_final <- rbind(ds_final, sub_data_austria)
ds_final <- rbind(ds_final, sub_data_bulgaria)
ds_final <- rbind(ds_final, sub_data_france)
ds_final <- rbind(ds_final, sub_data_mugla)
ds_final <- rbind(ds_final, sub_data_portugal)
ds_final <- rbind(ds_final, sub_data_sicily)


# 10 - Save the data ==================================================================
write_sandflies_data(ds_final, name = "aggregated")
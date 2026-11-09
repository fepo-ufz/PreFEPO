# 01 - import libraries =============================================================
library(lubridate)
library(dplyr)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")
# 02 read the data =========================================================
flies <- read_sandflies_data(name = "aggregated", type = "processed")
morphology <- read_morphology_data(name = "morphology", type = "processed")
meteo <- read_meteorology_data(name = "meteo", type = "processed")
meteo$sdate <- as.Date(meteo$sdate)


#convert sdate to number by sinuse and cosinuse
flies$sdate <- as.Date(flies$sdate)
flies$edate <- as.Date(flies$edate)
flies$duration <- as.numeric(flies$edate - flies$sdate, units = "days")
flies$dst <- flies$nst/flies$nt/flies$duration
flies <- expand_date(flies)

# 03 Remove irrelevant columns =========================================================

#remove these columns edate, nsm, nsf, nsu, nst, ds
cnames <- colnames(flies)
cnames <- setdiff(cnames, c("edate", "nt", "nsm", "nsf", "nsu", "nst"))
flies <- flies[, cnames]

# 04 - Round coordinates =========================================================
precision <- 4
flies$lat <- round(flies$lat, precision)
flies$lon <- round(flies$lon, precision)
morphology$lat <- round(morphology$lat, precision)
morphology$lon <- round(morphology$lon, precision)
meteo$lat <- round(meteo$lat, precision)
meteo$lon <- round(meteo$lon, precision)

# In this stage, each row represents a single observation of sand flies such that dst is the density of sand flies in that observation, and all observations are in a single day.
# 02 - Group by species =========================================================
# flies_ws refers to flies dataset with species, and flies_ns refers to flies dataset without species
flies_ws <- flies
flies_ns <- flies %>%
  group_by(lat, lon, sdate) %>%
  summarise (dst = sum(dst)) %>%
  ungroup()

flies_ws$smonth <- month(flies_ws$sdate)
flies_ns$smonth <- month(flies_ns$sdate)

# 03 - simple visualizatoin ===============================================
#plot histogram and density of dst in the whole dataset
dn <- density(flies_ws$dst)
plot(dn, main = "Density of dst", xlab = "dst", ylab = "Density")
hist(flies_ws$dst, breaks = 100)

dn <- density(flies_ns$dst)
plot(dn, main = "Density of dst", xlab = "dst", ylab = "Density")
hist(flies_ns$dst, breaks = 100)

#plot number of obeservation for each species
sub <- flies_ws %>% group_by(spec) %>% summarise(n = n())
#ggplot barplot, rotate the x axis labels
plt <- ggplot(sub, aes(x = spec, y = n)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
plt

# 04, join with meteorology, morphology and sandflies data =========================================

data_ws <- flies_ws %>%
   left_join(morphology, by = c("lat", "lon")) %>%
   left_join(meteo, by = c("lat", "lon", "sdate"))

data_ns <- flies_ns %>%
   left_join(morphology, by = c("lat", "lon")) %>%
   left_join(meteo, by = c("lat", "lon", "sdate"))

#count number of rows with NA values
dd <- data_ws[apply(data_ws, 1, function(row) any(is.na(row))), ]

#column dst, and lables should be the last columns
colnames <- colnames(data_ws)
colnames <- setdiff(colnames, "dst")
colnames <- c(colnames, "dst")

# the origin dataset (ds), flag extended should be in the last column
colnames <- setdiff(colnames, c("ds", "expanded"))
colnames <- c(colnames, "ds", "expanded")

data_ws <- data_ws[, colnames]

#remove the X column
idx <- which(colnames(data_ws) == 'X')
if (length(idx) > 0)
  data_ws <- data_ws[, -idx]

colnames <- colnames(data_ns)
colnames <- setdiff(colnames, "dst")
colnames <- c(colnames, "dst")
data_ns <- data_ns[, colnames]
#remove the X column
idx <- which(colnames(data_ns) == 'X')
if (length(idx) > 0)
  data_ns <- data_ns[, -idx]

# Check the NA values belong to which origin dataset
# index of rows with NA values
idx <- which(apply(data_ws, 1, function(row) any(is.na(row))))
na_rows <- data_ws[idx, ]
#group by the origin dataset
na_rows_report <- na_rows %>% group_by(ds) %>% summarise(n = n())

# 05 - Simply with 4 digits of precision ================================================
cnames <- colnames(data_ws)
numerical_columns <- setdiff(cnames, c("sdate", "smonth", "spec", "ds", "spec_code", "expanded", "lc"))
data_ws[, numerical_columns] <- round(data_ws[, numerical_columns], 4)
data_ns[, numerical_columns] <- round(data_ns[, numerical_columns], 4)


# 06 Handle duplication of data =========================================================

# find duplicated rows and remqove them
duplicated_rows <- data_ws[duplicated(data_ws), ]
data_ws <- data_ws[!duplicated(data_ws), ]

# group data based on the lat, lon, and sdate, spec_code, find which group has more than one record
duplicated_rows <- data_ws %>% group_by(lat, lon, sdate, spec_code) %>% summarise(n = n()) %>% filter(n > 1)
# if lat, lon, date and spec_code are the same, it means that all morphological, metelogical, and hydrological data are same, altough the number of sandflies can be different.
# ths we select the first one and the make an avaerage (or max) of the dst and ds(name of dataset) should be concatenated with the origin dataset

# in another case if lat, lon are not the same but the date and spec_code are same, and also the meteological and morphological data are same,
# it means that the distance between the two points are very close, (maybe less than 1 KM),
# in this situtaion it is better to get the maximum of the dst

data_ws <- data_ws %>% group_by(lat, lon, sdate, spec_code) %>% mutate(dst = max(dst), ds = paste(ds, collapse = "_")) %>% slice(1)


#remove data with NA
data_ws <- data_ws[complete.cases(data_ws), ]
data_ns <- data_ns[complete.cases(data_ns), ]
#xx <- data_ws[complete.cases(data_ws), ]

# 03 - Check the all continous columns shoould have between 0 and 1 =========================

# find min and max of each column

min_values <- sapply(data_ws, min, na.rm = TRUE)
max_values <- sapply(data_ws, max, na.rm = TRUE)
min_max <- data.frame(min_values, max_values)
print(min_max)


# 04 - Make you decision, you want to use vectornet or not =========================

#filter records with ds == 'vector'
#data_ws <- data_ws %>% dplyr::filter(ds != 'vector') %>% dplyr::select(-ds)


# remove ds column


#05 - write the data ==============================================================
write_training_data(data_ws, "trainingWS")
write_training_data(data_ns, "trainingNS")

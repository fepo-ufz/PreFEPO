library(lubridate)
library(dplyr)
library(mltools)
library(data.table)

source("src/base.R")

# 02 uniforming the data =========================================================
morph <- read_morphology_data(name = "lc", type = "raw")
morph <- morph %>% dplyr::select(c("lat", "lon", "lc_13"))
colnames(morph) <- c("lat", "lon", "lc")
morph$lc <- as.factor(morph$lc)

#morph <- one_hot(as.data.table(morph))
# 03 write the data ==============================================================
write_morphology_data(morph, name = "lc")


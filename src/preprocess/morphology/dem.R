library(lubridate)
library(dplyr)
source("src/base.R")

# 02 uniforming the data =========================================================
morph <- read_morphology_data(name = "dem", type = "raw")
morph <- morph %>% dplyr::select(c("lat", "lon", "dem_13"))
colnames(morph) <- c("lat", "lon", "elevation")


# The lowest elevation o the land is -433.0 m belong to the DeadSea in Israel
# The highest elevation of the land with population is 5000 meter belong to peru altough it is out of the scope of this study
# As a conclusion, we can say that the elevation of the land is between -450.0 and 5000 meter

min_elevation <- -450.0
max_elevation <- 3000.0
morph$elevation <- (morph$elevation - min_elevation) / (max_elevation - min_elevation)

# 03 write the data ==============================================================
write_morphology_data(morph, name = "dem")


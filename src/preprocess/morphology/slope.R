library(lubridate)
library(dplyr)
source("src/base.R")

# 02 uniforming the data =========================================================
morph <- read_morphology_data(name = "slope", type = "raw")
morph <- morph %>% dplyr::select(c("lat", "lon", "slope_13"))
colnames(morph) <- c("lat", "lon", "slope")

# we get the min and max of the slope in CIMOS domain, and we get this range: 0 - 249.83797
min_slope <- 0
max_slope <- 70
morph$slope <- (morph$slope - min_slope) / (max_slope - min_slope)
# 03 write the data ==============================================================
write_morphology_data(morph, name = "slope")


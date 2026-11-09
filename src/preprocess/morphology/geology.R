library(lubridate)
library(dplyr)
source("src/base.R")

# 02 uniforming the data =========================================================
morph <- read_morphology_data(name = "geology", type = "raw")
morph <- morph %>% dplyr::select(c("lat", "lon", "geology_class_13"))
colnames(morph) <- c("lat", "lon", "geology_class")

# 03 write the data ==============================================================
write_morphology_data(morph, name = "geology")


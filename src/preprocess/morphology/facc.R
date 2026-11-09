library(lubridate)
library(dplyr)
source("src/base.R")

# 02 uniforming the data =========================================================
morph <- read_morphology_data(name = "facc", type = "raw")
morph <- morph %>% dplyr::select(c("lat", "lon", "facc_13"))
colnames(morph) <- c("lat", "lon", "facc")

# 03 write the data ==============================================================
write_morphology_data(morph, name = "facc")


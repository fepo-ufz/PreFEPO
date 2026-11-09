library(lubridate)
library(dplyr)
source("src/base.R")

# 02 uniforming the data =========================================================
# For each coordinates, we get the two closest points in the Morphology data
# A01 A02 A03 A04 A05
# A06 A07 A08 A09 A10
# A11 A12 A13 A14 A15
# A16 A17 A18 A19 A20
# A21 A22 A23 A24 A25
# Based on the above matrix, A13 is the center of the matrix, and exatc corresponding to the given coordinates

morph <- read_morphology_data(name = "aspect", type = "raw")
morph <- morph %>% dplyr::select(c("lat", "lon", "aspect_13"))
colnames(morph) <- c("lat", "lon", "aspect")
# we get the min and max of the slope in CIMOS domain, and we get this range: [0, 359.9775]
min_aspect <- 0
max_aspect <- 360
morph$aspect <- (morph$aspect - min_aspect) / (max_aspect - min_aspect)

# 03 write the data ==============================================================
write_morphology_data(morph, name = "aspect")

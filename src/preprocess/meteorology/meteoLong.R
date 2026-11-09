library(lubridate)
library(dplyr)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")
# 02 read the data =========================================================
data <- read_meteorology_data("monthly")

#long avarge for min-temprature and max-temorature include NAN values for hempgenity we remove these colunmns
# later it should better to replace with long monthly temprature from other repository like ERA5
cols <- c("LM_tmax", "LM_tmin")
data <- data %>% dplyr::select(-cols)
write_meteorology_data(data, name = "monthly")
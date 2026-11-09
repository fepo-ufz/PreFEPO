# Aggregating Flies with All Species.
# The species is not important, and for a given coordinates and date we consder the max collecting number
# It means we focus on dominant species.
# 01 - import libraries =============================================================
library(lubridate)
library(dplyr)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
source("src/utils.R")

# 02 - load data ====================================================================
# synthetic data for location and species
data <- read_sandflies_data(name = "aggregated_as",type = "processed")
data <- get_region_code(data)
# group by region and compute sum of dst
xx <- data %>% group_by(region_code) %>% summarise(n = n(), nst = sum(nst))

dd <- xx %>% filter(nst > 100)

# plot this region on the map
# get the region coordinates
region <- read_region_data()
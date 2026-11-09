# 01 - import libraries =============================================================
library(lubridate)
library(dplyr)

library(dotenv)
load_dot_env("../../../.env")
setwd(Sys.getenv("WORKING_DIR"))
source("../../base.R")
source("../../utils.R")
# ================================================================================

# Assuming df is your original data frame with columns 'lat', 'lon', 'date'
# Ensure 'date' is in Date format
path <- "./resources/data/processed/v2/coorddates/coorddate.csv"
df <- read.csv(path)
df$sdate <- as.Date(df$sdate)

# Create 30 new rows for each existing row with date shifted 30 days back
new_rows <- df %>%
  rowwise() %>%
  do(data.frame(lat = .$lat,
                lon = .$lon,
                sdate = seq(.$sdate, by = -1, length.out = 30)))
# Remove duplicated rows
new_rows <- new_rows[!duplicated(new_rows),]

# Add a column to indicate the origin of the rows
new_rows$origin <- FALSE
df$origin <- TRUE

# Combine the original dataframe with the new rows
df_expanded <- bind_rows(df, new_rows)

# Optional: Arrange by 'lat', 'lon', and 'date'
df_expanded <- df_expanded %>%
  arrange(lat, lon, sdate)

path <- "./resources/data/processed/v2/coorddates/coordpastdate.csv"
write.csv(df_expanded, path, row.names = FALSE)
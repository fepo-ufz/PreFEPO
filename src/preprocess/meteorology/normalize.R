2# 01 - import libraries =============================================================
library(lubridate)
library(dplyr)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")
# ================================================================================
#~	                L_01	L_02	L_03	L_04	L_05	L_06
#Top depth (cm)	    0	    5	    15	    30	    60	    100
#Bottom depth (cm	5	    15	    30	    60	    100	    200

#02 read the data =========================================================

minmax_normalize <- function(name, min_values, max_values, apply_lags = TRUE) {

    lags <- c(1, 7, 14, 21, 28, 35, 42, 49, 56, 63, 70, 90, 120, 150, 180, 210, 240, 270, 300, 330, 365)
    column_names <- if (apply_lags) paste0(name, "_", lags) else name

    selected_data <- meteo %>% dplyr::select(any_of(column_names))
    num_cols <- ncol(selected_data)

    if(length(min_values) == 1){
        min_values <- rep(min_values, num_cols)
    }
    if(length(max_values) == 1){
        max_values <- rep(max_values, num_cols)
    }
    ranges <- max_values - min_values

    normalized_data <- selected_data
    normalized_data <- sweep(normalized_data, 2, min_values, FUN = "-")
    normalized_data <- sweep(normalized_data, 2, ranges, FUN = "/")

    return(normalized_data)
}

meteo <- read_meteorology_data(name = "meteo", type = "processed")
meteo_monthly <- read_meteorology_data(name = "monthly", type = "processed")

meteo$month <- as.integer(month(meteo$sdate))

# join meteo and meteo_monthly based on lat, lon, and month
meteo <- merge(meteo, meteo_monthly, by = c("lat", "lon", "month"), all.x = TRUE)

#Minimum value of SWC_L01: 0.8139793276786804
#Maximum value of SWC_L01: 30.29242515563965
# SWC_L01 [0, 40]
swc1 <- minmax_normalize("swc1", 0, 30)
swc11 <- swc1
#Minimum value of SWC_L02: 1.4359725713729858
#Maximum value of SWC_L02: 60.663970947265625
# SWC_L02 [0, 70]
swc2 <- minmax_normalize("swc2", 0, 50)
swc22 <- (10 * swc2 + 5 * swc1) / (10 + 5)

#Minimum value of SWC_L03: 2.5690743923187256
#Maximum value of SWC_L03: 90.30970764160156
# SWC_L03 [0, 100]
swc3 <- minmax_normalize("swc3", 5, 100)
swc33 <- (15 * swc3 + 10 * swc2 + 5 * swc1) / (15 + 10 + 5)

#Minimum value of SWC_L04: 2.6143715381622314
#Maximum value of SWC_L04: 106.03805541992188
# SWC_L04 [0, 110]
swc4 <- minmax_normalize("swc4", 5, 100)
swc44 <- (30 * swc4 + 15 * swc3 + 10 * swc2 + 5 * swc1) / (30 + 15 + 10 + 5)

#Minimum value of SWC_L05: 9.045849800109863
#Maximum value of SWC_L05: 262.9915771484375
# SWC_L05 [0, 300]
swc5 <- minmax_normalize("swc5", 10, 200)
swc55 <- (40 * swc5 + 30 * swc4 + 15 * swc3 + 10 * swc2 + 5 * swc1) / (40 + 30 + 15 + 10 + 5)

#Minimum value of SWC_L06: 27.149551391601562
#Maximum value of SWC_L06: 526.4985961914062
# SWC_L05 [0, 600]
swc6 <- minmax_normalize("swc6", 100, 400)
swc66 <- (100 * swc6 + 40 * swc5 + 30 * swc4 + 15 * swc3 + 10 * swc2 + 5 * swc1) / (100 + 40 + 30 + 15 + 10 + 5)

#Minimum value of tmin: -47.798912048339844
#Maximum value of tmin: 47.398433685302734
tmin <- minmax_normalize("tmin", -20, 50)

#Minimum value of tmax: -42.299774169921875
#Maximum value of tmax: 53.199920654296875
tmax <- minmax_normalize("tmax", -10, 50)

#Minimum value of tavg: -41.94892883300781
#Maximum value of tavg: 49.04853057861328
tavg <- minmax_normalize("tavg", -15, 50)

#Minimum value of pre: 0.0
#Maximum value of pre: 600.0
max_values <- c(100, 80, 50, 50, 40, 30, 20, 20, 15, 15, 15, 15, 10, 10, 10, 10, 10, 10, 10, 10, 10)
#min_values <- c(80.2, 58.642857, 29.814287, 31.99524, 25.58571, 20.468573, 17.166666, 14.714286, 12.946428, 11.530159, 10.431428, 11.1888895, 9.495, 8.208666, 7.866667, 7.2190475, 6.6766667, 7.00963, 6.6656666, 6.4300003, 5.971233)
pre <- minmax_normalize("pre", 0, max_values)

#Minimum value of pet: 0.0
#Maximum value of pet: 12.051288604736328
max_values <- c(100, 80, 50, 50, 40, 30, 20, 20, 15, 15, 15, 15, 10, 10, 10, 10, 10, 10, 10, 10, 10)
min_values <- c(10, 10, 10, 10, 10, 10, 10, 8, 8, 8, 8, 8, 8, 8, 6, 6, 6, 6, 6, 6, 6)
pet <- minmax_normalize("pet", 0, 10)

#Minimum value of pet: 0.0
#Maximum value of pet: 10
LM_pet <- minmax_normalize("LM_pet", 0, 8, apply_lags = FALSE)

#Minimum value of pet: 0.0
#Maximum value of pet: 500
LM_pre <- minmax_normalize("LM_pre", 0, 300, apply_lags = FALSE)

#Minimum value of pet: 0.0
#Maximum value of pet: 40.0
LM_tavg <- minmax_normalize("LM_tavg", -10, 30, apply_lags = FALSE)

#Minimum value of pet: 0.0
#Maximum value of pet: 30.0
LM_swc1 <- minmax_normalize("LM_swc1", 5, 30, apply_lags = FALSE)

#Minimum value of pet: 0.0
#Maximum value of pet: 60.0
LM_swc2 <- minmax_normalize("LM_swc2", 10, 60, apply_lags = FALSE)

#Minimum value of pet: 0.0
#Maximum value of pet: 90.0
LM_swc3 <- minmax_normalize("LM_swc3", 20, 90, apply_lags = FALSE)

#Minimum value of pet: 0.0
#Maximum value of pet: 105.0
LM_swc4 <- minmax_normalize("LM_swc4", 20, 120, apply_lags = FALSE)

#Minimum value of pet: 0.0
#Maximum value of pet: 250.0
LM_swc5 <- minmax_normalize("LM_swc5", 60, 260, apply_lags = FALSE)

#Minimum value of pet: 0.0
#Maximum value of pet: 500.0
LM_swc6 <- minmax_normalize("LM_swc6", 150, 550, apply_lags = FALSE)


meteo <- cbind(meteo[,c('lat','lon', 'sdate')], swc1, swc2, swc3, swc4, swc5, swc6, tmin, tmax, tavg, pre, pet)
meteo['LM_pet'] <- as.vector(LM_pet)
meteo['LM_tavg'] <- as.vector(LM_tavg)
meteo['LM_pre'] <- as.vector(LM_pre)
meteo['LM_swc1'] <- as.vector(LM_swc1)
meteo['LM_swc2'] <- as.vector(LM_swc2)
meteo['LM_swc3'] <- as.vector(LM_swc3)
meteo['LM_swc4'] <- as.vector(LM_swc4)
meteo['LM_swc5'] <- as.vector(LM_swc5)
meteo['LM_swc6'] <- as.vector(LM_swc6)


# 02 - Check ==============================================================

# The records with lat < 35 have NA values
# In the new version we have values for all climos domain, andd but in some case we have NA for min and max values.
#which(is.na(meteo), arr.ind = TRUE)
#idx <- which(meteo$lat < 35, arr.ind = TRUE)
#meteo <- meteo[-idx,]


# The all values should be [0,1]
cln <- setdiff(colnames(meteo), c('lat', 'lon', 'sdate'))
min(meteo[, cln], na.rm = TRUE)
max(meteo[, cln], na.rm = TRUE)

# Get the maximum values for each column in the meteo data frame
max_values <- apply(meteo[, cln], 2, max, na.rm = TRUE)
print(max_values)

# 03 - Save ==============================================================
write_meteorology_data(meteo, name = "meteo")

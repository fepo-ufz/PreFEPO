# In this script, we are goping to apply a convolution filter upon on soil-horizon-01
# The size of window is 5x5
# The filter is a mean filter


# 00 Bash command for running the script in the cluter ============================================

#!/bin/bash

#    #SBATCH --job-name=sand_caly_convolution
#    #SBATCH --output=../Logs/logs/%x-%A-%a.out
#    #SBATCH --error=../Logs/err/%x-%A-%a.err
#    #SBATCH --time=0-10:00:00
#
#    #SBATCH --mem-per-cpu=20G
#
#    module load foss/2022b R
#
#    Rscript --vanilla /home/$USER/myRscript.R

#source /global/apps/rakovec/module_loads/load_R_0_2.sh

# 01. Load the required libraries =============================================
library(ncdf4)
library(dplyr)
library(bigmemory)
library(doParallel)
library(foreach)
# 01. Define the convolution function =========================================
# The convolution function takes a data matrix and a kernel as input, and returns the convolved matrix.
# owing to the big size of the input data, we use bigmemory package to handle the data.

convolve_2d2 <- function(data_matrix, kernel) {
  n_rows <- nrow(data_matrix)
  n_cols <- ncol(data_matrix)
  kernel_rows <- nrow(kernel)
  kernel_cols <- ncol(kernel)

  # Define padding size (half kernel size)
  pad_size <- floor(c(kernel_rows, kernel_cols) / 2)

  # write d1 is big martix, such that the size of d1 is equal to the size of data_matrix but two rows should shift down and two columns should shift right
  d1 <- big.matrix(nrow = n_rows, ncol = n_cols , init = 0, type = "double")
  d1[3:(n_rows-2), 3:(n_cols-2)] <- data_matrix[1:n_rows, 3:n_cols]


}

convolve_2d <- function(data_matrix, kernel) {
  # Get dimensions of the data matrix and kernel
  n_rows <- nrow(data_matrix)
  n_cols <- ncol(data_matrix)
  kernel_rows <- nrow(kernel)
  kernel_cols <- ncol(kernel)

  # Define padding size (half kernel size)
  pad_size <- floor(c(kernel_rows, kernel_cols) / 2)

  # Check if padding is needed
  if (any(pad_size < 0)) {
    stop("Kernel size cannot be larger than the data matrix dimensions.")
  }

  # Add padding around the data matrix
  padded_matrix <- big.matrix(nrow = n_rows + 2 * pad_size[1], ncol = n_cols + 2 * pad_size[2], init = 0, type = "double")
  padded_matrix[(pad_size[1] + 1):(n_rows + pad_size[1]), (pad_size[2] + 1):(n_cols + pad_size[2])] <- data_matrix[]

  # Convolution with padding
  convolved_matrix <- big.matrix(nrow = n_rows, ncol = n_cols, init = 0, type = "double")

  nt <- n_rows * n_cols
  for(i in 1:nt) {
    i <- as.integer(i)
    row <- as.integer((i - 1) / n_cols) + 1
    col <- as.integer((i - 1) %% n_cols) + 1

    prg <- i/nt * 100
    if (prg == as.integer(prg)) print(prg)

    window <- padded_matrix[row : (row + 2 * pad_size[1]), col : (col + 2 * pad_size[2])]
    convolved_matrix[row, col] <- sum(window * kernel)
  }

 # n_cores <- detectCores()
 # if (n_cores > 1) {
 #   cl <- makeCluster(n_cores)
 #   registerDoParallel(cl)
 # }
#
 # for (i in 1:n_rows) {
 #   row_results <- foreach(j = 1:n_cols, .combine = c, .errorhandling = "pass") %dopar% {
 #     window <- padded_matrix[i:(i + 2 * pad_size[1]), j:(j + 2 * pad_size[2])]
 #     sum(window * kernel)
 #   }
 #   if (inherits(row_results, "try-error")) {
 #     print(paste("Error in row", i, ": ", row_results))
 #   } else {
 #     print(paste("Row ", i, " is done"))
 #     convolved_matrix[i,] <- row_results
 #   }
 # }
#
 # if (n_cores > 1) {
 #   stopCluster(cl)
 # }

  #foreach(i = 1:n_rows) %dopar% {
  #  # Initialize a vector to store the results of the inner loop
  #  row_results <- numeric(n_cols)

  #  # Perform the inner loop
  #  for (j in 1:n_cols) {
  #    window <- padded_matrix[i:(i + 2 * pad_size[1]), j:(j + 2 * pad_size[2])]
  #    row_results[j] <- sum(window * kernel)
  #  }

  #  # Return the results of the inner loop
  #  row_results
  #} -> convolved_matrix

  return(convolved_matrix)
}


# 02. Read the soil class definition ==========================================
#The soil_class_horizon_01.nc file contains the soil class definition for the first horizon of the soil profile.
# and each value refer an ID on the soil_classdefinition.csv file.
# Thus we need to read the soil_classdefinition.csv file to get the soil class definition, and extract the sand and clay content for each class.
sc <- read.csv("/Volumes/Researches/CHS/CLIMOS/SFFA/resources/data/raw/v2/morphology/soil_classdefinition.csv")

# 03. Read Soil Horizon NetCDF file ===============================================

# Open the netCDF file
file_path <- "/Users/soheili/Desktop/soil_class_horizon_01.nc"
nc <- nc_open(file_path)

# Get the variable and coordinates
var <- ncvar_get(nc, "Band1")
lat <- ncvar_get(nc, "lat")
lon <- ncvar_get(nc, "lon")

lat <- lat[7700:7740]
lon <- lon[27300:27370]
var <- var[27300:27370, 7700:7740]

# Define the window size for the convolution
window_size <- 5

# Create the averaging kernel
kernel <- matrix(1.0/(window_size * window_size), nrow = window_size, ncol = window_size)

# 04. Apply the convolution filter ============================================

# Extract the sand and clay content for each soil class
clay <- apply(var, 1, function(x) {
  x <- as.vector(x)
  sc[x, "CLAY"]
})
clay <- t(clay)

sand <- apply(var, 1, function(x) {
  x <- as.vector(x)
  sc[x, "SAND"]
})
sand <- t(sand)

bClay <- big.matrix(clay, type = "double", ncol = ncol(clay), nrow = nrow(clay))
bSand <- big.matrix(sand, type = "double", ncol = ncol(sand), nrow = nrow(sand))
bClay <- clay[]
bSand <- sand[]
print(bClay)
clay_convolved <- convolve_2d(bClay, kernel)
print(clay_convolved)
sand_convolved <- convolve_2d(bSand, kernel)

clay_convolved <- as.matrix(clay_convolved)
sand_convolved <- as.matrix(sand_convolved)

# 05. Write the convolved data to a new NetCDF file ============================
output_file <- "convolved.nc"
if (file.exists(output_file)) {
  file.remove(output_file)
  cat("Existing file removed:", output_file, "\n")
}

lat_dim <- ncdim_def( "lat", "degrees_north", lat)
lon_dim <- ncdim_def( "lon", "degrees_east", lon)
sand_var <- ncvar_def("sand", "percent", list(lat_dim, lon_dim), longname="Sand content")
clay_var <- ncvar_def("clay", "percent", list(lat_dim, lon_dim), longname="Clay content")
nc_new <- nc_create(output_file, list(sand_var, clay_var), force_v4=TRUE)
ncvar_put(nc_new, sand_var, sand_convolved)
ncvar_put(nc_new, clay_var, clay_convolved)
nc_close(nc_new)

# 06. Test ==================================================
#%%
print("=====================================================")

nc <- nc_open(output_file)
#find clay value for the given latitude and longitude
latitude <- 35.0933
longitude <- 33.4334

clay <- ncvar_get(nc, "clay")
lat <- ncvar_get(nc, "lat")
lon <- ncvar_get(nc, "lon")
lat_idx <- which.min(abs(lat - latitude))
lon_idx <- which.min(abs(lon - longitude))
cValue <- clay[lat_idx, lon_idx]
print(cValue)


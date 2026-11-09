# PreFEPO: preprocessing for FEPO

PreFEPO cleans and harmonises the sandfly trap records and extracts the meteorological, hydrological and morphological predictors at the trap sites and dates, producing the training tables of FEPO.

PreFEPO was developed by Majid Soheili at the Helmholtz Centre for Environmental Research - UFZ in the
CLIMOS project (EU Horizon Europe, grant agreement 101057690).

- Article: Soheili et al. (2025), FEPO: a machine learning ensemble approach for predicting extreme
  phlebotomine sand fly abundance and leishmaniasis-risk hotspots across Europe,
  <https://doi.org/10.21203/rs.3.rs-7852217/v1>
- FEPO model: <https://github.com/fepo-ufz/FEPO>

## Release 1.0.0

Release 1.0.0 is the version used for the CLIMOS runs (commit 3a991cd of 3 January 2026 for FEPO,
commit 9f04ff7 of 23 December 2025 for PreFEPO, both in the internal UFZ repositories). It is published
as it was run, apart from the files added for the release (licence, authors, citation) and the
installation of smogn from its public repository. The changes are listed in `CHANGELOG.md`.

The trap data used for training belong to the providers of the field surveys and are not part of this
repository. They can be requested from the providers listed in the article.

---


# Preprocessing steps for the FEPO model
In this document we outline the steps required to preprocess the sandflies data and prepare the corresponding environmental data features for the FEPO model.
As the final result of these preprocessing steps, we will provide a cleaned and well-structured dataset ready for modeling.
The main steps are as follows:

* 1️⃣ [Preparing the sandfly observation data by cleaning and standardizing it.](#step-1-preparing-sandflies-data)
* 2️⃣ [Extracting morphology data features corresponding to the sandfly observation locations.](#step-2-providing-morphology-data-features)
* 3️⃣ [Extracting meteorology data features corresponding to the sandfly observation locations and sampling date.](#step-3-providing-metrological-data-features)
* 4️⃣ [Extracting hydrology data features corresponding to the sandfly observation locations and sampling date.](#step-4-providing-hydrology-data-features)
* 5️⃣ [Combine all the extracted features into a final dataset for modeling.](#step-5-combining-all-features-into-a-final-dataset)

- ✅ All data used in the following steps are stored in the Eve cluster at: `/gpfs1/data/climos/FEPO/RawData/`.
- ✅ Please read [DataSharing.md](DataSharing.md) for more information about the datasets used in this project.

## STEP 1: Preparing Sandflies Data

### 1.1: set path variables in .env file
- Set the following variables in the `.env` file located in the root directory of the project:
```
WORKING_DIR=Absolute path to the root directory of the project
DATA_VERSION=v3
RAW_DATA_DIR=/gpfs1/data/climos/FEPO/RawData
PROCESSED_DATA_DIR=/gpfs1/data/climos/FEPO/ProcessedData
```
### 1.2: Provide raw data files in the specified directories

#### Sandflies Data Directory
- The directory must be named **`sandflies`** and placed under the path: `RAW_DATA_DIR/DATA_VERSION/`.
- Example: `/gpfs1/data/climos/FEPO/RawData/v3/sandflies/`
- For each country, create a subdirectory and place the corresponding `samples.csv` file inside it.

#### Landshape Data Directory
- Place the landshape files under: `RAW_DATA_DIR/landshape/`.
- This directory will not change during the project period, so a data version is not necessary.
- Example: `/gpfs1/data/climos/FEPO/RawData/landshape/`

#### NUTS3 Data Directory
- Place the NUTS3 files under: `RAW_DATA_DIR/NUTS3/`.
- Create subdirectories for each data version (e.g., `2016`, `2024`).
- Example: `/gpfs1/data/climos/FEPO/RawData/NUTS3/2016/`

#### GAUL Data Directory
- Place the GAUL files under: `RAW_DATA_DIR/GAUL/`.
- Create subdirectories for each data version (e.g., `2014`, `2020`).
- Example: `/gpfs1/data/climos/FEPO/RawData/GAUL/2014/`

```
`RAW_DATA_DIR/`
    ├── `v3/`
    │   └── `sandflies/`
    │       ├── `Country1/`
    │       │   └── `samples.csv`
    │       └── `Country2/`
    │           └── `samples.csv`
    ├── `landshape/`
    │   ├── `WB_Land_10m.sbx`
    │   ├── `WB_Land_10m.shp`
    │   └── `...`
    ├── `NUTS3/`
    │   ├── `2016/`
    │   └── `2024/`
    └── `GAUL/`
        └── `2014/`    
```

### 1.3: Run scripts for sandflies data cleaning and standardization
After the above steps, run STEP 2 in `main.R` to clean and standardize the sandflies data:

- `src/data_preparation/main.R`
``` r
source("src/preprocess/sandflies/austria.R")
source("src/preprocess/sandflies/bulgaria.R")
...
source("src/preprocess/coordinates/coorddate.R")
```
---
## Step 2: Providing Morphology Data Features

### 2.1: Normalizing Morphology Data
1. Find the morphology netcdf file at: `/gpfs1/data/climos/FEPO/RawData/Morphology/`
2. Set the input and output directory path variables in NormalizeMorph.sh script located at:`src/Normalizing/NormalizeMorph.sh`
3. Run the NormalizeMorph.sh script on the Eve cluster to normalize the morphology data in a parallel job.
4. The normalized morphology data have been saved in: `/gpfs1/data/climos/FEPO/ProcessedData/Morphology/Norm/`

### 2.2: Extracting Morphology Data Features
1. Find the coordinate file at: `PROCESSED_DATA_DIR/DATA_VERSION/coordinates/coordinates.csv`
2. Set the input and output directory path variables in ExtractingMorph.sh script located at:`src/Extracting/ExtractingMorph.sh`
3. Run the ExtractingMorph.sh script on the Eve cluster to extract morphology features in a parallel job.
4. The extracted morphology features have been saved in: `PROCESSED_DATA_DIR/DATA_VERSION/morphology/`

## Step 3: Providing Metrological Data Features

### 3.1: Normalizing Metrological Data
1. Find the metrological netcdf file at: `/gpfs1/data/climos/FEPO/RawData/Meteorology/`
2. Set the input and output directory path variables in NormalizeMeteo.sh script located at:`src/Normalizing/NormalizeMeteo.sh`
3. Run the NormalizeMeteo.sh script on the Eve cluster to normalize the metrological data in a parallel job.
4. Rnn the ReChunkMetro.sh script on the Eve cluster to rechunk the normalized metrological data in a parallel job.
5. The normalized and chunked metrological data have been saved in: `/gpfs1/data/climos/FEPO/ProcessedData/Meteorology/Norm/`


   |        | tmin | tmax | tavg | pre | pet |
   |--------|------|------|------|-----|-----|
   | Min    | 0    | 0    | 0    | 0   |     |
   | Max    | 0.97 | 1    | 0.98 | 1   |     |


### 3.2: Extracting Metrological Data Features
1. Find the coordinate_dates file at: `PROCESSED_DATA_DIR/DATA_VERSION/coordinates/coordinates_date.csv`
2. Run the metrological data extraction script located at:`src/FeExtracting/ExMetrlogy.sh`
3. The extracted metrological features have been saved in: `PROCESSED_DATA_DIR/DATA_VERSION/Meteorology/`

## Step 4: Providing Hydrology Data Features

### 4.1: Computing Soil Moisture from Hydrology Data
1. Find the hydrology netcdf file at: `/gpfs1/data/climos/hmh_output/emo_v1/mHM_Fluxes_States.nc`
2. Set the input and output directory path variables in ComputeSM.sh script located at:`src/Normalizing/ComputeSM.sh`
3. Run the ComputeSM.sh script on Eve cluster to compute soil moisture the hydrology data in a parallel job.
4. The computed soil moisture data have been saved in: `/gpfs1/data/climos/FEPO/ProcessedData/Hydrology/SM/`

### 4.2: Normalizing SM Data
1. Set the input and output directory path variables in NormalizeSM.sh script located at:`src/Normalizing/NormalizeSM.sh`
2. Run the NormalizeSM.sh script on the Eve cluster to normalize the soil moisture data in a parallel job.
3. The normalized soil moisture data have been saved in: `/gpfs1/data/climos/FEPO/ProcessedData/Hydrology/Norm/`

### 4.3: Extracting Hydrology Data Features
1. Set the input and output directory path variables in ExtractingHydro.sh script located at:`src/Extracting/ExtractingHydro.sh`
2. Find the coordinate_dates file at: `PROCESSED_DATA_DIR/DATA_VERSION/coordinates/coordinates_date.csv`
3. Run the hydrology data extraction script located at:`src/Extracting/ExtractingHydro.sh`
4. The extracted hydrology features have been saved in: `PROCESSED_DATA_DIR/DATA_VERSION/hydrology/`

## Step 5: Combining All Features into a Final Dataset
1. Run STEP 5 in `main.R` to combine all the extracted features into a final dataset for modeling:
    `src/data_preparation/main.R`
    ``` r
    source("src/preprocess/aggregating/synthetic-AS.R")
    source("src/preprocess/training-AS.R")
    ```
2. The final dataset has been saved in: `PROCESSED_DATA_DIR/DATA_VERSION/training/`
3. You can now proceed to model training using the training dataset.

---

## Libraries

- Install the required R packages by running the following command in your R environment:
  * dotenv
  * lubridate
  * dplyr
  * purrr
  * readr
  * tidyr
  * stringr
  * tibble
  * forcats
  * ggplot2
  * scales
  * raster
  * sp
  * rnaturalearth
  * rgeos
  * sf
  * geosphere
  * countrycode

So, you can install them using following command in R console:

```R
install.packages(c(
  "dotenv",
  "lubridate",
  "dplyr",
  "purrr",
  "readr",
  "tidyr",
  "stringr",
  "tibble",
  "forcats",
  "ggplot2",
  "scales",
  "raster",
  "sp",
  "rnaturalearth",
  "rgeos",
  "sf",
  "geosphere",
  "countrycode"
))
```

Or the one more complete way is:

```R
# 1. --- Define the Install and Load Function ---
# This function checks if a package is installed and installs it if missing,
# then loads the package into the current session.
install_and_load <- function(package) {
  # Check if the package is installed using requireNamespace
  if (!requireNamespace(package, quietly = TRUE)) {
    # If not installed, install it from CRAN
    message(paste("Installing package from CRAN:", package))
    install.packages(package, dependencies = TRUE)
  }
  # Load the package
  message(paste("Loading package:", package))
  library(package, character.only = TRUE)
}

# 2. --- Handle Special Package Installations (remotes and httpgd) ---
# Install 'remotes' first, as it's needed to install packages from GitHub
if (!requireNamespace("remotes", quietly = TRUE)) {
  message("Installing 'remotes' package...")
  install.packages("remotes", dependencies = TRUE)
}
library(remotes)

# Install 'httpgd' from GitHub, as the CRAN version was unavailable
if (!requireNamespace("httpgd", quietly = TRUE)) {
  message("Installing 'httpgd' from GitHub (required for VSCode plotting)...")
  remotes::install_github("nx10/httpgd")
}
library(httpgd)


# 3. --- List and Process Core Packages ---
packages_to_check <- c(
  "dotenv",
  "lubridate",
  "dplyr",
  "purrr",
  "readr",
  "tidyr",
  "stringr",
  "tibble",
  "forcats",
  "ggplot2",
  "scales",
  "raster",
  "sp",
  "rnaturalearth",
  "sf",
  "geosphere",
  "countrycode"
  # rgeos is intentionally omitted due to deprecation. Note: rgeos is officially removed and no longer available for R ≥ 4.4, including your R 4.5.0. CRAN retired it because GEOS is now fully integrated into the sf package
)

# Apply the install_and_load function to all core packages
message("\n--- Starting Core Package Installation and Loading ---")
sapply(packages_to_check, install_and_load)


# 4. --- Cleanup ---
# Optional: Remove the custom function to keep the global environment clean
rm(install_and_load)
```

### Note:

The `rgeos` package has been deprecated and is no longer available for R versions 4.4 and above. Its functionalities have been integrated into the `sf` package. If your codebase uses `rgeos`, you should transition to using `sf` functions instead. Below is a mapping of common `rgeos` functions to their `sf` equivalents:

| Old `rgeos` function     | `sf` replacement        |
| ------------------------ | ----------------------- |
| `rgeos::gBuffer()`       | `sf::st_buffer()`       |
| `rgeos::gIntersection()` | `sf::st_intersection()` |
| `rgeos::gUnion()`        | `sf::st_union()`        |
| `rgeos::gDifference()`   | `sf::st_difference()`   |
| `rgeos::gContains()`     | `sf::st_contains()`     |
| `rgeos::gWithin()`       | `sf::st_within()`       |


conda install -n fepo_env r-tidyverse
conda activate fepo_env
conda install -c conda-forge r-leaflet r-sf r-raster r-terra r-units r-s2
conda install -c conda-forge r-rnaturalearth r-rnaturalearthdata

---

## Citation

If you use PreFEPO, please cite the article above and this software (see `CITATION.cff`; the DOI of
each release is on Zenodo).

## Licence

LGPL-3.0-or-later (c) 2025-2026 the PreFEPO developers, Helmholtz Centre for Environmental Research - UFZ.
See `LICENSE.md`, `COPYING` and `COPYING.LESSER`.

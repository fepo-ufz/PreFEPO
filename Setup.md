# Making FEPO Environment
To execute the code implemented in the projects related to the **FEPO model**, it is necessary to create a proper environment that includes all required packages. 
Follow the steps below to set up the appropriate environment.

## ✅ Simpler way using the provided script
A script named `Setup.sh` is provided in the repository to automate the environment setup process. 
You can run this script to create the FEPO environment with all necessary packages installed.
After cloning the repository, execute the following command in your terminal:
```bash
chmod +x ./Setup.sh
./Setup.sh
```

## 🤞Manual way
If you prefer to set up the environment manually, follow the steps outlined below:

1. **Load Conda module**
   ```bash
   module purge
   module load Conda/24.3.0
    ```
2. **Create the FEPO environment (e.g., envFepo)**
    ``` bash
    conda create -n envFepo r-base=4.5.1 r-essentials
    conda activate envFepo
    ```
3. **Install required packages (**R**) using Conda**
    ``` bash
    conda install -c conda-forge gdal proj geos udunits2 libpng sqlite
    conda install -c conda-forge r-sf r-s2 r-terra r-raster r-units
    conda install -c conda-forge r-leaflet r-rnaturalearth
    conda install -c conda-forge r-tidyverse r-lubridate r-dbplyr r-ggplot2 
   ```
4. **Install remaining required packages inside the R environment**
    ```r
    install.packages("dotenv")
    install.packages("geosphere")
    install.packages("countrycode")
    install.packages("languageserver")
    ```
5. **Checking the required library**
    ```r
    library(ggplot2)
    library(lubridate)
    library(dbplyr)
    library(tidyverse)
    library(leaflet)
    library(dotenv)    
    library(raster)
    library(rnaturalearth)    
    library(sf)
    library(scales)        
    library(geosphere)
    library(countrycode)    
   ```
6. **Install required packages (**Python**) using Conda**
    ``` bash
    conda activate envFepo
    conda install python=3.11
    conda create -n envFepo -c conda-forge numpy xarray netCDF4 pandas dask pydantic
    ```
7. **Clone the repository**
   ``` bash
   git clone
   ```
8. ** Define vscode settings for R language server**
   - Open VSCode and go to settings (Ctrl + ,)
   - Search for "r.rterm.linux"
   - Set the path to the R executable in your Conda environment, e.g.:
     ```
     $USER_HOME/.conda/envs/$ENV_NAME/bin/R
     ```
9. **Set permissions for the project directory**
   ``` bash
   chmod -R u+rwX /home/soheili/CHS/projects/PreFEPO
   find /home/soheili/CHS/projects/PreFEPO -type f -name "*.sh" -exec chmod +x {} \;
   ```

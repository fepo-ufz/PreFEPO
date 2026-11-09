#!/bin/bash
# setup_project_envs.sh
# Usage: ./setup_project_envs.sh
# Sets up R + Python environments and VS Code workspace settings

# ---------------------------
# 1. Global Variables
# ---------------------------
ENV_NAME="envFepo"        # R + Python environment
R_VERSION="4.5.1"
PY_VERSION="3.11"
VSCODE_DIR=".vscode"
SETTINGS_FILE="$VSCODE_DIR/settings.json"
USER_HOME="${HOME}"

# ---------------------------
# 2. Load Conda module
# ---------------------------
echo "Purging all modules..."
module purge

echo "Loading Conda module..."
module load Conda/24.3.0

# Initialize Conda for bash scripts
eval "$(conda shell.bash hook)"

# ---------------------------
# 3. Create R + Python environment
# ---------------------------
echo "Creating R environment: $ENV_NAME with R $R_VERSION and Python $PY_VERSION..."
conda create -y -n "$ENV_NAME" r-base="$R_VERSION" r-essentials python="$PY_VERSION"

# Activate R environment
conda activate "$ENV_NAME"

# ---------------------------
# 4. Install R packages via Conda
# ---------------------------
conda install -y -c conda-forge gdal proj geos udunits2 libpng sqlite
conda install -y -c conda-forge r-sf r-s2 r-terra r-raster r-units
conda install -y -c conda-forge r-leaflet r-rnaturalearth
conda install -y -c conda-forge r-tidyverse r-lubridate r-dbplyr r-ggplot2
conda install -y -c conda-forge r-languageserver
conda install -y -c conda-forge numpy xarray netCDF4 pandas dask pydantic python-dotenv
conda install -y -c conda-forge catboost scikit-learn joblib imbalanced-learn imbalance-metrics
pip install numpy==1.26.4
pip install scikit-learn==1.7.2
pip install scikit-learn-extra==0.3.0
pip install seaborn==0.13.2
pip install geopandas==0.14.4
pip install shapely==2.0.3
pip install xgboost==2.1.1
pip install git+https://github.com/fepo-ufz/smogn.git

# ---------------------------
# 5. Install R packages from CRAN
# ---------------------------
Rscript -e 'install.packages(c("dotenv","geosphere","countrycode"), repos="https://cloud.r-project.org/")'

# ---------------------------
# 6. Set VS Code workspace settings for R + Python + Conda terminals
# ---------------------------
mkdir -p "$VSCODE_DIR"
cat > "$SETTINGS_FILE" <<EOL
{
  "r.rterm.linux": "$USER_HOME/.conda/envs/$ENV_NAME/bin/R",
  "r.bracketedPaste": true,
  "terminal.integrated.env.linux": {
    "PROJ_LIB": "$USER_HOME/.conda/envs/$ENV_NAME/bin/share/proj"
  },
  "python.defaultInterpreterPath": "$USER_HOME/.conda/envs/$ENV_NAME/bin/python",
  "terminal.integrated.inheritEnv": true,
  "terminal.integrated.profiles.linux": {
    "envFepo (Python)": {
      "path": "/bin/bash",
      "args": ["-c", "module purge && module load Conda/24.3.0 && conda activate $ENV_NAME && exec bash"]
    },
    "envFepo (R)": {
      "path": "/bin/bash",
      "args": ["-c", "module purge && module load Conda/24.3.0 && conda activate $ENV_NAME && exec R"]
    }
  },
  "terminal.integrated.defaultProfile.linux": "envFepo (Python)"
}
EOL

echo "VS Code workspace settings created at $SETTINGS_FILE"
echo "Profiles created:"
echo " - envFepo (Python): Bash with Conda environment"
echo " - envFepo (R): R with Conda environment"

# ---------------------------
# 7. Make all directories and *.sh files executable
# ---------------------------
echo "Setting execute permissions for directories and *.sh files..."
find . -type d -exec chmod +x {} \;
find . -type f -name "*.sh" -exec chmod +x {} \;

echo "All directories and *.sh files are now executable."
# STEP 01 - import libraries =============================================================
library(lubridate)
library(dotenv)
load_dot_env(".env")
setwd(Sys.getenv("WORKING_DIR"))
source("src/base.R")

# STEP 02: sandflies the data preparation =========================================================

# 02-01 do some correction on the sandflies data
source("src/preprocess/sandflies/austria.R")
source("src/preprocess/sandflies/bulgaria.R")
source("src/preprocess/sandflies/crete.R")
source("src/preprocess/sandflies/cyprus.R")
source("src/preprocess/sandflies/edenext.R")
source("src/preprocess/sandflies/france.R")
source("src/preprocess/sandflies/idalert.R")
source("src/preprocess/sandflies/israel.R")
source("src/preprocess/sandflies/italy.R")
source("src/preprocess/sandflies/madrid.R")
source("src/preprocess/sandflies/me1.R")
source("src/preprocess/sandflies/me2.R")
source("src/preprocess/sandflies/me3.R")
source("src/preprocess/sandflies/me4.R")
source("src/preprocess/sandflies/mugla.R")
source("src/preprocess/sandflies/portugal.R")
source("src/preprocess/sandflies/sicily.R")
source("src/preprocess/sandflies/slovenia.R")
source("src/preprocess/sandflies/turkey.R")
source("src/preprocess/sandflies/vectornet.R")

# 02-02 aggregating all sand flies data to a single file
source("src/preprocess/aggregating/aggregating-Flies-AS.R")
source("src/preprocess/aggregating/aggregating-Flies-AT.R")
source("src/preprocess/aggregating/aggregating-Flies-LT.R")


# 02-03 transform sandflies species to the standard names
source("src/preprocess/aggregating/species.R")

# 02-04 define species dictionary
source("src/preprocess/aggregating/species_dictionary.R")

# 02-05 add coordinates and date features for sandflies observation
source("src/preprocess/coordinates/coordinates.R")

# STEP 03 - Extract corresponding data for sandflies observation =======================================================
source("src/preprocess/morphology/aggregate.R")
source("src/preprocess/meteorology/aggregate.R")
source("src/preprocess/hydrology/aggregate.R")

# STEP 05 - Making Training Data =======================================================
source("src/preprocess/aggregating/synthetic-AS.R")
source("src/preprocess/training-AS.R")
# STEP 06 - Information ========================================================
print("******************************************")
print("Data preprocessing is done.")
print("The prepared data are stored in:")
print(get_training_data_dir())
print("******************************************")
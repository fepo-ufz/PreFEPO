# Data Sharing and Data Access Guide
- This document summarizes the fundamental datasets that are used in FEPO preprocessing, FEPO model training of FEPO outcome.
- All datasets stored in EVE cluster at: `/gpfs1/data/climos/`
- For some RawDatasets, it was necessary to run scripts to provide usable data for downstream stages, which is mentioned in the below sections.


## Quick Reference

| Dataset                 | Contents                                | Purpose                                | Primary EVE path                                            |
|-------------------------|-----------------------------------------|----------------------------------------|-------------------------------------------------------------|
| Hydrology (mHM outputs) | Daily soil-water-content                | Input feature of the FEPO model        | `/gpfs1/data/climos/mhm_output/emo_v1/mHM_Fluxes_States.nc` |
| Meteorology (EMO1)      | Precipitation, temperature, and forcing | Input feature of the FEPO model        | `/gpfs1/data/climos/mhm_output/transfer_MinIO/Meteo/`       |
| Morphology              | DEM, slope, geology, etc.               | Input feature of the FEPO model        | `/gpfs1/data/climos/FEPO/RawData/Morphology`                |
| Sandfly observations    | Coordinates, date, and surveillance     | Target variable of the FEPO model      | `/gpfs1/data/climos/FEPO/RawData/Sandflies/v3/`             |
| Land shape              | Land/water polygons                     | Validation of observation's coordinate | `/gpfs1/data/climos/FEPO/RawData/Sandflies/landshape/`      |
| NUTS3                   | Administrative boundaries               | Validation of species's regions        | `/gpfs1/data/climos/FEPO/RawData/Sandflies/NUTS3/`          |
| GAUL                    | Global Administrative                   | Validation of species's regions        | `/gpfs1/data/climos/FEPO/RawData/Sandflies/GAUL/`           |

---

## 1️⃣ Hydrology Data

- **Source**: Multiscale Hydrologic Model (mHM) run over the CLIMOS domain.
- **Location**: `/gpfs1/data/climos/mhm_output/emo_v1/mHM_Fluxes_States.nc`
- **Coverage**: 1980–2022, daily resolution, 1 km × 1 km grid.
- **Variables**: `SWC_L01` … `SWC_L06` soil water content layers.

### 1.1 Soil Moisture Layer Aggregation

- The FEPO model uses blended soil-moisture depths derived from SWC layers:
```
SM_L01 = SWC_L01
SM_L02 = (10·SWC_L02 + 5·SWC_L01) / 15
SM_L03 = (15·SWC_L03 + 10·SWC_L02 + 5·SWC_L01) / 30
SM_L04 = (30·SWC_L04 + 15·SWC_L03 + 10·SWC_L02 + 5·SWC_L01) / 60
SM_L05 = (40·SWC_L05 + 30·SWC_L04 + 15·SWC_L03 + 10·SWC_L02 + 5·SWC_L01) / 100
SM_L06 = (100·SWC_L06 + 40·SWC_L05 + 30·SWC_L04 + 15·SWC_L03 + 10·SWC_L02 + 5·SWC_L01) / 200
```

- **Run** `src/Normalizing/ComputeSM.sh` on the Eve cluster to generate the blended layers before any normalization. 
- The output NetCDF file is stored under a subdirectory

### 1.2 Normalization
- After computing the blended soil moisture layers, they must be normalized to a 0–1 scale for model training.
- **Run** the normalization script to process the blended layers via `src/Normalizing/NormalizeSM.sh`.
- The resulting NetCDF file will be used for extracting input features for training the FEPO model.

---

## 2️⃣ Meteorology Data

- **Source**: EMO1 reanalysis dataset (Downloaded and prepared by Oldrich Rakovec).
- ** Variables**: Precipitation, temperature (min, max, avg), potential evaporation.
- **Coverage**: 1980–2022, daily resolution, 1 km × 1 km
- **Location**: `/gpfs1/data/climos/mhm_output/transfer_MinIO/Meteo` 
- **Run** `src/Normalizing/NormalizeMeteo.sh` to produce normalized forcing.
  - This script normalizes precipitation, temperature, and potential evaporation variables to a 0–1 scale.

---
## 3️⃣ Morphology Data
- **Source**: It is not clear (Downloaded and prepared by Oldrich Rakovec).
- **Variables**: DEM, slope, aspect, Soil type (Percentage of sand and clay)
- **Location RAW**: `/gpfs1/data/climos/FEPO/RawData/Morphology/`
- **Run** `src/Normalizing/NormalizeMorph.sh` to produce normalized morphology.
  - This script normalizes morphology variables to a 0–1 scale.
- **Location Normal**: `/gpfs1/data/climos/FEPO/NormMorphology/` 
---
## 4️⃣ Sandfly Observation Data
- **URL**: Predicitia Company CKAN portal: `https://climos-data.predictia.es/dataset/`
- **Access**: account on request from the CLIMOS data managers.
- **Contents**: Some csv files containing sandfly surveillance data from multiple countries.
- **Action**: Download CSV files per country and place them under `RAW_DATA_DIR/DATA_VERSION/sandflies/<country>/samples.csv`.
- **Location**: `/gpfs1/data/climos/FEPO/RawData/Sandflies/v3/`
-
---

## 5️⃣ Supporting Geospatial Layers

- **Land/Water Mask**
  - **Purpose**: Enforce that observation points fall on land; used during QA and duplicate removal.
  - **Location**: `/gpfs1/data/climos/FEPO/RawData/Landshape/WB_Land_10m.shp` (plus auxiliary files).
- **Administrative Boundaries (GAUL & NUTS3)**
  - **Purpose**: Validate and filter observation coordinates; derive region labels for species presence constraints.
  - **Locations**:
    - GAUL: `/gpfs1/data/climos/FEPO/RawData/GAUL/`
    - NUTS3: `/gpfs1/data/climos/FEPO/RawData/NUTS3/<version>/`
- **Species Presence Tables**
  - **Purpose**: Define known occurrence regions for sandfly species; used in synthetic sampling and filtering.
  - **Location**:
    - `/gpfs1/data/climos/FEPO/RawData/Sandflies/Eduardo/spatial_presence.csv`
    - `/gpfs1/data/climos/FEPO/RawData/Sandflies/Eduardo/species_presence.csv`
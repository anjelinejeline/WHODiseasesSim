##########################################################################################################################################
# File Name:     07_Predictions.R
# Description:   Predict the fitted models without travel time to healthcare facility and with only travel time to healthcare facility to raster data
# Institution:   JRC
# Author:        Angela Fanelli
# Role:          Epidemiologist
# Email:         Angela.FANELLI@ec.europa.eu
##########################################################################################################################################

# Set the seed for reproducibility
set.seed(123)

# Load the necessary libraries
source("/eos/jeodpp/data/projects/APES/WHODiseasesSim/Scripts/01_Load_packages.R")

# Load the custom functions
source("/eos/jeodpp/data/projects/APES/WHODiseasesSim/Scripts/02_Functions.R")

# Load the models
models_notraveltime_list <- list.files(
  path = '/eos/jeodpp/data/projects/APES/WHODiseasesSim/Output/Models_correction/Models_notraveltime', 
  full.names = TRUE
)

models_onlytraveltime_list <- list.files(
  path = '/eos/jeodpp/data/projects/APES/WHODiseasesSim/Output/Models_correction/Models_onlytraveltime', 
  full.names = TRUE
)

# Load the raster template
raster_template <- rast("/eos/jeodpp/data/projects/APES/WHODiseasesSim/Input/Drivers/aridityIndex.tif")

# Load the gridded data
data <- read.csv("/eos/jeodpp/data/projects/APES/WHODiseasesSim/Input/Outbreaks/dataSim_30km_gridded.csv")

# Make predictions without the travel time to healthcare facilities
walk(
  models_notraveltime_list, 
  function(x) {
    # Read the model
    mod_BARTs <- readRDS(x)
    
    # Extract the model name
    model_name <- gsub("/eos/jeodpp/data/projects/APES/WHODiseasesSim/Output/Models_correction/Models_notraveltime/mod_BARTs_","", x)
    model_name <- gsub(".RDS","", model_name)
    
    # Predict using the predict_BARTs function
    BART_P <- predict_BARTs(
      data = data, 
      covariates = c(
        "aridityIndex", 
        "bioLoss", 
        "landuse_change", 
        "hfc_change", 
        "livestock", 
        "population", 
        "precipitation", 
        "tmax", 
        "tmin"
      ),
      coords = c("x","y"),
      mod_BARTs = mod_BARTs,
      raster_template = raster_template,
      crs = "+proj=moll +lon_0=0 +x_0=0 +y_0=0"
    )
    
    # Write the mean predictions to file
    mean_predictions <- BART_P[[1]]
    writeRaster(
      mean_predictions, 
      filename = glue("/eos/jeodpp/data/projects/APES/WHODiseasesSim/Output/Predictions/Predictions_notraveltime/mean_predictions_{model_name}.tif"),
      filetype = "GTiff"
    )
    
    # Write the uncertainty to file
    uncertainty_sd <- BART_P[[4]]
    writeRaster(
      uncertainty_sd, 
      filename = glue("/eos/jeodpp/data/projects/APES/WHODiseasesSim/Output/Predictions/Uncertainty_SD_notraveltime/uncertainty_sd_{model_name}.tif"),
      filetype = "GTiff"
    )
  }, 
  .progress = TRUE
)

# Make predictions only with the travel time to healthcare facilities
walk(
  models_onlytraveltime_list, 
  function(x) {
    # Read the model
    mod_BARTs <- readRDS(x)
    
    # Extract the model name
    model_name <- gsub("/eos/jeodpp/data/projects/APES/WHODiseasesSim/Output/Models_correction/Models_onlytraveltime/mod_BARTs_","", x)
    model_name <- gsub(".RDS","", model_name)
    
    # Predict using the predict_BARTs function
    BART_P <- predict_BARTs(
      data = data, 
      covariates = c("time_to_healthcare"),
      coords = c("x","y"),
      mod_BARTs = mod_BARTs,
      raster_template = raster_template,
      crs = "+proj=moll +lon_0=0 +x_0=0 +y_0=0"
    )
    
    # Write the mean predictions to file
    mean_predictions <- BART_P[[1]]
    writeRaster(
      mean_predictions, 
      filename = glue("/eos/jeodpp/data/projects/APES/WHODiseasesSim/Output/Predictions/Predictions_onlytraveltime/mean_predictions_{model_name}.tif"),
      filetype = "GTiff"
    )
    
    # Write the uncertainty to file
    uncertainty_sd <- BART_P[[4]]
    writeRaster(
      uncertainty_sd, 
      filename = glue("/eos/jeodpp/data/projects/APES/WHODiseasesSim/Output/Predictions/Uncertainty_SD_onlytraveltime/uncertainty_sd_{model_name}.tif"),
      filetype = "GTiff"
    )
  }, 
  .progress = TRUE
)

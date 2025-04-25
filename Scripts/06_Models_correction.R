##########################################################################################################################################
# File Name:     06_Models_correction.R
# Description:   Fit a BART model for each subset: first without the travel time to healthcare facilities, and then with only this variable as the sole covariate
# Institution:   JRC
# Author:        Angela Fanelli
# Role:          Epidemiologist
# Email:         Angela.FANELLI@ec.europa.eu
##########################################################################################################################################

# Set the seed for reproducibility
set.seed(123)

# Load the required libraries
source("Scripts/01_Load_packages.R")

# Load the custom functions
source("Scripts/02_Functions.R")

# Load subset data
data_list <- list.files(
  "Input/Outbreaks/Subsets", 
  full.names = TRUE
)

# Fit BART models without the travel time to healthcare facilities
walk(
  data_list, 
  \(x) {
    # Call the spatial_BARTs function to fit the model
    spatial_BARTs(
      data = x, 
      outbreak = "presence",
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
      ntree = 200, 
      ndpost = 1000, 
      nskip = 100,
      output_path = "Output/Models_correction/Models_notraveltime"
    )
  }, 
  .progress = TRUE
)

# Fit BART models with only the travel time to healthcare facilities
walk(
  data_list, 
  \(x) {
    # Call the spatial_BARTs function to fit the model
    spatial_BARTs(
      data = x, 
      outbreak = "presence",
      covariates = "time_to_healthcare",
      ntree = 200, 
      ndpost = 1000, 
      nskip = 100,
      output_path = "Output/Models_correction/Models_onlytraveltime"
    )
  }, 
  .progress = TRUE
)

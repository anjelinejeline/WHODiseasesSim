##########################################################################################################################################
# File Name:     05_Models.R
# Description:   Fit a BART model for each subset including the travel time to healthcare facilities as a covariate
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

# Load the subset data
data_list <- list.files(
  "Input/Outbreaks/Subsets", 
  full.names = TRUE
)

# Fit BART models to each subset
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
        "time_to_healthcare",
        "precipitation", 
        "tmax", 
        "tmin"
      ),
      ntree = 200, 
      ndpost = 1000, 
      nskip = 100,
      output_path = "Output/Models"
    )
  }, 
  .progress = TRUE
)

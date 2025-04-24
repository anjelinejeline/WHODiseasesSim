##########################################################################################################################################
# File Name:     03_SimulateOutbreaks.R
# Description:   Simulate presences and absences of WHO priority disease outbreaks
# Institution:   JRC
# Author:        Angela Fanelli
# Role:          Epidemiologist
# Email:         Angela.FANELLI@ec.europa.eu
##########################################################################################################################################

# Set the seed for reproducibility
set.seed(123)

# Load the required libraries
source("/eos/jeodpp/data/projects/APES/WHODiseasesSim/Scripts/01_Load_packages.R")

# Load the gridded dataset containing the covariates 
data <- read.csv("/eos/jeodpp/data/projects/APES/WHODiseasesSim/Input/Drivers/covariates_30km_gridded.csv")

# Simulate the disease presence by assigning approximately 115 random locations as 1 (presence) and the rest as 0 (absence)
data$presence <- rbinom(nrow(data), 1, prob = 115 / nrow(data))

# Reorder the columns to put the response variable first
data <- data |>
  relocate(presence, .before = 1)

# Save the simulated data
write.csv(
  data,
  "/eos/jeodpp/data/projects/APES/WHODiseasesSim/Input/Outbreaks/dataSim_30km_gridded.csv",
  row.names = FALSE
)

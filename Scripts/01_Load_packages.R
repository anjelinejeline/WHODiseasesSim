##########################################################################################################################################
# File Name:     01_Load_packages.R
# Description:   Load required packages for data analysis and visualization
# Institution:   JRC
# Author:        Angela Fanelli
# Role:          Epidemiologist
# Email:         Angela.FANELLI@ec.europa.eu
##########################################################################################################################################

# Define the required libraries
libraries <- c(
  # Packages for spatial data analysis
  "terra", "raster", "sf",
  
  # Packages for data visualization
  "ggplot2", "glue", "extrafont", "cowplot", "colorspace", "tmap", "ggrepel","kableExtra",
  
  # Packages for data manipulation
  "dplyr", "purrr",
  
  # Package for modeling
  "dbarts",
  
  # Packages for parallel processing
  "doSNOW", "foreach"
)

# Load the libraries using purrr::walk
purrr::walk(libraries, library, character.only = TRUE)

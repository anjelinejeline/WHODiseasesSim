##########################################################################################################################################
# File Name:     04_Subsets_Outbreaks.R
# Description:   Create 10 random subsets containing outbreaks and pseudo-absence points to run the model
# Institution:   JRC
# Author:        Angela Fanelli
# Role:          Epidemiologist
# Email:         Angela.FANELLI@ec.europa.eu
##########################################################################################################################################

# Set the seed for reproducibility
set.seed(123)

# Load the required libraries
source("Scripts/01_Load_packages.R")

# Create the subsets
random_numbers <- sample(1:10000, 10, replace = FALSE)
subsets_n <- 1:10

# Create the subsets
walk2(
  random_numbers, 
  subsets_n, 
  function(x, y) {
    # Load the data
    data <- read.csv("Input/Outbreaks/dataSim_30km_gridded.csv")
    
    # Select the presence points
    data_pres <- data |> 
      filter(presence == 1)
    
    # Calculate the number of presence points
    npres <- data |> 
      filter(presence == 1) |> 
      nrow()
    
    # Select the absence points
    data_abs <- data |> 
      filter(presence == 0) |> 
      sample_n(npres * 2)
    
    # Combine the presence and absence points
    data <- rbind(data_pres, data_abs)
    
    # Assign the subset index
    subset_index <- y
    data <- data |> 
      mutate(subset = subset_index)
    
    # Save the subset
    saveRDS(
      data, 
      glue("Input/Outbreaks/Subsets/data_{y}.RDS")
    )
  }
)

##########################################################################################################################################
# File Name:     MarginalEffects.R
# Description:   Compute marginal effects
# Institution:   JRC
# Author:        Angela Fanelli
# Role:          Epidemiologist
# Email:         Angela.FANELLI@ec.europa.eu
##########################################################################################################################################

# Set the seed for reproducibility
set.seed(123)

# Load required libraries
source("/eos/jeodpp/data/projects/APES/WHODiseasesSim/Scripts/01_Load_packages.R")

# Load the data
data <- read.csv("/eos/jeodpp/data/projects/APES/WHODiseasesSim/Input/Outbreaks/dataSim_30km_gridded.csv")

# Define the covariate columns
covariates <- c(
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
)


# Calculate the number of chunks
n_chunks <- ceiling(nrow(data) / 100)

# Split the data into chunks of 100 rows
chunks_list <- split(data, gl(n_chunks, 100, nrow(data)))

# Load the models
mod_all <- list.files("/eos/jeodpp/data/projects/APES/WHODiseasesSim/Output/Models", full.names = TRUE)

# Loop over models and covariates
for (i in seq_along(mod_all)) {
  # Load the current model
  model <- mod_all[i]
  mod_BARTs <- readRDS(model)
  
  # Extract the subset information
  n <- gsub("/eos/jeodpp/data/projects/APES/WHODiseasesSim/Output/Models/mod_BARTs_", "", model)
  n <- gsub(".RDS", "", n)
  
  # Loop over covariates
  for (j in seq_along(covariates)) {
    # Select the current covariate
    covariate <- covariates[j]
    
    # Create a cluster for parallel processing
    cl <- makeSOCKcluster(100)
    registerDoSNOW(cl)
    
    # Compute marginal effects in parallel
    parallel_results <- foreach(chunk = 1:length(chunks_list), .packages = c("dbarts"),
                                .combine = rbind) %dopar% {
                                  # Compute partial dependence
                                  pd <- pdbart(mod_BARTs, xind = covariate, pl = FALSE, levs = list(as.numeric(chunks_list[[chunk]][[covariate]])))
                                  
                                  # Compute the mean of the partial dependence
                                  qmean <- apply(pd$fd[[1]], 2, mean)
                                  p_mean <- pnorm(qmean)
                                  
                                  # Create a data frame with the results
                                  df <- data.frame(x = pd$levs[[1]], mean = p_mean)
                                  
                                  # Return the results
                                  df
                                }
    
    # Stop the cluster
    stopCluster(cl)
    
    # Save the results to a CSV file
    write.csv(parallel_results, 
              glue("/eos/jeodpp/data/projects/APES/WHODiseasesSim/Output/MarginalEffects/MarginalEffect_{covariate}_{n}.csv"), 
              row.names = FALSE)
  }
}


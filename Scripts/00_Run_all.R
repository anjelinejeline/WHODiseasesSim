##########################################################################################################################################
# File Name:     00_Run_all.R
# Description:   Run all scripts sequentially
# Institution:   JRC
# Author:        Angela Fanelli
# Role:          Epidemiologist
# Email:         Angela.FANELLI@ec.europa.eu
##########################################################################################################################################

# Load the required libraries
source("/eos/jeodpp/data/projects/APES/WHODiseasesSim/Scripts/01_Load_packages.R")

# Define the scripts
scripts=list.files(path="/eos/jeodpp/data/projects/APES/WHODiseasesSim/Scripts",
                     pattern=".R",
                     recursive = TRUE,
                     full.names = TRUE)
  
# Exclude the first scripts containing the functions and packages sourced where appropriate in each individual script and the script to visualise the results
scripts=scripts[-c(1:3,10)]


print(scripts)
  
walk(scripts, function(s){
    
    script_name=sub(glue::glue("/eos/jeodpp/data/projects/APES/WHODiseasesSim/Scripts/"), "", s)
    
    # Print useful information to keep track
    # Start time
    start_time = Sys.time()
    start_msg = (glue("Executing script {script_name} at {start_time}\n"))
    write(start_msg, glue("/eos/jeodpp/data/projects/APES/WHODiseasesSim/Output/log_file.txt"), append = TRUE)
    print(start_msg)
    
    # Source the script 
    source(s)
    
  },.progress=TRUE)
  
  



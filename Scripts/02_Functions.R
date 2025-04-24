##########################################################################################################################################
# File Name:     02_Functions.R
# Description:   Functions for the analysis
# Institution:   JRC
# Author:        Angela Fanelli
# Role:          Epidemiologist
# Email:         Angela.FANELLI@ec.europa.eu
##########################################################################################################################################

# Fit a spatial BARTs
spatial_BARTs <- function(data, outbreak, covariates, ntree = 200, ndpost = 1000, nskip = 100, output_path) {
  # Load the data
  data <- readRDS(data)
  n <- data$subset[[1]]  # Retrieve subset index
  
  # Prepare data for BARTs model
  x <- as.matrix(data[, covariates])
  y <- as.vector(data[, outbreak])
  
  # Build the full model
  mod_BARTs <- bart(
    x.train = x,
    ntree = ntree,
    ndpost = ndpost,
    nskip = nskip,
    y.train = y,
    keeptrees = TRUE
  )
  
  # Save the model
  invisible(mod_BARTs$fit$state)
  saveRDS(mod_BARTs, glue("{output_path}/mod_BARTs_{n}.RDS"))
}

# Make predictions
predict_BARTs <- function(data, covariates, coords, mod_BARTs, crs, raster_template) {
  # Prepare data for prediction
  x <- as.matrix(data[, covariates])
  
  # Predict using BARTs model
  predicted <- dbarts:::predict.bart(mod_BARTs, newdata = x, type = "response")
  
  # Calculate the mean and confidence interval across the iterations
  predicted_mean <- predicted |>
    as.data.frame() |>
    colMeans() |>
    as.vector()
  
  predicted_025 <- predicted |>
    as.data.frame() |>
    map_dfr(~ quantile(., probs = 0.025)) |>
    as.vector() |>
    list_c()
  
  predicted_975 <- predicted |>
    as.data.frame() |>
    map_dfr(~ quantile(., probs = 0.975)) |>
    as.vector() |>
    list_c()
  
  # Calculate the standard deviation across the iterations
  predicted_sd <- predicted |>
    as.data.frame() |>
    map_dfr(~ sd(., na.rm = TRUE)) |>
    as.vector() |>
    list_c()
  
  # Create a data frame with the predictions
  predictions_df <- data |>
    select(coords) |>
    mutate(
      predicted_mean = predicted_mean,
      predicted_025 = predicted_025,
      predicted_975 = predicted_975,
      predicted_sd = predicted_sd
    )
  
  # Convert into a vector
  predictions_v <- vect(predictions_df, geom = c("x", "y"), crs = "+proj=moll +lon_0=0 +x_0=0 +y_0=0")
  
  # Rasterize the predictions
  mean_pred <- rasterize(predictions_v, rast(raster_template), field = "predicted_mean")
  names(mean_pred) <- "mean_pred"
  
  lower_ci <- rasterize(predictions_v, rast(raster_template), field = "predicted_025")
  names(lower_ci) <- "lower_ci"
  
  upper_ci <- rasterize(predictions_v, rast(raster_template), field = "predicted_975")
  names(upper_ci) <- "upper_ci"
  
  pred_sd <- rasterize(predictions_v, rast(raster_template), field = "predicted_sd")
  names(pred_sd) <- "pred_sd"
  
  # Combine the predictions into a single object
  pred_sds <- sds(mean_pred, lower_ci, upper_ci, pred_sd)
  return(pred_sds)
}

# Bind marginal effects across all models
bind_marginal_effects <- function(file_path, covariates, nrow = 102508, nmodels = 10) {
  # Loop through each covariate
  for (covar in covariates) {
    # Get the files for the current covariate
    files <- list.files(file_path,
                        pattern = glue("MarginalEffect_{covar}"), full.names = TRUE)
    
    # Read and bind the files
    data <- files |>
      map(\(x) read.csv(x)) |>
      list_rbind() |>
      mutate(model = rep(1:nmodels, each = nrow, length.out = n()))
    
    # Assign the data to the global environment
    assign(x = glue("{covar}"), value = data, envir = .GlobalEnv)
  }
}

# Marginal effect plot
marginal_effect_plot <- function(data, title, themeplot) {
  # Transform the model variable into a categorical one
  data$model <- as.factor(data$model)
  
  # Calculate the average risk across the models
  data_average <- data |>
    group_by(x) |>
    summarise(
      # Calculate the minimum and maximum values before the mean
      min = min(mean),
      max = max(mean),
      mean = mean(mean)
    )
  
  # Create the plot
  plot <- ggplot(data_average, aes(x = x, y = mean)) +
    geom_line(color = "black", size = 0.8) +
    geom_ribbon(aes(x = x, ymin = min, ymax = max), fill = "grey", alpha = 0.3) +
    labs(x = '',
         title = title,
         y = "Mean risk") +
    scale_x_continuous(breaks = pretty(data_average$x, n = 5)) +
    scale_y_continuous(breaks = pretty(data_average$mean, n = 3)) +
    themeplot
  
  return(plot)
}

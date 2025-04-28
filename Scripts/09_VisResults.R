##########################################################################################################################################
# File Name:     09_VisResults.R
# Description:   Creates plots to visualise the main results
# Institution:   JRC
# Author:        Angela Fanelli
# Role:          Epidemiologist
# Email:         Angela.FANELLI@ec.europa.eu
##########################################################################################################################################

# Load required libraries
source("Scripts/01_Load_packages.R")

# Load custom functions
source("Scripts/02_Functions.R")

# Load the data
# Mean predictions across models without travel time to healthcare facilities
mean_pred <- list.files("Output/Predictions/Predictions_notraveltime/", full.names = TRUE) |>
  map(\(x) rast(x))

# Mean predictions across models with only travel time to healthcare facilities as a proxy for detection bias
mean_pred_detection <- list.files("Output/Predictions/Predictions_onlytraveltime/", full.names = TRUE) |>
  map(\(x) rast(x))

# World shapefile
World <- st_read("Input/World_Countries/World_union.shp")

# Regional codes
regionalcodes <- read.csv("Input/World_Countries/ISO-3166-Countries-with-Regional-Codes.csv")

# Import the shapefile containing the IHC3 information
# This shapefile contains a column called mean_perc which is the average IHRC3 per each country across the period of their reporting
# The raw file from which this was derived can be found in Input/Resilience/IHR_C3.xlsx
# or downloaded from https://www.who.int/data/gho/data/indicators/indicator-details/GHO/zoonotic-events-and-the-human-animal-interface
World_countries_ihrc3 <- st_read("Input/Resilience/IHRC3.shp")
World_countries_ihrc3 <- World_countries_ihrc3 |>
  st_transform("+proj=moll +lon_0=0 +x_0=0 +y_0=0")

# Create data frames for marginal effects
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

covariates |>
  walk(\(x) bind_marginal_effects(file_path = "Output/MarginalEffects",
                                 covariates = x, nrow = 102508, nmodels = 10))

# FIGURE 1: TRUE RISK MAP (FACTORING OUT DETECTION BIAS)----
mean_pred <- mean_pred |>
  sds() |>
  app(fun = "mean", na.rm = TRUE)
names(mean_pred) <- "mean_pred"

mean_pred_detection <- mean_pred_detection |>
  sds() |>
  app(fun = "mean", na.rm = TRUE)
names(mean_pred_detection) <- "mean_pred_detection"

# Factor out the detection bias
true_risk <- (mean_pred / mean_pred_detection)
names(true_risk) <- 'true_risk'

# Rescale it between 0 and 1
# Compute the min and max values of the raster
r_min <- global(true_risk, c('min'), na.rm = TRUE) |>
  pull(min)
r_max <- global(true_risk, c('max'), na.rm = TRUE) |>
  pull(max)

# Rescale the raster using the formula
true_risk_rescaled <- (true_risk - r_min) / (r_max - r_min)

# Define palette
InfernoPalette <- sequential_hcl(5, "Inferno")
InfernoPalette <- rev(InfernoPalette)

# Create the map
tm_shape(World, crs = "+proj=moll +lon_0=0 +x_0=0 +y_0=0") +
  tm_borders(col = "black") +
  tm_graticules(labels.show = FALSE, ticks = FALSE) +
  tm_shape(true_risk_rescaled, crs = "+proj=moll +lon_0=0 +x_0=0 +y_0=0") +
  tm_raster(
    col.scale = tm_scale_intervals(style = "fisher",
                                   values = InfernoPalette,
                                   labels = c("Very Low", "Low", "Medium", "High", "Very High")),
    col.legend = tm_legend(title = "", reverse = TRUE)
  ) +
  tm_layout(
    bg.color = "white",
    earth_boundary = TRUE,
    space.color = "white"
  )

# FIGURE 2: MARGINAL EFFECTS------
# Define the theme 
font_import()
loadfonts(device = "pdf")

matplotlib_theme <- theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    text = element_text(family = "DejaVu Sans"), 
    axis.line = element_line(color = "black"),
    axis.ticks = element_line(color = "black"),
    axis.text.x = element_text(color = "black", size = 10),
    axis.text.y = element_text(color = "black", size = 10, angle = 90),
    axis.title.x = element_text(color = "black", size = 10, margin = margin(t = 10, r = 0, b = 0, l = 0)),
    axis.title.y = element_text(color = "black", size = 10, angle = 90, margin = margin(t = 0, r = 10, b = 0, l = 0)),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white"),
    plot.title = element_text(color = "black", size = 10)
  )

# Transform the biodiversity loss in percentage
bioLoss$x <- bioLoss$x * 100

# Create the marginal effects plots
aridityIndex_plot <- marginal_effect_plot(data = aridityIndex, title = "Water deficit index (%)", themeplot = matplotlib_theme)
bioLoss_plot <- marginal_effect_plot(data = bioLoss, title = "Biodiversity loss (%)", themeplot = matplotlib_theme)
landuse_change_plot <- marginal_effect_plot(data = landuse_change, title = "Frequency of land use change", themeplot = matplotlib_theme)
hfc_change_plot <- marginal_effect_plot(data = hfc_change, title = "Δ Human-forest proximity (km)", themeplot = matplotlib_theme)
livestock_plot <- marginal_effect_plot(data = livestock, title = "Livestock density (K head)", themeplot = matplotlib_theme)
population_plot <- marginal_effect_plot(data = population, title = "Population density", themeplot = matplotlib_theme)
precipitation_plot <- marginal_effect_plot(data = precipitation, title = "Annual precipitation (mm)", themeplot = matplotlib_theme)
tmax_plot <- marginal_effect_plot(data = tmax, title = "Annual max temperature (°C)", themeplot = matplotlib_theme)
tmin_plot <- marginal_effect_plot(data = tmin, title = "Annual min temperature (°C)", themeplot = matplotlib_theme)
time_to_healthcare_plot <- marginal_effect_plot(data = time_to_healthcare, title = "Travel time to healthcare (minutes)", themeplot = matplotlib_theme)

# Create the plot grid
plot_grid(tmax_plot, tmin_plot,
          aridityIndex_plot, precipitation_plot,
          livestock_plot, landuse_change_plot, 
          hfc_change_plot, bioLoss_plot,
          population_plot,
          ncol = 3,
          align = "hv",
          label_fontfamily = "DejaVu Sans",
          label_fontface = 'italic')

print(time_to_healthcare_plot)

# FIGURE 3 MAXIMUM OUTBREAK RISK-EPIDEMIC RISK INDEX MATRIX ----
# Extract maximum risk per country
max_risk <- terra::extract(true_risk_rescaled, World_countries_ihrc3, bind = TRUE, fun = "max", na.rm = TRUE)

max_risk <- max_risk |>
  sf::st_as_sf() |>
  filter(!is.na(true_risk))

# Calculate epidemic Index
epidemicriskIndex_sf <- max_risk |>
  mutate(ER = true_risk * (1 - mean_perc))

# Regional analysis
regionalcodes <- regionalcodes |>
  select(alpha.3, region, sub.region, name)

epidemicriskIndex_sf <- epidemicriskIndex_sf |>
  left_join(regionalcodes, by = c("ISO3_CODE" = "alpha.3"))

epidemicriskIndex <- epidemicriskIndex_sf |>
  st_drop_geometry() |>
  mutate(IHR_C3 = mean_perc,
         max_risk = true_risk) |>
  mutate(region = case_when(
    sub.region == "Central Asia" ~ "Asia",
    sub.region == "Eastern Asia" ~ "Asia",
    sub.region == "Southern Asia" ~ "Asia",
    sub.region == "South-eastern Asia" ~ "Asia",
    sub.region == "Western Asia" ~ "Asia",
    sub.region == "Eastern Europe" ~ "Europe",
    sub.region == "Western Europe" ~ "Europe",
    sub.region == "Northern Europe" ~ "Europe",
    sub.region == "Southern Europe" ~ "Europe",
    sub.region == "Northern Africa" ~ "Africa",
    sub.region == "Sub-Saharan Africa" ~ "Africa",
    sub.region == "Australia and New Zealand" ~ "Oceania",
    sub.region == "Polynesia" ~ "Oceania",
    sub.region == "Melanesia" ~ "Oceania",
    sub.region == "Latin America and the Caribbean" ~ "Latin America",
    sub.region == "Northern America" ~ "North America"
  )) |>
  select(CNTR_ID, NAME_ENGL, ISO3_CODE,
         region,
         max_risk, IHR_C3, ER)

# Define matplotlib theme
matplotlib_theme <- theme_minimal(base_size = 20) +
  theme(
    text = element_text(family = "DejaVu Sans"),
    axis.line = element_line(color = "black"),
    axis.ticks = element_line(color = "black"),
    axis.text.x = element_text(color = "black", size = 16),
    axis.text.y = element_text(color = "black", size = 16, angle = 90),
    axis.title.x = element_text(color = "black", size = 16, margin = margin(t = 0, r = 0, b = 0, l = 0)),
    axis.title.y = element_text(color = "black", size = 16, angle = 90, margin = margin(t = 0, r = 0, b = 0, l = 0)),
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 16),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white"),
    plot.title = element_text(hjust = 0.5, color = "black")
  )

# Sample 6 countries randomly
random_countries <- sample(unique(epidemicriskIndex$NAME_ENGL), 6, replace = FALSE)

# Filter the dataset for the randomly selected countries
labelled_points <- epidemicriskIndex |>
  filter(NAME_ENGL %in% random_countries)

# Define palette regions
paletteregions <- c("#00468BFF", "#ED0000FF", "#42B540FF", "#DE8F05", "#0099B4FF", "#925E9FFF")

# Create the plot
matrix <- ggplot(epidemicriskIndex, aes(x = max_risk, y = ER, color = region)) +
  coord_fixed() +
  scale_x_continuous(limits = c(0, 1), breaks = c(0.05, 1),
                     labels = c("0.05" = "Very low", "1" = "Very high")) +
  scale_y_continuous(limits = c(0, 1), breaks = c(0.05, 1),
                     labels = c("0.05" = "", "1" = "Very high")) +
  geom_vline(xintercept = 0.5, color = "grey85") +
  geom_hline(yintercept = 0.5, color = "grey85") +
  geom_point(size = 4, alpha = 0.4) +
  labs(title = "",
       x = "Max risk of an outbreak",
       y = "Epidemic risk index") +
  scale_color_manual(name = "Region", values = paletteregions) +
  matplotlib_theme +
  # Quadrant labels
  annotate("text", x = 0.75, y = 0.75, label = "Critical", size = 6) +
  annotate("text", x = 0.75, y = 0.25, label = "Exposed but resilient", size = 6) +
  annotate("text", x = 0.25, y = 0.25, label = "Least concern", size = 6) +
  annotate("text", x = 0.25, y = 0.75, label = "Unexposed but vulnerable", size = 6) +
  geom_point(data = labelled_points, aes(x = max_risk, y = ER), size = 4, alpha = 0.9) + 
  geom_label_repel(data = labelled_points, aes(label = NAME_ENGL), size = 5, fill = "white", colour = "black", min.segment.length = unit(0, "lines")) +
  theme(
    axis.line = element_line(arrow = arrow(angle = 15, length = unit(.15, "inches"), type = "closed")),
    axis.ticks.y = element_blank(),
    axis.ticks.x = element_blank(),
    plot.margin = margin(t = 0,  
                         r = 0,  
                         b = 0,  
                         l = 0,  
                         unit = "cm")
  )

print(matrix)

# Create ncountriesmatrix
epidemicriskIndex <- epidemicriskIndex |>
  mutate(country_cat = case_when(max_risk <= 0.5 & ER <= 0.5 ~ "Least concern",
                                 max_risk > 0.5 & ER <= 0.5 ~ "Exposed but resilient",
                                 max_risk > 0.5 & ER > 0.5 ~ "Critical"))

epidemicriskIndex_grouped <- epidemicriskIndex |>
  group_by(country_cat, region) |>
  summarise(n = n())

epidemicriskIndex_grouped$country_cat <- factor(epidemicriskIndex_grouped$country_cat, levels = c("Least concern", "Exposed but resilient", "Critical"))

ncountriesmatrix <- ggplot(data = epidemicriskIndex_grouped) +
  geom_bar(width = 0.5, aes(x = country_cat, y = n, fill = region), stat = 'identity', position = "dodge") +
  scale_fill_manual("Region", values = paletteregions) +
  scale_x_discrete(labels = c('Least concern', 'Exposed\nbut resilient', 'Critical')) +
  matplotlib_theme +
  xlab("") +
  ylab("N° countries") +
  theme(axis.ticks.x = element_blank(), 
        axis.title.y = element_text(color = "black", size = 16, angle = 90, margin = margin(t = 0, r = 10, b = 0, l = 0)),
        plot.margin = margin(t = 0,  # Top margin
                             r = 0,  # Right margin
                             b = 0,  # Bottom margin
                             l = 0,  # Left margin
                             unit = "cm"))

# Extract a legend that is laid out horizontally
legend_matrix <- get_legend(
  matrix + 
    guides(color = guide_legend(nrow = 1)) +
    theme(legend.position = "bottom")
)

# Re-build the plot without the legend to reduce the margin and reduce the text size
matrixnolegend <- ggplot(epidemicriskIndex, aes(x = max_risk, y = ER, color = region)) +
  coord_fixed() +
  scale_x_continuous(limits = c(0, 1), breaks = c(0.05, 1),
                     labels = c("0.05" = "Very low", "1" = "Very high")) +
  scale_y_continuous(limits = c(0, 1), breaks = c(0.05, 1),
                     labels = c("0.05" = "", "1" = "Very high")) +
  geom_vline(xintercept = 0.5, color = "grey85") +
  geom_hline(yintercept = 0.5, color = "grey85") +
  geom_point(size = 4, alpha = 0.4, show.legend = FALSE) +
  labs(title = "",
       x = "Max risk of an outbreak",
       y = "Epidemic risk index") +
  scale_color_manual(values = paletteregions) +
  matplotlib_theme +
  # Quadrant labels
  annotate("text", x = 0.75, y = 0.75, label = "Critical", size = 4) +
  annotate("text", x = 0.75, y = 0.25, label = "Exposed but\nresilient", size = 4) +
  annotate("text", x = 0.25, y = 0.25, label = "Least\nconcern", size = 4) +
  annotate("text", x = 0.25, y = 0.75, label = "Unexposed but\nvulnerable", size = 4) +
  geom_point(data = labelled_points, aes(x = max_risk, y = ER), size = 4, alpha = 0.9, show.legend = FALSE) + 
  geom_label_repel(data = labelled_points, aes(label = NAME_ENGL), size = 3, fill = "white", colour = "black", min.segment.length = unit(0, "lines")) +
  theme(
    axis.line = element_line(arrow = arrow(angle = 15, length = unit(.15, "inches"), type = "closed")),
    axis.ticks.y = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title.x = element_text(margin = margin(t = 0, unit = "in")),
    axis.title.y = element_text(margin = margin(r = 0, unit = "in")),
    plot.margin = margin(t = 0,  
                         r = 0,  
                         b = 0,  
                         l = 0,  
                         unit = "cm")
  )

# Create the plot grid
prow <- plot_grid(
  matrixnolegend + theme(legend.position = "none"),
  ncountriesmatrix + theme(legend.position = "none"),
  align = 'vh',
  labels = c("A", "B"),
  label_size = 18,
  hjust = -1,
  nrow = 1,
  label_fontfamily = "DejaVu Sans",
  label_fontface = "plain"
)

# Add the legend underneath the row we made earlier
plot_grid(prow, legend_matrix, ncol = 1, rel_heights = c(1, .1))

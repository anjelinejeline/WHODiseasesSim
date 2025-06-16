# Code and data to accompany "Assessing the risk of diseases with epidemic and pandemic potential in a changing world"

## Authors

Angela Fanelli ([ORCID](https://orcid.org/0000-0002-8204-1230))\
Alessandro Cescatti\
Juan Carlos Ciscar\
Gregoire Dubois\
Dolores Ibarreta\
Rachel Lowe ([ORCID](https://orcid.org/0000-0003-3939-7343))\
Nicola Riccetti ([ORCID](https://orcid.org/0000-0002-3178-7892))\
Marine Robuchon ([ORCID](https://orcid.org/0000-0001-5873-2915))\
Ilaria Capua ([ORCID](https://orcid.org/0000-0002-7072-2581))\
Wojtek Szewczyk\
Emanuele Massaro ([ORCID](https://orcid.org/0000-0002-9287-3743))

Contact information: [Angela.FANELLI\@ec.europa.eu](Angela.FANELLI@ec.europa.eu)

## Description

This repository contains the data and code used to assess the risk of diseases with epidemic and pandemic potential, as described in the paper *Assessing the risk of diseases with epidemic and pandemic potential in a changing world*.

The repository is divided as follows:

-   Input
-   Scripts

It assumes that the results will be saved in a folder called Output and relative subfolders.

## Files

The *Scripts* folder contains all R scripts, while the *Input* folder holds the data files sourced by these scripts. Please note that the scripts are applied to a simulated dataset, and the results will differ from those presented in the manuscript.

**Important notes**:

-   Data availability: The outbreak data used in this analysis is the sole and exclusive property of GIDEON and is protected by [copyright and other intellectual property laws](https://www.gideononline.com/institutional-subscriber-license/). As such, we are not permitted to share the full dataset.
-   Sample dataset: As agreed with GIDEON, in EXTRA_GIDEON.Rmd we show a sample dataset containing 10 records for illustrative purposes only.
-   GIDEON Services: For more information about GIDEON and their services, please visit their [website](https://www.gideononline.com/). You can also contact them directly to learn more about their datasets and services.

A detailed description is provided below.

### Input

Contains data used as input for the project.

#### Drivers

Covariates and raster template for predictions.

-   `aridityIndex.tif`: Aridity index raster.
-   `covariates_30km_gridded.csv`: Covariates data at 30km grid resolution.

#### Outbreaks

Outbreak data and subsets.

-   `GIDEONSample.csv`: Sample outbreak data from GIDEON. 
-   `Subsets`: Directory for storing subsets of outbreak data.

#### Resilience

Data related to zoonotic events and human-animal health interface.

-   `IHRC3.dbf`, `IHRC3.prj`, `IHRC3.shp`, `IHRC3.shx`: Shapefile components for IHR C3 data.
-   `IHR_C3_summary.csv`: Summary of IHR C3 data.
-   `IHR_C3.xlsx`: IHR C3 data downloaded from the [Global Health Observatory](https://www.who.int/data/gho).

#### World_Countries

Shapefile and ISO codes for world countries and regions.

-   `ISO-3166-Countries-with-Regional-Codes.csv`: ISO codes for countries and regions.
-   `World_union.dbf`, `World_union.prj`, `World_union.shp`, `World_union.shx`: Shapefile components for world countries.

### Scripts

Contains R scripts for running the project.

-   `00_Run_all.R`: Script to run all other scripts in sequence.
-   `01_Load_packages.R`: Script to load required R packages.
-   `02_Functions.R`: Script containing custom functions.
-   `03_SimulateOutbreaks.R`: Script to simulate outbreaks.
-   `04_Subsets_Outbreaks.R`: Script to create subsets of outbreak data.
-   `05_Models.R`: Script to run models.
-   `06_Models_correction.R`: Script to correct models.
-   `07_Predictions.R`: Script to make predictions.
-   `08_MarginalEffects.R`: Script to calculate marginal effects.
-   `09_VisResults.R`: Script to visualise the results.
-   `Extra_GIDEON.Rmd`: Additional Rmd file to show GIDEON data.

```         
Session info 

─ Session info ─────────────────────────────────────────────────────────────────
 setting  value
 version  R version 4.4.2 (2024-10-31)
 os       Ubuntu 22.04.5 LTS
 system   x86_64, linux-gnu
 ui       RStudio
 language (EN)
 collate  en_US.UTF-8
 ctype    en_US.UTF-8
 tz       Europe/Rome
 date     2025-04-17
 rstudio  2024.12.0+467 Kousa Dogwood (desktop)
 pandoc   3.2 @ /usr/lib/rstudio/resources/app/bin/quarto/bin/tools/x86_64/ (via rmarkdown)
 quarto   1.5.57 @ /usr/lib/rstudio/resources/app/bin/quarto/bin/quarto

─ Packages ─────────────────────────────────────────────────────────────────────
 package           * version    date (UTC) lib source
 abind               1.4-8      2024-09-12 [1] CRAN (R 4.4.2)
 base64enc           0.1-3      2015-07-28 [3] CRAN (R 4.0.2)
 class               7.3-23     2025-01-01 [4] CRAN (R 4.4.2)
 classInt            0.4-11     2025-01-08 [1] CRAN (R 4.4.2)
 cli                 3.6.4      2025-02-13 [1] CRAN (R 4.4.2)
 clipr               0.8.0      2022-02-22 [1] CRAN (R 4.4.2)
 codetools           0.2-19     2023-02-01 [4] CRAN (R 4.2.2)
 colorspace        * 2.1-1      2024-07-26 [1] CRAN (R 4.4.1)
 cols4all            0.8        2024-10-16 [1] CRAN (R 4.4.2)
 cowplot           * 1.1.3      2024-01-22 [3] CRAN (R 4.3.2)
 crosstalk           1.2.1      2023-11-23 [3] CRAN (R 4.3.2)
 data.table          1.17.0     2025-02-22 [1] CRAN (R 4.4.2)
 dbarts            * 0.9-28     2024-05-02 [1] CRAN (R 4.4.1)
 DBI                 1.2.3      2024-06-02 [1] CRAN (R 4.4.1)
 dichromat           2.0-0.1    2022-05-02 [3] CRAN (R 4.2.0)
 digest              0.6.37     2024-08-19 [1] CRAN (R 4.4.2)
 doSNOW            * 1.0.20     2022-02-04 [3] CRAN (R 4.2.0)
 dplyr             * 1.1.4      2023-11-17 [3] CRAN (R 4.3.2)
 e1071               1.7-16     2024-09-16 [1] CRAN (R 4.4.2)
 evaluate            1.0.3      2025-01-10 [1] CRAN (R 4.4.2)
 extrafont         * 0.19       2023-01-18 [2] CRAN (R 4.4.2)
 extrafontdb         1.0        2012-06-11 [2] CRAN (R 4.4.2)
 fansi               1.0.6      2023-12-08 [3] CRAN (R 4.3.2)
 fastmap             1.2.0      2024-05-15 [1] CRAN (R 4.4.2)
 foreach           * 1.5.2      2022-02-02 [1] CRAN (R 4.4.1)
 generics            0.1.3      2022-07-05 [3] CRAN (R 4.2.1)
 ggplot2           * 3.5.1      2024-04-23 [2] CRAN (R 4.4.2)
 ggrepel           * 0.9.6      2024-09-07 [2] CRAN (R 4.4.2)
 glue              * 1.8.0      2024-09-30 [2] CRAN (R 4.4.2)
 gtable              0.3.5      2024-04-22 [1] CRAN (R 4.4.1)
 htmltools           0.5.8.1    2024-04-04 [1] CRAN (R 4.4.2)
 htmlwidgets         1.6.4      2023-12-06 [3] CRAN (R 4.3.2)
 iterators         * 1.0.14     2022-02-05 [3] CRAN (R 4.2.0)
 kableExtra        * 1.4.0      2024-01-24 [1] CRAN (R 4.4.1)
 KernSmooth          2.23-26    2025-01-01 [4] CRAN (R 4.4.2)
 knitr               1.50       2025-03-16 [1] CRAN (R 4.4.2)
 lattice             0.22-5     2023-10-24 [4] CRAN (R 4.3.1)
 leafem              0.2.3      2023-09-17 [3] CRAN (R 4.3.1)
 leaflegend          1.2.1      2024-05-09 [1] CRAN (R 4.4.1)
 leaflet             2.2.2      2024-03-26 [1] CRAN (R 4.4.2)
 leaflet.providers   2.0.0      2023-10-17 [3] CRAN (R 4.3.2)
 leafsync            0.1.0      2019-03-05 [3] CRAN (R 4.2.0)
 lifecycle           1.0.4      2023-11-07 [3] CRAN (R 4.3.2)
 logger              0.4.0      2024-10-22 [1] CRAN (R 4.4.2)
 lwgeom              0.2-14     2024-02-21 [1] CRAN (R 4.4.1)
 magrittr            2.0.3      2022-03-30 [3] CRAN (R 4.2.0)
 maptiles            0.9.0      2025-02-04 [1] CRAN (R 4.4.2)
 munsell             0.5.1      2024-04-01 [1] CRAN (R 4.4.1)
 pillar              1.9.0      2023-03-22 [3] CRAN (R 4.2.3)
 pkgconfig           2.0.3      2019-09-22 [3] CRAN (R 4.0.1)
 png                 0.1-8      2022-11-29 [1] CRAN (R 4.4.2)
 proxy               0.4-27     2022-06-09 [3] CRAN (R 4.2.0)
 purrr             * 1.0.4      2025-02-05 [1] CRAN (R 4.4.2)
 R6                  2.6.1      2025-02-15 [1] CRAN (R 4.4.2)
 raster            * 3.6-32     2025-03-28 [1] CRAN (R 4.4.2)
 RColorBrewer        1.1-3      2022-04-03 [3] CRAN (R 4.2.0)
 Rcpp                1.0.14     2025-01-12 [1] CRAN (R 4.4.2)
 rlang               1.1.5      2025-01-17 [2] CRAN (R 4.4.2)
 rmarkdown           2.29       2024-11-04 [1] CRAN (R 4.4.2)
 rstudioapi          0.15.0     2023-07-07 [3] CRAN (R 4.3.1)
 Rttf2pt1            1.3.12     2023-01-22 [2] CRAN (R 4.4.2)
 s2                  1.1.7      2024-07-17 [1] CRAN (R 4.4.1)
 scales              1.3.0      2023-11-28 [3] CRAN (R 4.3.2)
 sessioninfo         1.2.3      2025-02-05 [1] CRAN (R 4.4.2)
 sf                * 1.0-20     2025-03-24 [1] CRAN (R 4.4.2)
 snow              * 0.4-4      2021-10-27 [3] CRAN (R 4.1.2)
 sp                * 2.2-0      2025-02-01 [1] CRAN (R 4.4.2)
 spacesXYZ           1.5-1      2025-02-10 [1] CRAN (R 4.4.2)
 stars               0.6-8      2025-02-01 [1] CRAN (R 4.4.2)
 stringi             1.8.4      2024-05-06 [1] CRAN (R 4.4.1)
 stringr             1.5.1      2023-11-14 [3] CRAN (R 4.3.2)
 svglite             2.1.3      2023-12-08 [3] CRAN (R 4.3.2)
 systemfonts         1.2.1      2025-01-20 [2] CRAN (R 4.4.2)
 terra             * 1.8-15     2025-01-24 [1] CRAN (R 4.4.2)
 tibble              3.2.1      2023-03-20 [3] CRAN (R 4.3.1)
 tidyselect          1.2.1      2024-03-11 [1] CRAN (R 4.4.1)
 tmap              * 4.0.0.9000 2025-04-11 [1] Github (r-tmap/tmap@ce647f1)
 tmaptools           3.2        2025-01-13 [1] CRAN (R 4.4.2)
 units               0.8-7      2025-03-11 [1] CRAN (R 4.4.2)
 utf8                1.2.4      2023-10-22 [3] CRAN (R 4.3.2)
 vctrs               0.6.5      2023-12-01 [3] CRAN (R 4.3.2)
 viridisLite         0.4.2      2023-05-02 [3] CRAN (R 4.3.0)
 withr               3.0.1      2024-07-31 [1] CRAN (R 4.4.1)
 wk                  0.9.4      2024-10-11 [1] CRAN (R 4.4.2)
 xfun                0.52       2025-04-02 [1] CRAN (R 4.4.2)
 XML                 3.99-0.18  2025-01-01 [1] CRAN (R 4.4.2)
 xml2                1.3.6      2023-12-04 [3] CRAN (R 4.3.2)

 [1] /home/panelan/R/x86_64-pc-linux-gnu-library/4.4
 [2] /usr/local/lib/R/site-library
 [3] /usr/lib/R/site-library
 [4] /usr/lib/R/library
 * ── Packages attached to the search path.

────────────────────────────────────────────────────────────────────────────────
```

rm(list=ls())

# needed libraries
libs <- c(
  "tidyverse", "stringr", "httr", "sf", "giscoR", "scales"
)

#check if libraries are installed and install missing ones
installed_libs <- libs %in% rownames(installed.packages())
if (any(installed_libs==FALSE)) {
  install.packages(libs[!installed_libs])
}

lapply(libs, library, character.only = T)

### get the data from the geonames dataset
file_name <- "geonames-population-1000.csv"
## define the function
get_geonames_data <- function() {
  table_link <- "https://public.opendatasoft.com/api/explore/v2.1/catalog/datasets/geonames-all-cities-with-a-population-1000/exports/csv?lang=en&timezone=Europe%2FBerlin&use_labels=true&delimiter=%3B"
  res <- httr::GET(table_link, write_disk(file_name), progress())
}
get_geonames_data() ### run the function

## load the csv in R
places_df <- read.csv(file_name, sep = ";")
head(places_df)
names(places_df)

### downsize the dataset to: name, country, population, coodìrdinates
places_modified_df <- places_df[, c(2,7,14,20)]
names(places_modified_df) <- c("name", "country_code", "pop", "coords")
head(places_modified_df)

## dplyr alternative
var<- c("Name", "Country.Code", "Population", "Coordinates")
places_small_df <- places_df %>% select(var)
head(places_small_df)

### split the coordinates column in latitude and longitude
places_modified_df[c("lat", "long")] <- 
  stringr::str_split_fixed(places_modified_df$coords, ",", 2) ## can we use dplyr for this?

head(places_modified_df)
places_clean_df <- places_modified_df %>% select(-coords)
head(places_clean_df)

### generate shapefile
## define coordinate reference system
crsLONGLAT <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
places_sf <-places_clean_df %>% st_as_sf(coords=c("long", "lat"), crs=crsLONGLAT)

places_sf

### plottign
ggplot() +
  geom_sf(
    data=places_sf,
  )

## country level obyect?
places_uk_sf <- places_sf %>% filter(country_code == "GB")

View(places_uk_sf)
ggplot() + 
  geom_sf(data=places_uk_sf)

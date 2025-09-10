## plotting points - the German version

rm(list  = ls())
# needed libraries
libs <- c(
  "tidyverse", "stringr", "httr", "sf", "giscoR", "scales"
)
## check if libraries are present and in case not download them
installed_libs <- libs %in% rownames(installed.packages())
if (any(installed_libs==FALSE)) {
  install.packages(libs[!installed_libs])
}

### load libraries
lapply(libs, library, character.only = T)

## check if dataset is present and download it in case
file_name <- "geonames-population-1000.csv"
if (file.exists(file_name) == FALSE) {
  get_geonames_data <- function() {
    table_link <- "https://public.opendatasoft.com/api/explore/v2.1/catalog/datasets/geonames-all-cities-with-a-population-1000/exports/csv?lang=en&timezone=Europe%2FBerlin&use_labels=true&delimiter=%3B"
    res <- httr::GET(table_link, write_disk(file_name), progress())
  }
  get_geonames_data() ### run the function
}

## load the csv in R
places_df <- read.csv(file_name, sep = ";")
head(places_df)
names(places_df)

### select only relevant columns
var<- c("Name", "Country.Code", "Population", "Coordinates")
places_small_df <- places_df %>% select(var)
head(places_small_df)

names(places_small_df) <- c("name", "country_code", "pop", "coords")
head(places_small_df)

#### splitting the coordinate column
places_coord_df <- places_small_df %>% bind_cols(
  stringr::str_split_fixed(places_small_df$coords, ",", 2) 
)
names(places_coord_df) <- c(names(places_small_df), "long", "lat")
head(places_coord_df)

places_clean_df <- places_coord_df %>% select(-coords)
head(places_clean_df)

### selecting Germany
places_germany_df <- places_clean_df %>% filter(country_code == "DE")

###creating shapefile
crsLONGLAT <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
germany_sf <-places_germany_df %>% st_as_sf(coords=c("lat", "long"), crs=crsLONGLAT)

germany_sf

de <- gisco_get_countries(resolution = "1", country = "DEU") %>% 
  st_transform(crsLONGLAT) ## need to transform to same crs
plot(de)

### plottign
ggplot() +
  geom_sf(
    data=germany_sf,
    color = "purple",
    fill = "purple",
    alpha = .5
  ) +
  geom_sf(
    data = de,
    color="grey20",
    fill = "transparent"
  )

germany_sf %>% st_write("germany_sf.shp")


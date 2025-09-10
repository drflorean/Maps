### plotting different types of settlement
rm(list = ls())
s
germany_sf <- st_read("germany_sf.shp")
head(germany_sf)

crsLONGLAT <- st_crs(germany_sf)
de <- gisco_get_countries(resolution = "1", country = "DEU") %>% 
  st_transform(crsLONGLAT) ## need to transform to same crs

### generate variable for Grossstadt
germany_gs <- germany_sf %>% 
  mutate(big_label = case_when(
    pop >= 100000 ~ "Grossstadt",
    pop < 100000 ~ "Kleinstadt"
))
head(germany_gs)

## plot
ggplot() +
  geom_sf(
    data=germany_gs,
    aes(color = big_label, size = pop),
    alpha = 0.6
  ) +
  geom_sf(
    data = de,
    color = "grey5",
    fill = "transparent"
  )

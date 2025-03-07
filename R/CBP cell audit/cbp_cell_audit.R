library(tidync)
library(sf)
library(dplyr)
library(mapview)

model_points <- tidync("R/big data/whiteperch_95_96.nc") |>
  activate(
    "D1,D0"
  ) |>
  hyper_tibble() |>
  distinct(Cell_ID, .keep_all = TRUE) |>
  sf::st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326)

model_cells <- st_read("R/Chesapeake_Bay_Water_Quality_Modeling_cells.geojson")


cells_points_joined <- sf::st_join(
  model_cells,
  model_points
) |>
  mutate(cell = is.na(Cell_ID))

the_map <- mapview(
  cells_points_joined,
  zcol = "cell"
) +
  mapview(model_points, cex = 2)

the_map |>
  mapshot("cbp_polygon_audit.html",
    selfcontained = TRUE
  )

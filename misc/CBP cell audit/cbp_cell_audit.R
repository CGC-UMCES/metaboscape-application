## Audit run to compare CBP cells to model points
## Completed 2025-03-07
# This file was used to match the coordinates from the metaboscape model output
#  to the curvilinear grid found here as of 2025-03-24:
#  https://data-chesbay.opendata.arcgis.com/maps/9e77263c8c594d88869e46cbe85ca666
#  REST: https://gis.chesapeakebay.net/ags/rest/services/Modeling/WQ_cells_11064/MapServer

library(tidync)
library(sf)
library(dplyr)
library(mapview)

model_points <- tidync("data/whiteperch_95_96.nc") |>
  activate(
    "D1,D0"
  ) |>
  hyper_tibble() |>
  distinct(Cell_ID, .keep_all = TRUE) |>
  sf::st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326)

model_cells <- st_read("misc/CBP cell audit/Chesapeake_Bay_Water_Quality_Modeling_cells.geojson")

# Shift latitude down by 0.00225 to match model points
# This was done by hand -- other values will likely work
st_geometry(model_cells) <- st_geometry(model_cells) - c(0, 0.00225)
st_crs(model_cells) <- 4326

cells_points_joined <- sf::st_join(
  model_cells,
  model_points
) |>
  mutate(cell = is.na(Cell_ID))

mapview(
  cells_points_joined,
  zcol = "cell"
) +
  mapview(model_points, cex = 2)

# CELLID is the cell ID from the CBP model polygons
#   Note that CELLID has leading zeroes
# Cell_ID is the cell ID from the model points
key <- cells_points_joined |>
  data.frame() |>
  select(CELLID, Cell_ID) |>
  distinct()

write.csv(key, "data/cell_id_key.csv", row.names = FALSE)

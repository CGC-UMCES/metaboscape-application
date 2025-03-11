library(tidync)
library(sf)
library(dplyr)

coord_key <- read.csv(
  "R/cell_id_key.csv",
  colClasses = "character"
) |>
  # Change to nuemeric to get the correct order
  mutate(Cell_ID = as.numeric(Cell_ID)) |>
  arrange(Cell_ID)

wp <- tidync("R/big data/whiteperch_95_96.nc")

coords <- wp |>
  activate(
    "D1,D0"
  ) |>
  hyper_tibble() |>
  distinct(Cell_ID, .keep_all = TRUE) |>
  sf::st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326)

model <- wp |>
  hyper_filter(
    Layer_N = Layer_N > 25 & Layer_N < 26,
    Time = Time == "1995-01-01-00"
  ) |>
  hyper_tibble() |>
  bind_cols(coord_key)

domain <- "R/CBP cell audit/Chesapeake_Bay_Water_Quality_Modeling_cells.geojson" |>
  sf::st_read() |>
  left_join(model, by = join_by(CELLID))

library(mapgl)

maplibre(style = carto_style("positron")) |>
  fit_bounds(
    c(-77.46285, 36.71919, -75.38543, 39.63196)
  ) |>
  add_fill_layer(
    id = "domain",
    source = domain,
    fill_color = interpolate(
      column = "DEPTH",
      values = range(domain$DEPTH, na.rm = TRUE),
      stops = c("blue", "red"),
      na_color = "lightgrey"
    ),
    fill_opacity = 0.5,
    fill_outline_color = "rgba(0, 0, 0, 0)",
    tooltip = "DEPTH"
  )

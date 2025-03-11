library(sf)
library(dplyr)
library(tidyr)

model_cells <- st_read("R/CBP cell audit/Chesapeake_Bay_Water_Quality_Modeling_cells.geojson") |>
  pivot_longer(starts_with("LAYER"), names_to = "layer", values_to = "cell") |>
  select(DEPTH, layer, cell) |>
  filter(cell != 0) |>
  mutate(layer = as.numeric(gsub("LAYER_", "", layer)))

k <- model_cells |>
  group_by(geometry) |>
  filter(layer == min(layer))

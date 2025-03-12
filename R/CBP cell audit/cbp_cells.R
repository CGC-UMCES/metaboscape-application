library(sf)
library(dplyr)
library(tidyr)

model_cells <- st_read("R/CBP cell audit/Chesapeake_Bay_Water_Quality_Modeling_cells.geojson") |>
  pivot_longer(starts_with("LAYER"), names_to = "layer", values_to = "cell") |>
  mutate(layer_index = as.numeric(gsub("LAYER_", "", layer))) |>
  select(layer_index, cell) |>
  filter(cell != 0)

st_write(model_cells, "R/working data/model_cells.geojson")

# Find the maximum layer for each cell
max_layer <- model_cells |>
  group_by(geometry) |>
  filter(layer_index == min(layer_index))

library(tidync)
library(sf)
library(dplyr)

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
    Layer_N = Layer_N < 2,
    Time = Time == "1995-01-01-00"
  ) |>
  hyper_tibble()

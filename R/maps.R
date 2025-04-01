## Import data
init_data <- slice_ncdf(5, "1995-04-01")
init_compare_data <- slice_ncdf(5, "1996-04-01")

## Overall range for comparison
compare_range <- range(
  c(init_data$IGR, init_compare_data$IGR),
  na.rm = TRUE
)

# Create the initial map
init_map <- mapgl::maplibre(
  style = mapgl::carto_style("positron"),
  bounds = c(-77.46285, 36.71919, -75.38543, 39.63196)
) |>
  mapgl::add_fill_layer(
    id = "domain",
    source = init_data,
    fill_color = mapgl::interpolate(
      column = "IGR",
      values = range(
        init_data$IGR,
        na.rm = TRUE
      ),
      stops = c("blue", "red"),
      na_color = "lightgrey"
    ),
    fill_opacity = 0.8,
    tooltip = "IGR"
  )
  

# Create the initial compare map
init_compare_map <- mapgl::maplibre(
  style = mapgl::carto_style("positron"),
  bounds = c(-77.46285, 36.71919, -75.38543, 39.63196)
) |>
  mapgl::add_fill_layer(
    id = "domain",
    source = init_compare_data,
    fill_color = mapgl::interpolate(
      column = "IGR",
      values = range(
        init_compare_data$IGR,
        na.rm = TRUE
      ),
      stops = c("blue", "red"),
      na_color = "lightgrey"
    ),
    fill_opacity = 0.8,
    tooltip = "IGR"
  )

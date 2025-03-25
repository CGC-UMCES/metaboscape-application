#' Update the map proxy when triggered by changing inputs
#'
#' @param input UI inputs
#' @param data Reactive data from `slice_ncdf`
#' @param clear Logical. Clear the current map layer?
update_map_paint <- function(input, data, clear = FALSE) {
  variable_range <- range(data[[input$select]], na.rm = TRUE)

  base <- mapgl::maplibre_proxy("map") |>
    mapgl::set_view(
      center = input$map_center,
      zoom = input$map_zoom
    )

  if (isTRUE(clear)) {
    base <- base |>
      mapgl::set_source(
        "domain",
        data
      )
  }

  base |>
    mapgl::set_paint_property(
      layer = "domain",
      name = "fill-color",
      value = mapgl::interpolate(
        column = input$select,
        values = variable_range,
        stops = c("blue", "red"),
        na_color = "lightgrey"
      )
    ) |>
    mapgl::set_tooltip(
      layer = "domain",
      tooltip = input$select
    ) |>
    mapgl::add_legend(
      legend_title = input$select,
      type = "continuous",
      colors = c("blue", "red"),
      values = variable_range
    )
}

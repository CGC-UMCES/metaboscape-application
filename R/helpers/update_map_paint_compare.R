#' Update the compare map proxy when triggered by changing inputs
#'
#' @param input UI inputs
#' @param side Which side of the map to update? "before" or "after"
update_map_paint_compare <- function(input, side) {
  variable_range <- range(
  c(init_data[[input$select_compare]], init_compare_data[[input$select_compare]]),
  na.rm = TRUE
)

  base <- mapgl::maplibre_compare_proxy(
    "compare", map_side = side
    ) |>
    mapgl::set_view(
      center = input$map_center,
      zoom = input$map_zoom
    ) |>
    mapgl::set_paint_property(
      layer = "domain",
      name = "fill-color",
      value = mapgl::interpolate(
        column = input$select_compare,
        values = variable_range,
        stops = c("blue", "red"),
        na_color = "lightgrey"
      )
    ) |>
    mapgl::set_tooltip(
      layer = "domain",
      tooltip = input$select_compare
    ) 
    
    if (side == "before") {
      base |>
    mapgl::add_legend(
      legend_title = input$select_compare,
      type = "continuous",
      colors = c("blue", "red"),
      values = variable_range
    )
    }
}

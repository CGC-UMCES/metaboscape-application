server <- function(input, output, session) {
  selected_data <- shiny::reactive({
    slice_ncdf(input$layer, input$date)
  })


  output$map <- mapgl::renderMaplibre({
    init_map |>
      mapgl::add_legend(
        legend_title = "IGR",
        type = "continuous",
        colors = c("blue", "red"),
        values = range(
          init_data$IGR,
          na.rm = TRUE
        )
      )
  })

  output$compare <- mapgl::renderMaplibreCompare({
    mapgl::compare(
      init_map,
      init_compare_map
    )
  })

  shiny::observeEvent(
    input$select,
    update_map_paint(input, selected_data())
  )

  shiny::observeEvent(
    input$date,
    update_map_paint(input, selected_data(), clear = TRUE)
  )

  # Need to clear the map layer if changing model depth as the plotting
  # domain is now different.
  shiny::observeEvent(
    input$layer,
    update_map_paint(input, selected_data(), clear = TRUE)
  )

  # Comparison map
  shiny::observeEvent(
    input$select_compare,
    {
      update_map_paint_compare(input, side = "before")
      update_map_paint_compare(input, side = "after")
    }
  )
}

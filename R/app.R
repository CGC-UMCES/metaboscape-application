# This library utilizes the shiny, bslib, mapgl, tidync, and dplyr R packages
# Shiny reference: https://mastering-shiny.org/index.html

# Suppress messages from unused terra dependency to install the
#   codetools package.
suppressMessages(
  library(mapgl)
)

options(shiny.host = "0.0.0.0")
options(shiny.port = 20688)

# Load helper functions
sapply(
  list.files("/home/R/helpers", full.names = TRUE),
  source
)

# Load metaboscape model output
wp <- tidync::tidync(
  "/home/data/whiteperch_95_96.nc"
)

# Initial data
init_data <- slice_ncdf(5, "1995-01-01")

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
  ) |>
  mapgl::add_legend(
    legend_title = "IGR",
    type = "continuous",
    colors = c("blue", "red"),
    values = range(
      init_data$IGR,
      na.rm = TRUE
    )
  )

### The app ###
ui <- bslib::page_navbar(
  title = "The Chesapeake Metaboscape v0.1.0",
  sidebar = bslib::sidebar(
    bslib::card(
      shiny::selectInput(
        "select",
        "Select variable",
        choices = list(
          "Inst. Growth Rate" = "IGR", "MF" = "MF", "RM" = "RM",
          "Temperature (C)" = "T", "Salinity (ppt)" = "S",
          "Dissolved Oxygen (mg/L)" = "DO"
        )
      ),
      shiny::sliderInput(
        "layer",
        "Select depth (ft)",
        min = 5,
        max = 95,
        step = 5,
        value = 5
      ),
      shiny::dateInput(
        "date",
        "Select date",
        min = "1995-01-01",
        max = "1996-12-31",
        value = "1995-01-01"
      )
    )
  ),
  bslib::nav_panel(
    "Map",
    bslib::card(
      full_screen = TRUE,
      mapgl::maplibreOutput("map") |>
        shinycssloaders::withSpinner(
          caption = "Loading...",
          color = "#8aba5e",
          color.background = "#00587c",
          hide.ui = FALSE
        ) |>
        bslib::as_fill_carrier()
    )
  ),
  bslib::nav_panel(
    "Histogram",
    bslib::card(
      full_screen = TRUE,
      shiny::plotOutput("hist")
    )
  )
)

server <- function(input, output, session) {
  selected_data <- shiny::reactive({
    slice_ncdf(input$layer, input$date)
  })


  output$map <- mapgl::renderMaplibre({
    init_map
  })

  shiny::observeEvent(
    input$select,
    update_map_paint(input, selected_data())
  )

  shiny::observeEvent(
    input$date,
    update_map_paint(input, selected_data())
  )

  # Need to clear the map layer if changing model depth as the plotting
  # domain is now different.
  shiny::observeEvent(
    input$layer,
    update_map_paint(input, selected_data(), clear = TRUE)
  )

  output$hist <- shiny::renderPlot({
    hist(selected_data()[[input$select]],
      xlab = input$select,
      main = NULL
    )
  })
}

shiny::shinyApp(ui, server)

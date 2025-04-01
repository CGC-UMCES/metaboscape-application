# This library utilizes the shiny, bslib, mapgl, tidync, and dplyr R packages
# Shiny reference: https://mastering-shiny.org/index.html

# Suppress messages from unused terra dependency to install the
#   codetools package.
suppressMessages(
  library(mapgl)
)

options(shiny.host = "0.0.0.0")

# Change this if you are in a development container and 20688 is in use
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

# Load initial maps
source("/home/R/maps.R")

### The app ###
ui <- bslib::page_navbar(
  title = "The Chesapeake Metaboscape v0.1.0",
  theme = bslib::bs_theme(brand = "/home/brand/_brand.yml"),
  bslib::nav_panel(
    "Map",
    bslib::layout_sidebar(
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
      ),
      sidebar = bslib::sidebar(
        bslib::card(
          shiny::selectInput(
            "select",
            "Select variable",
            choices = list(
              "Inst. Growth Rate" = "IGR", "Feeding Rate" = "MF",
              "Metabolic Rate" = "RM", "Temperature (C)" = "T",
              "Salinity (ppt)" = "S", "Dissolved Oxygen (mg/L)" = "DO"
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
            value = "1995-07-01"
          )
        )
      )
    )
  ),
  bslib::nav_panel(
    "Compare",
    bslib::layout_sidebar(
      bslib::card(
        full_screen = TRUE,
        mapgl::maplibreCompareOutput("compare") |>
          shinycssloaders::withSpinner(
            caption = "Loading...",
            color = "#8aba5e",
            color.background = "#00587c",
            hide.ui = FALSE
          ) |>
          bslib::as_fill_carrier()
      ),
      sidebar = bslib::sidebar(
        shiny::selectInput(
          "select_compare",
          "Select variable",
          choices = list(
            "Inst. Growth Rate" = "IGR", "Feeding Rate" = "MF",
            "Metabolic Rate" = "RM", "Temperature (C)" = "T",
            "Salinity (ppt)" = "S", "Dissolved Oxygen (mg/L)" = "DO"
          )
        )
      )
    )
  )
)

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

shiny::shinyApp(ui, server)

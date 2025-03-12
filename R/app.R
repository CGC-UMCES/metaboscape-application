# Shiny reference: https://mastering-shiny.org/index.html
library(shiny)
library(bslib)
library(mapgl)
library(tidync)
library(dplyr)

options(shiny.host = "0.0.0.0")
options(shiny.port = 20688)

# Metaboscape model output
wp <- tidync("R/big data/whiteperch_95_96.nc")

# Cell ID key of the CBP model domain. See R/CBP cell audit/cbp_cells.R
domain <- sf::st_read(
  "/home/R/working data/model_cells.geojson"
)

#' @param depth_ft The depth in feet: 5-95, a multiple of 5
#' @param date The date in the format "YYYY-MM-DD"
cut_ncdf <- function(depth_ft, date) {
  layer <- depth_ft / 5
  date <- paste0(date, "-00")

  domain |>
    inner_join(
      wp |>
        tidync::hyper_filter(
          Time = Time == date,
          Layer_N = index == layer
        ) |>
        tidync::hyper_tibble() |>
        dplyr::filter(nwcbox != -9999),
      by = join_by(cell == nwcbox)
    )
}

### The app ###
ui <- page_sidebar(
  title = "The Chesapeake Metaboscape",
  sidebar = sidebar(
    card(
      selectInput(
        "select",
        "Select data",
        choices = list(
          "IGR" = "IGR", "MF" = "MF", "RM" = "RM",
          "Temperature (C)" = "T", "Salinity (ppt)" = "S",
          "Dissolved Oxygen (mg/L)" = "DO"
        ),
        selected = "IGR"
      ),
      sliderInput(
        "layer",
        "Select depth (ft)",
        min = 5,
        max = 95,
        step = 5,
        value = 5
      ),
      dateInput(
        "date",
        "Select date",
        min = "1995-01-01",
        max = "1996-12-31",
        value = "1995-01-01"
      )
    )
  ),
  card(
    full_screen = TRUE,
    maplibreOutput("map")
  )
)

server <- function(input, output, session) {
  selected_data <- reactive({
    cut_ncdf(input$layer, input$date)
  })

  output$map <- renderMaplibre({
    maplibre(style = carto_style("positron")) |>
      fit_bounds(
        c(-77.46285, 36.71919, -75.38543, 39.63196)
      ) |>
      add_fill_layer(
        id = "domain",
        source = selected_data(),
        fill_color = interpolate(
          column = input$select,
          values = range(selected_data()[[input$select]], na.rm = TRUE),
          stops = c("blue", "red"),
          na_color = "lightgrey"
        ),
        fill_opacity = 0.5,
        fill_outline_color = "rgba(0, 0, 0, 0)",
        tooltip = input$select
      )
  })
}

shinyApp(ui, server)

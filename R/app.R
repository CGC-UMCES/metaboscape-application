# Shiny reference: https://mastering-shiny.org/index.html
library(shiny)
library(bslib)
library(mapgl)
library(tidync)

options(shiny.host = "0.0.0.0")
options(shiny.port = 20688)

wp <- tidync("R/big data/whiteperch_95_96.nc")

domain <- sf::st_read(
  "/home/R/Chesapeake_Bay_Water_Quality_Modeling_cells.geojson"
)

ui <- page_sidebar(
  title = "The Chesapeake Metaboscape",
  sidebar = sidebar(
    card(
      selectInput(
        "select",
        "Select data",
        choices = list("Depth" = 1, "IGR" = 2, "MR" = 3, "RM" = 4),
        selected = 1
      )
    ),
    card(
      dateInput("date", "Select date", value = "1995-01-01")
    )
  ),
  card(
    full_screen = TRUE,
    maplibreOutput("map")
  )
)

server <- function(input, output, session) {
  output$map <- renderMaplibre({
    maplibre(style = carto_style("positron")) |>
      fit_bounds(
        c(-77.46285, 36.71919, -75.38543, 39.63196)
      ) |>
      add_fill_layer(
        id = "domain",
        source = domain,
        fill_color = interpolate(
          column = "DEPTH",
          values = range(domain$DEPTH, na.rm = TRUE),
          stops = c("blue", "red"),
          na_color = "lightgrey"
        ),
        fill_opacity = 0.5,
        fill_outline_color = "rgba(0, 0, 0, 0)",
        tooltip = "DEPTH"
      )
  })
}

shinyApp(ui, server)

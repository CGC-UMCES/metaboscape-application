# Shiny reference: https://mastering-shiny.org/index.html
library(shiny)
library(bslib)
library(mapgl)

options(shiny.host = "0.0.0.0")
options(shiny.port = 20688)

domain <- sf::st_read(
    "/home/R/Chesapeake_Bay_Water_Quality_Modeling_cells.geojson"
)

ui <- page_sidebar(
    title = "The Chesapeake Metaboscape",
    sidebar = sidebar(),
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
                fill_color = "pink",
                fill_opacity = 0.5,
                fill_outline_color = "gray"
            )
    })
}

shinyApp(ui, server)

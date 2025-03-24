# This library utilizes the shiny, bslib, mapgl, tidync, and dplyr R packages
# Shiny reference: https://mastering-shiny.org/index.html

# Suppress messages from unused terra dependency to install the codetools package.
suppressMessages(
  library(mapgl)
)

options(shiny.host = "0.0.0.0")
options(shiny.port = 20688)

# Metaboscape model output
wp <- tidync::tidync(
  "/home/data/whiteperch_95_96.nc"
)

# Cell ID key of the CBP model domain. See misc/CBP cell audit/cbp_cells.R
domain <- sf::st_read(
  "/home/data/model_cells.geojson",
  quiet = TRUE
)

#' Slice NetCDF file according to depth and date inputs and extract pertinent
#' cells of the model domain
#'
#' @param depth_ft The depth in feet: 5-95, a multiple of 5
#' @param date The date in the format "YYYY-MM-DD"
slice_ncdf <- function(depth_ft, date) {
  layer <- depth_ft / 5
  date <- paste0(date, "-00")

  domain |>
    # Select only those cells with data in both model domain and model output
    dplyr::inner_join(
      # Slice NCDF file
      wp |>
        tidync::hyper_filter(
          Time = Time == date,
          Layer_N = index == layer
        ) |>
        tidync::hyper_tibble() |>
        # Remove cells with no data
        dplyr::filter(nwcbox != -9999),
      # Cells are labeled "cell" in model domain and "nwcbox" in model output
      by = dplyr::join_by(cell == nwcbox)
    ) |>
    dplyr::mutate(
      dplyr::across(IGR:S, ~ signif(.x, 3))
    )
}

### The app ###
ui <- bslib::page_navbar(
  title = "The Chesapeake Metaboscape",
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
      mapgl::maplibreOutput("map")
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
  init_data <- slice_ncdf(5, "1995-01-01")

  output$map <- mapgl::renderMaplibre({
    mapgl::maplibre(
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
  })

  shiny::observeEvent(
    input$select,
    {
      mapgl::maplibre_proxy("map") |>
        mapgl::set_view(
          center = input$map_center,
          zoom = input$map_zoom
        ) |>
        mapgl::set_paint_property(
          layer = "domain",
          name = "fill-color",
          value = mapgl::interpolate(
            column = input$select,
            values = range(
              selected_data()[[input$select]],
              na.rm = TRUE
            ),
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
          values = range(
            selected_data()[[input$select]],
            na.rm = TRUE
          )
        )
    }
  )

  shiny::observeEvent(
    input$date,
    {
      mapgl::maplibre_proxy("map") |>
        mapgl::set_view(
          center = input$map_center,
          zoom = input$map_zoom
        ) |>
        mapgl::set_paint_property(
          layer = "domain",
          name = "fill-color",
          value = mapgl::interpolate(
            column = input$select,
            values = range(
              selected_data()[[input$select]],
              na.rm = TRUE
            ),
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
          values = range(
            selected_data()[[input$select]],
            na.rm = TRUE
          )
        )
    }
  )

  # Need to clear the map layer if changing model depth as the plotting
  # domain is now different.
  shiny::observeEvent(
    input$layer,
    {
      mapgl::maplibre_proxy("map") |>
        mapgl::set_view(
          center = input$map_center,
          zoom = input$map_zoom
        ) |>
        mapgl::clear_layer("domain") |>
        mapgl::add_fill_layer(
          id = "domain",
          source = selected_data(),
          fill_color = mapgl::interpolate(
            column = input$select,
            values = range(
              selected_data()[[input$select]],
              na.rm = TRUE
            ),
            stops = c("blue", "red"),
            na_color = "lightgrey"
          ),
          fill_opacity = 0.8,
          tooltip = input$select
        ) |>
        mapgl::add_legend(
          legend_title = input$select,
          type = "continuous",
          colors = c("blue", "red"),
          values = range(
            selected_data()[[input$select]],
            na.rm = TRUE
          )
        )
    }
  )

  output$hist <- shiny::renderPlot({
    hist(selected_data()[[input$select]],
      xlab = input$select,
      main = NULL
    )
  })
}

shiny::shinyApp(ui, server)

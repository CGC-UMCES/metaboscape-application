ui <- bslib::page_navbar(
  title = "The Chesapeake Metaboscape v0.1.1",
  theme = bslib::bs_theme(brand = "brand/_brand.yml"),
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

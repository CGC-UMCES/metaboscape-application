#' Slice NetCDF file according to depth and date inputs and extract pertinent
#' cells of the model domain
#'
#' @param depth_ft The depth in feet: 5-95, a multiple of 5
#' @param date The date in the format "YYYY-MM-DD"
slice_ncdf <- function(depth_ft, date) {
  layer <- depth_ft / 5
  date <- paste0(date, "-00")

  # Select cells in the correct layer
  sf::st_read(
    "/home/data/model_cells.gpkg",
    query = sprintf(
      "SELECT * FROM model_cells WHERE layer_index = %d",
      (19:1)[layer]
    ),
    quiet = TRUE
  ) |>
    dplyr::left_join(
      # Slice NCDF file
      wp |>
        tidync::hyper_filter(
          Time = Time == date,
          Layer_N = index == layer
        ) |>
        tidync::hyper_tibble(),
      # Cells are labeled "cell" in model domain and "nwcbox" in model output
      by = dplyr::join_by(cell == nwcbox)
    ) |>
    dplyr::mutate(
      dplyr::across(IGR:S, ~ signif(.x, 3))
    )
}

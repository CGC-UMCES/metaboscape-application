# This library utilizes the shiny, bslib, mapgl, tidync, and dplyr R packages
# Shiny reference: https://mastering-shiny.org/index.html

# Suppress messages from unused terra dependency to install the
#   codetools package.
suppressMessages(
  library(mapgl)
)


# Load data and functions
## Load helper functions
sapply(
  list.files("R/helpers", full.names = TRUE),
  source
)

## Load metaboscape model output
wp <- tidync::tidync(
  "data/whiteperch_95_96.nc"
)

## Load initial maps
source("R/maps.R")

## Load UI and server logic
source("R/ui.R")
source("R/server.R")


# Run application
## Set application host address and port
options(shiny.host = "0.0.0.0", shiny.port = 20688)

## Run application
shiny::shinyApp(ui, server)

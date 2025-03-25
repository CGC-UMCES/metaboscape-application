FROM rhub/r-minimal

# https://specs.opencontainers.org/image-spec/annotations/
LABEL \
    org.opencontainers.image.authors="Michael O'Brien <obrien@umces.edu>; Theresa Murphy <tmurphy@umces.edu>" \
    org.opencontainers.image.vendor="University of Maryland Center for Environmental Science" \
    org.opencontainers.image.version="0.0.999"



# Install R packages
## sf
RUN installr -d \
      -t "openssl-dev linux-headers gfortran proj-dev gdal-dev sqlite-dev geos-dev udunits-dev" \
      -a "libssl3 proj gdal geos expat udunits" \
      sf Rcppcore/Rcpp

## tidync and dplyr (dependency of tidync)
RUN installr -d \
      -t "netcdf-dev" \
      -a "netcdf" \
      tidync Rcppcore/Rcpp

## mapgl
RUN installr -d \
      mapgl Rcppcore/Rcpp

## shiny and bslib (dependency of shiny)
RUN installr -d \
      -t "zlib-dev" \
      shiny Rcppcore/Rcpp

## shinycssloaders
RUN installr -d shinycssloaders

## Cairo and fonts are needed to plot without X11; r-minimal does not have X11
RUN installr -d -e \
      -t "zlib-dev cairo-dev" \
      -a "cairo font-liberation" \
      Cairo


# Make application directories
RUN mkdir /home/R /home/data

# Expose the port
EXPOSE 20688

# Add a dummy user to avoid running as root
RUN addgroup -S myuser && adduser -S -G myuser myuser

# Switch to the dummy user
USER myuser

# Run application
CMD [ "Rscript", "/home/R/app.R" ]
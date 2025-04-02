FROM rhub/r-minimal

# https://specs.opencontainers.org/image-spec/annotations/
LABEL \
    org.opencontainers.image.authors="Michael O'Brien <obrien@umces.edu>; Theresa Murphy <tmurphy@umces.edu>" \
    org.opencontainers.image.vendor="University of Maryland Center for Environmental Science" \
    org.opencontainers.image.version="0.0.999"



# Install R packages (grouped by needed system dependencies)
## sf and Rcpp (needed to compile)
RUN installr -d \
      -t "openssl-dev linux-headers gfortran proj-dev gdal-dev sqlite-dev geos-dev udunits-dev" \
      -a "libssl3 proj gdal geos expat udunits" \
      sf Rcppcore/Rcpp

## tidync and dplyr (dependency of tidync)
RUN installr -d \
      -t "netcdf-dev" \
      -a "netcdf" \
      tidync

## mapgl
RUN installr -d mapgl

## shiny and bslib (dependency of shiny)
## Cairo and fonts are needed to plot without X11; r-minimal does not have X11
RUN installr -d \
      -t "zlib-dev cairo-dev" \
      -a "cairo font-liberation" \
      shiny Cairo

## shinycssloaders
RUN installr -d shinycssloaders


# Make application directories
RUN mkdir /home/R /home/data /home/brand

# Expose the port
EXPOSE 20688

# Add a dummy user to avoid running as root
RUN addgroup -S myuser && adduser -S -G myuser myuser

# Switch to the dummy user
USER myuser
WORKDIR /home/R

# Run application
CMD [ "Rscript", "/home/R/app.R" ]

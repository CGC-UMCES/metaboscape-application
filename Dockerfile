FROM rhub/r-minimal

# https://specs.opencontainers.org/image-spec/annotations/
LABEL \
    org.opencontainers.image.authors="Michael O'Brien <obrien@umces.edu>; Theresa Murphy <tmurphy@umces.edu>" \
    org.opencontainers.image.vendor="University of Maryland Center for Environmental Science" \
    org.opencontainers.image.version="0.0.999"


### Install R packages ###

# If adding/removing R packages, run the following to retain the build log:
#   docker build --progress=plain --no-cache -t temp . 2>&1 | tee build.log
# Look at the output of pak. It will tell you what system packages are needed.
# So, below, sf needs gdal-dev, gdal-tools, geos-dev, proj-dev, and sqlite-dev.
# All are already installed via the arguments below EXCEPT gdal-tools, so add that
# to `installr -t` or `installr -a`
#   sf 1.0-20 [bld][cmp][dl] (4.49 MB) + ✔ gdal-dev, ✖ gdal-tools, ✔ geos-dev, ✔ proj-dev, ✔ sqlite-dev


# openssl-dev:udunits-dev for sf and dependencies
# netcdf-dev:icu-dev for tidync and dependencies
# zlib-dev for shiny
# cairo-dev for Cairo (needed to plot without X11; r-minimal does not have X11)
ARG temp_system_packages="openssl-dev linux-headers gfortran proj-dev gdal-dev\
 gdal-tools sqlite-dev geos-dev udunits-dev netcdf-dev icu-dev zlib-dev cairo-dev"

# libssl3:udunits for sf and dependencies
# netcdf:icu for tidync and dependencies
# cairo:font-liberation for shiny and Cairo
ARG keep_system_packages="libssl3 proj gdal geos expat udunits netcdf icu\
 cairo font-liberation"

RUN installr -d \
      -t "$temp_system_packages" \
      -a "$keep_system_packages" \
      sf Rcppcore/Rcpp tidync shiny Cairo shinycssloaders mapgl

######


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
# using r2u for precompiled binaries
FROM rocker/r2u

# https://specs.opencontainers.org/image-spec/annotations/
LABEL \
    org.opencontainers.image.authors="Michael O'Brien <obrien@umces.edu>; Theresa Murphy <tmurphy@umces.edu>" \
    org.opencontainers.image.vendor="University of Maryland Center for Environmental Science" \
    org.opencontainers.image.version="0.0.999"

# Add a dummy user to avoid running as root
RUN groupadd -r myuser && useradd -r -m -g myuser myuser

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    r-cran-shiny \
    r-cran-bslib \
    r-cran-mapgl \
    r-cran-tidync \
    r-cran-dplyr

RUN mkdir /home/R

EXPOSE 20688

# switch to the dummy user
USER myuser

CMD [ "Rscript", "/home/R/app.R"]
# using r2u for precompiled binaries
FROM rocker/r2u

# https://specs.opencontainers.org/image-spec/annotations/
LABEL \
    org.opencontainers.image.authors="Michael O'Brien <obrien@umces.edu>; Theresa Murphy <tmurphy@umces.edu>" \
    org.opencontainers.image.vendor="University of Maryland Center for Environmental Science" \
    org.opencontainers.image.version="0.0.999"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    r-cran-shiny \
    r-cran-bslib \
    r-cran-mapgl \
    r-cran-tidync 

RUN mkdir /home/R

EXPOSE 20688

CMD [ "Rscript", "/home/R/app.R"]
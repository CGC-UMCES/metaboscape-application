# Chesapeake Bay Metaboscape Forecasting

This repository contains code for the Chesapeake Bay Metaboscape visualization
application at <https://metaboscape.cbl.umces.edu>, funded by a donation from
the Merrill Family Foundation to the Chesapeake Global Collaboratory of the
University of Maryland Center for Environmental Science.

The application is still very much a work in progress. A few notes for developers,
in the meantime:

## Development
 - Edit application at `R/app.R`
 - Serve application (see below)
 - Repeat.

Note that the image is currently 420MB and takes 6 minutes to build.

If developing on the Chesapeake Biological Laboratory server you will need to
change the port in the
[docker compose file](https://github.com/CGC-UMCES/metaboscape-application/blob/main/docker-compose.yaml#L8)
or `docker run` command from `20688:20688` to `someothernumber:20688`, as the
toy application is currently running on `20688`. Depending on your development
environment, you might need to change the port in
[`R/app.R`](https://github.com/CGC-UMCES/metaboscape-application/blob/9c34d4828e1ca494e108be57956d57ca240671b7/R/app.R#L9) 
instead. Don't hesitate to reach out with questions regarding this!

## Misc. container navigation
### Build image
```
docker build -t app .
```

### Open container
```
docker run -it \
  -v ./R:/home/R -v ./data:/home/data -v ./brand:/home/brand \
  app bash
```

### Open directly into R
```
docker run -it \
  -v ./R:/home/R -v ./data:/home/data -v ./brand:/home/brand \
  app R
```

### Serve application
```
docker compose up -d
```

or

```
docker run --rm --name metabo_app -d \
  -v ./R:/home/R -v ./data:/home/data -v ./brand:/home/brand \
  -p 20688:20688 \
  app
```

Navigate to: http://localhost:20688/
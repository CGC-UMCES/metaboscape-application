# Chesapeake Bay Metaboscape Forecasting

This is still very much a work in progress. A few notes for developers, in the 
meantime:

## Development
 - Edit application at `R/app.R`
 - Serve application (see below)
 - Repeat.

## Misc. container navigation
### Build container
```
docker build -t app .
```

### Open container
```
docker run -it -v ./R:/home/R -p 20688:20688 app bash
```

### Open directly into R
```
docker run -it -v ./R:/home/R -p 20688:20688 app R
```

### Serve application
```
docker run --rm -d -v ./R:/home/R -p 20688:20688 app
```
Navigate to: http://127.0.0.1:20688/
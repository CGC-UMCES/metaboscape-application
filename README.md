# Chesapeake Bay Metaboscape Forecasting

This is still very much a work in progress. A few notes for developers, in the 
meantime:

## Build container
```
docker build -t app .
```

## Open directly into R
```
docker run -it -v ./R:/home/R -p 20688:20688 app R
```

## Serve application
```
docker run --rm -v ./R:/home/R -p 20688:20688 app
```
Navigate to: http://127.0.0.1:20688/

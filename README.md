# scraping
A collection of simple scripts that were used in the past for scraping meteorological data from the internet.

## Download and process NCEP reanalysis

Something like this will work:

```
library(scraping)
coor <- data.frame(lon=13.40,lat=52.52)
var <- c('temperature','relative humidity')
years <- c('2000','2001')

request <- def_request(coor,var,years)

get_nc(request)

nc2rds(request)

```

Variables are available from two datasets. From NCEP such as: `temperature`,`relative humidity`,`u wind`,`v wind`,`soil heat flux`,`net radiation` or `precipitation rate`. And from [GPCC](http://dx.doi.org/10.5676/DWD_GPCC/FD_D_V2018_100) such as `gpcc precipitation` and `number of gauges`.

Please have a look at the [vignette](vignettes/scraping1.md) for more details.

## pluviopt
A [rvest](https://blog.rstudio.com/2014/11/24/rvest-easy-web-scraping-with-r/) based package to harvest near real-time pluviometry data from SNIRH/Portugal.

Data is publicly available at [SNIRH](http://snirh.apambiente.pt/) from the Portuguese Environemntal Agency. Right now it is possible to obtain rainfall data from the telemetry database. Objective is to make it easier to retrieve data from the website directly into an R workflow. Work in progress...

## download_hidroweb.py

A selenium-based script for downloading the complete time-series of hundreds of hydro-meteorological stations in the São Francisco river basin.

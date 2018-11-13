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

Please have a look at the [vignette](vignettes/get_ncep_reanalysis.html) in a browser for more details.

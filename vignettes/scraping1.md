NCEP example
================
JM Delgado
2018-12-12

Define request, download and convert from ncdf to data frame and save
---------------------------------------------------------------------

`var` should be a meteorological variable name as a string. Variables are available from two datasets. From NCEP such as: `temperature`,`relative humidity`,`u wind`,`v wind`,`soil heat flux`,`net radiation` or `precipitation rate`. And from [GPCC](http://dx.doi.org/10.5676/DWD_GPCC/FD_D_V2018_100) such as `gpcc precipitation` and `number of gauges`.

### Define request

``` r
library(scraping)
```

Insert coordinates as points:

``` r
coor <- data.frame(lon=c(13.40,13.91),lat=c(52.52,52.90))
```

...or as left, right, bottom and top extents of your region of interest:

``` r
coor <- data.frame(l=12,r=14,b=50,t=53)
```

Choose years and variables

``` r
var <- c('temperature','gpcc precipitation')
years <- c('2000','2001')
setwd('/home/delgado/proj/scraping')
request <- def_request(coor,var,years)
#> Joining, by = "varname"
knitr::kable(request)
```

| year | variable           | varname | dataset | prefix                                                           | fname                    | geometry                                        |
|:-----|:-------------------|:--------|:--------|:-----------------------------------------------------------------|:-------------------------|:------------------------------------------------|
| 2000 | temperature        | air     | ncep    | <ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis/surface_gauss/> | air.2m.gauss             | list(c(12, 14, 14, 12, 12, 50, 50, 53, 53, 50)) |
| 2000 | gpcc precipitation | precip  | gpcc    | <ftp://ftp.dwd.de/pub/data/gpcc/full_data_daily_V2018/>          | full\_data\_daily\_v2018 | list(c(12, 14, 14, 12, 12, 50, 50, 53, 53, 50)) |
| 2001 | temperature        | air     | ncep    | <ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis/surface_gauss/> | air.2m.gauss             | list(c(12, 14, 14, 12, 12, 50, 50, 53, 53, 50)) |
| 2001 | gpcc precipitation | precip  | gpcc    | <ftp://ftp.dwd.de/pub/data/gpcc/full_data_daily_V2018/>          | full\_data\_daily\_v2018 | list(c(12, 14, 14, 12, 12, 50, 50, 53, 53, 50)) |

### Download and convert from ncdf to data frame and save

``` r

get_nc(request)

nc2rds(request)
```

### Print metadata

``` r
get_nc_meta(request,var)
```

air.2m.gauss.2000.nc not found.

Load rds data examples
----------------------

``` r
library(scraping)
library(dplyr)
library(lubridate)
lookup=lookup_var(request$variable)

lookup %>% knitr::kable()
```

| variable           | varname |
|:-------------------|:--------|
| temperature        | air     |
| gpcc precipitation | precip  |

``` r

myproj='/home/delgado/proj/scraping/'

df1=readRDS(paste0(myproj,lookup$varname[1],'.rds'))
df2=readRDS(paste0(myproj,lookup$varname[2],'.rds'))

head(df2) %>% knitr::kable()
```

|   lon|   lat| time       |     value| var    | dataset |
|-----:|-----:|:-----------|---------:|:-------|:--------|
|  12.5|  50.5| 2000-01-01 |  5.205224| precip | gpcc    |
|  13.5|  50.5| 2000-01-01 |  2.517535| precip | gpcc    |
|  12.5|  51.5| 2000-01-01 |  1.775673| precip | gpcc    |
|  13.5|  51.5| 2000-01-01 |  1.823611| precip | gpcc    |
|  12.5|  52.5| 2000-01-01 |  3.002200| precip | gpcc    |
|  13.5|  52.5| 2000-01-01 |  1.986066| precip | gpcc    |

Compute daily maxima if it applies (for example temperature and relative humidity, not precipitation rate or net radiation, which is given as daily values):

``` r
df1 %>%
    group_by(day=floor_date(time,"day")) %>%
    summarise(daily_max=max(value),daily_min=min(value),daily_mean=mean(value),varname=first(varname)) %>%  
    head() %>%
    knitr::kable()
```

| day        |  daily\_max|  daily\_min|  daily\_mean| varname |
|:-----------|-----------:|-----------:|------------:|:--------|
| 2000-01-01 |       274.7|       262.7|     270.9250| gflux   |
| 2000-01-02 |       275.2|       269.2|     272.6312| gflux   |
| 2000-01-03 |       276.7|       270.1|     273.6250| gflux   |
| 2000-01-04 |       277.2|       272.7|     275.0250| gflux   |
| 2000-01-05 |       277.1|       269.3|     273.5875| gflux   |
| 2000-01-06 |       276.7|       267.4|     272.2687| gflux   |

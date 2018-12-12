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
setwd('/home/delgado/proj/scraping')
get_nc_meta(request,var[2])
```

$long\_name \[1\] "gpcc full data daily product version 2018 precipitation per grid"

$units \[1\] "mm/day"

$code \[1\] 20

$`_FillValue` \[1\] -9999

$missing\_value \[1\] -9999

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
    group_by(day=floor_date(time,"day"),lon,lat) %>%
    summarise(daily_max=max(value),daily_min=min(value),daily_mean=mean(value),var=first(var)) %>%  
    head() %>%
    knitr::kable()
```

| day        |     lon|      lat|  daily\_max|  daily\_min|  daily\_mean| var         |
|:-----------|-------:|--------:|-----------:|-----------:|------------:|:------------|
| 2000-01-01 |  13.125|  50.4752|       273.6|       265.7|      271.050| temperature |
| 2000-01-01 |  13.125|  52.3799|       274.7|       268.6|      272.625| temperature |
| 2000-01-01 |  15.000|  50.4752|       271.5|       262.7|      268.900| temperature |
| 2000-01-01 |  15.000|  52.3799|       273.2|       267.3|      271.125| temperature |
| 2000-01-02 |  13.125|  50.4752|       273.5|       271.1|      272.475| temperature |
| 2000-01-02 |  13.125|  52.3799|       275.2|       273.1|      274.425| temperature |

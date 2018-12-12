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
var <- c('soil heat flux','gpcc precipitation')
years <- c('2000','2001')
setwd('/home/delgado/proj/scraping')
request <- def_request(coor,var,years)
#> Joining, by = "varname"
knitr::kable(request)
```

| year | variable           | varname | dataset | prefix                                                                     | fname                    | geometry                                        |
|:-----|:-------------------|:--------|:--------|:---------------------------------------------------------------------------|:-------------------------|:------------------------------------------------|
| 2000 | soil heat flux     | gflux   | ncep    | <ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface_gauss/> | gflux.sfc.gauss          | list(c(12, 14, 14, 12, 12, 50, 50, 53, 53, 50)) |
| 2000 | gpcc precipitation | precip  | gpcc    | <ftp://ftp.dwd.de/pub/data/gpcc/full_data_daily_V2018/>                    | full\_data\_daily\_v2018 | list(c(12, 14, 14, 12, 12, 50, 50, 53, 53, 50)) |
| 2001 | soil heat flux     | gflux   | ncep    | <ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface_gauss/> | gflux.sfc.gauss          | list(c(12, 14, 14, 12, 12, 50, 50, 53, 53, 50)) |
| 2001 | gpcc precipitation | precip  | gpcc    | <ftp://ftp.dwd.de/pub/data/gpcc/full_data_daily_V2018/>                    | full\_data\_daily\_v2018 | list(c(12, 14, 14, 12, 12, 50, 50, 53, 53, 50)) |

### Download and convert from ncdf to data frame and save

``` r

get_nc(request)

nc2rds(request)

get_nc_meta(request,var)
```

Load rds data examples
----------------------

``` r
library(scraping)
library(dplyr)
library(lubridate)
varname=lookup_var(request$variable) %>% pull(varname)

varname %>% knitr::kable()
```

| x      |
|:-------|
| gflux  |
| precip |

``` r

myproj='/home/delgado/proj/scraping/'

df1=readRDS(paste0(myproj,varname[1],'.rds'))

head(df1) %>% knitr::kable()
```

|     lon|      lat| time       |      value| var   | dataset |
|-------:|--------:|:-----------|----------:|:------|:--------|
|  13.125|  52.3799| 2000-01-01 |  13.000000| gflux | ncep    |
|  15.000|  52.3799| 2000-01-01 |   4.899902| gflux | ncep    |
|  13.125|  50.4752| 2000-01-01 |   5.699951| gflux | ncep    |
|  15.000|  50.4752| 2000-01-01 |   6.899902| gflux | ncep    |
|  13.125|  52.3799| 2000-01-02 |   4.500000| gflux | ncep    |
|  15.000|  52.3799| 2000-01-02 |   3.699951| gflux | ncep    |

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
| 2000-01-01 |   13.000000|   4.8999023|     7.624939| gflux   |
| 2000-01-02 |    4.500000|   3.3999023|     3.949951| gflux   |
| 2000-01-03 |    3.899902|  -0.3000488|     2.724915| gflux   |
| 2000-01-04 |    3.699951|   1.1999512|     2.574951| gflux   |
| 2000-01-05 |   17.399902|   5.6999512|    11.824951| gflux   |
| 2000-01-06 |   16.399902|   2.3999023|     7.799927| gflux   |

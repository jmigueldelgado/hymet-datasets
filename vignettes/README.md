NCEP example
================
JM Delgado
2018-12-11

Define request, download and convert from ncdf to data frame and save
---------------------------------------------------------------------

`var` should be a meteorological variable name as a string such as `temperature`,`relative humidity`,`u wind`,`v wind`,`soil heat flux`,`net radiation` or `precipitation rate`.

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
var <- c('precipitation rate')
years <- c('2000','2001')
setwd('/home/delgado/proj/scraping')
request <- def_request(coor,var,years)
#> Joining, by = "varname"
knitr::kable(request)
```

| year | variable           | varname | prefix                                                                     | fname           | geometry                               |
|:-----|:-------------------|:--------|:---------------------------------------------------------------------------|:----------------|:---------------------------------------|
| 2000 | precipitation rate | prate   | <ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface_gauss/> | prate.sfc.gauss | 12, 14, 14, 12, 12, 50, 50, 53, 53, 50 |
| 2001 | precipitation rate | prate   | <ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface_gauss/> | prate.sfc.gauss | 12, 14, 14, 12, 12, 50, 50, 53, 53, 50 |

### Download and convert from ncdf to data frame and save

``` r

get_nc(request)

nc2rds(request)
```

Load rds data examples
----------------------

### Load air temperature

``` r
library(scraping)
library(dplyr)
library(lubridate)

varname=lookup_var(var) %>% pull(varname)

myproj='/home/delgado/proj/scraping/'

df1=readRDS(paste0(myproj,varname,'.rds'))

head(df1) %>% knitr::kable()
```

|     lon|      lat| time       |     value| var                |
|-------:|--------:|:-----------|---------:|:-------------------|
|  13.125|  52.3799| 2000-01-01 |  1.17e-05| precipitation rate |
|  15.000|  52.3799| 2000-01-01 |  1.50e-05| precipitation rate |
|  13.125|  50.4752| 2000-01-01 |  4.07e-05| precipitation rate |
|  15.000|  50.4752| 2000-01-01 |  2.22e-05| precipitation rate |
|  13.125|  52.3799| 2000-01-02 |  1.90e-06| precipitation rate |
|  15.000|  52.3799| 2000-01-02 |  6.90e-06| precipitation rate |

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
| 2000-01-01 |    4.07e-05|    1.17e-05|     2.24e-05| prate   |
| 2000-01-02 |    3.17e-05|    1.90e-06|     1.33e-05| prate   |
| 2000-01-03 |    3.37e-05|    1.00e-07|     1.17e-05| prate   |
| 2000-01-04 |    6.02e-05|    2.80e-05|     3.73e-05| prate   |
| 2000-01-05 |    1.92e-05|    1.70e-06|     9.30e-06| prate   |
| 2000-01-06 |    2.30e-06|    3.00e-07|     8.00e-07| prate   |

NCEP example
================
JM Delgado
2018-11-29

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
var <- c('temperature')
years <- c('2008')
setwd('/home/delgado/proj/scraping')
request <- def_request(coor,var,years)
#> Joining, by = "varname"
knitr::kable(request)
```

| year | variable    | varname | prefix                                                           | fname        | geometry                               |
|:-----|:------------|:--------|:-----------------------------------------------------------------|:-------------|:---------------------------------------|
| 2008 | temperature | air     | <ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis/surface_gauss/> | air.2m.gauss | 12, 14, 14, 12, 12, 50, 50, 53, 53, 50 |

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
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(lubridate)
#> 
#> Attaching package: 'lubridate'
#> The following object is masked from 'package:base':
#> 
#>     date

var=lookup_var('temperature') %>% pull(varname)

myproj='/home/delgado/proj/scraping/'

df1=readRDS(paste0(myproj,var,'.rds'))

head(df1) %>% knitr::kable()
```

|     lon|      lat| time                |   value| var         |
|-------:|--------:|:--------------------|-------:|:------------|
|  13.125|  52.3799| 2008-01-01 00:00:00 |  271.50| temperature |
|  15.000|  52.3799| 2008-01-01 00:00:00 |  271.80| temperature |
|  13.125|  50.4752| 2008-01-01 00:00:00 |  271.00| temperature |
|  15.000|  50.4752| 2008-01-01 00:00:00 |  271.21| temperature |
|  13.125|  52.3799| 2008-01-01 06:00:00 |  273.30| temperature |
|  15.000|  52.3799| 2008-01-01 06:00:00 |  273.71| temperature |

``` r

df1 %>%
    group_by(day=floor_date(time,"day")) %>%
    summarise(daily_max=max(value),daily_min=min(value),daily_mean=mean(value),var=first(var)) %>%  
    head() %>%
    knitr::kable()
```

| day        |  daily\_max|  daily\_min|  daily\_mean| var         |
|:-----------|-----------:|-----------:|------------:|:------------|
| 2008-01-01 |      273.71|      259.90|     268.7456| temperature |
| 2008-01-02 |      271.21|      264.40|     267.9656| temperature |
| 2008-01-03 |      270.00|      264.10|     266.8962| temperature |
| 2008-01-04 |      273.10|      265.30|     268.9025| temperature |
| 2008-01-05 |      274.60|      269.71|     272.9637| temperature |
| 2008-01-06 |      276.80|      272.90|     274.3706| temperature |

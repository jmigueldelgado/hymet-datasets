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
var <- c('net radiation')
years <- c('2000','2001')
setwd('/home/delgado/proj/scraping')
request <- def_request(coor,var,years)
#> Joining, by = "varname"
knitr::kable(request)
```

| year | variable      | varname | prefix                                                                     | fname           | geometry                               |
|:-----|:--------------|:--------|:---------------------------------------------------------------------------|:----------------|:---------------------------------------|
| 2000 | net radiation | dswrf   | <ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface_gauss/> | dswrf.sfc.gauss | 12, 14, 14, 12, 12, 50, 50, 53, 53, 50 |
| 2001 | net radiation | dswrf   | <ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface_gauss/> | dswrf.sfc.gauss | 12, 14, 14, 12, 12, 50, 50, 53, 53, 50 |

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

var=lookup_var('net radiation') %>% pull(varname)

myproj='/home/delgado/proj/scraping/'

df1=readRDS(paste0(myproj,var,'.rds'))

head(df1) %>% knitr::kable()
```

|     lon|      lat| time       |     value| var           |
|-------:|--------:|:-----------|---------:|:--------------|
|  13.125|  52.3799| 2000-01-01 |  37.89990| net radiation |
|  15.000|  52.3799| 2000-01-01 |  44.89990| net radiation |
|  13.125|  50.4752| 2000-01-01 |  50.69995| net radiation |
|  15.000|  50.4752| 2000-01-01 |  59.00000| net radiation |
|  13.125|  52.3799| 2000-01-02 |  53.50000| net radiation |
|  15.000|  52.3799| 2000-01-02 |  51.50000| net radiation |

Compute daily maxima if it applies:

``` r
df1 %>%
    group_by(day=floor_date(time,"day")) %>%
    summarise(daily_max=max(value),daily_min=min(value),daily_mean=mean(value),var=first(var)) %>%  
    head() %>%
    knitr::kable()
```

| day        |  daily\_max|  daily\_min|  daily\_mean| var           |
|:-----------|-----------:|-----------:|------------:|:--------------|
| 2000-01-01 |    59.00000|     37.8999|     48.12494| net radiation |
| 2000-01-02 |    62.19995|     51.5000|     56.54999| net radiation |
| 2000-01-03 |    68.19995|     50.8999|     58.49994| net radiation |
| 2000-01-04 |    62.69995|     46.8999|     54.54993| net radiation |
| 2000-01-05 |    68.50000|     54.0000|     61.17499| net radiation |
| 2000-01-06 |    69.69995|     55.5000|     62.54999| net radiation |

NCEP example
================
JM Delgado
2018-11-27

Define request, download and convert from ncdf to data frame and save
---------------------------------------------------------------------

### Define request

``` r
library(scraping)
coor <- data.frame(lon=13.40,lat=52.52)
var <- c('temperature','relative humidity')
years <- c('2000','2001')

request <- def_request(coor,var,years)
#> Joining, by = "varname"
knitr::kable(request)
```

| year | variable          | varname | prefix                                                           | fname        | geometry       |
|:-----|:------------------|:--------|:-----------------------------------------------------------------|:-------------|:---------------|
| 2000 | temperature       | air     | <ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis/surface_gauss/> | air.2m.gauss | c(13.4, 52.52) |
| 2000 | relative humidity | rhum    | <ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis/surface/>       | rhum.sig995  | c(13.4, 52.52) |
| 2001 | temperature       | air     | <ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis/surface_gauss/> | air.2m.gauss | c(13.4, 52.52) |
| 2001 | relative humidity | rhum    | <ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis/surface/>       | rhum.sig995  | c(13.4, 52.52) |

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

| time                | var         |  value|     lon|      lat|
|:--------------------|:------------|------:|-------:|--------:|
| 2000-01-01 00:00:00 | temperature |  268.6|  13.125|  52.3799|
| 2000-01-01 06:00:00 | temperature |  273.0|  13.125|  52.3799|
| 2000-01-01 12:00:00 | temperature |  274.7|  13.125|  52.3799|
| 2000-01-01 18:00:00 | temperature |  274.2|  13.125|  52.3799|
| 2000-01-02 00:00:00 | temperature |  273.1|  13.125|  52.3799|
| 2000-01-02 06:00:00 | temperature |  274.8|  13.125|  52.3799|

``` r

df1 %>%
    group_by(day=floor_date(time,"day")) %>%
    summarise(daily_max=max(value),daily_min=min(value),daily_mean=mean(value),var=first(var)) %>%  
    head() %>%
    knitr::kable()
```

| day        |  daily\_max|  daily\_min|  daily\_mean| var         |
|:-----------|-----------:|-----------:|------------:|:------------|
| 2000-01-01 |       274.7|       268.6|      272.625| temperature |
| 2000-01-02 |       275.2|       273.1|      274.425| temperature |
| 2000-01-03 |       276.7|       274.4|      275.975| temperature |
| 2000-01-04 |       277.2|       275.2|      276.500| temperature |
| 2000-01-05 |       276.5|       272.1|      274.275| temperature |
| 2000-01-06 |       276.7|       270.9|      274.175| temperature |

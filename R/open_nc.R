library(tidync)
setwd('/home/delgado/proj/hymet-datasets')

## Import peaks
peaks=readr::read_csv('/home/delgado/proj/hymet-datasets/data/peak_coordinates_revised3_WGS84.csv')

ncfile <- "/home/delgado/proj/hymet-datasets/data/1979-01.nc"

DS=tidync(ncfile)

## ncmeta::nc_grids(ncfile)

ncmeta::nc_atts(ncfile,"time")$value

library(lubridate)
library(dplyr)
origin=ymd_hms("1900-01-01 00:00:00.0")

DS %>% hyper_tibble() %>% mutate(time=origin+hours(time))

lon=DS %>% activate("D0") %>% hyper_array()
lat=DS %>% activate("D1") %>% hyper_array()

## Find nearest grid point to peak
lon_i = list()
lat_i = list()
for(i in seq(1,nrow(peaks)))
{
    lon_i[[i]] = which.min(abs(lon$longitude-peaks$LON[i]))
    lat_i[[i]] = which.min(abs(lat$latitude-peaks$LAT[i]))
}

peaks$lon_i=unlist(lon_i)
peaks$lat_i=unlist(lat_i)

relevant_cells=unique(peaks[c('lon_i','lat_i')])

for(i in seq(1,nrow(relevant_cells)))
{
    
}

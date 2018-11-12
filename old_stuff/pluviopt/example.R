require(pluviopt)
require(readr)
require(dplyr)
require(lubridate)
require(rvest)
require(sf)

setwd("~/proj/pluviopt")
tbl <- get_stations_meteo()
#tbl <- get_stations_pluvio()
start <- "1/10/2000"
end <- "17/10/2017"

select(tbl,Nome)

x <- get_temp_web(tbl$ref[4],start,end) %>% group_by(date=date(datetime)) %>% summarise(value=mean(value))

x <- get_pluvio_web(tbl$ref[4],start,end %>% group_by(date=date(datetime)) %>% summarise(value=sum(value)))

require(ggplot2)
ggplot(x)+geom_line(aes(x=datetime,y=value))

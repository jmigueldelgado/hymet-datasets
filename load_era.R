## this works:
Sys.setenv(RETICULATE_PYTHON='/home/delgado/local/miniconda3/envs/ecmwf/bin/python')
library(reticulate)
py_config()
ecmwf <- import('ecmwfapi')

server = ecmwf$ECMWFDataServer
query = r_to_py(list(
  class='ei',
  dataset='interim',
  date='2018-01-01/to/2018-03-31',
  expver='1',
  grid='0.125/0.125',
  levtype='sfc',
  param='167.128', # air temperature (2m)
  area='45/-10/30/5', # N/W/S/E
  step='0',
  stream='oper',
  time='00/06/12/18',
  type='an',
  format='netcdf',
  target='ta201801-03.nc'
  ))

server$retrieve(query)

require(sf)
require(ncdf4)
require(dplyr)
require(lubridate)
require(tidyr)
require(ggplot2)

nc=nc_open('ta201801-03.nc')

lat=ncvar_get(nc,'latitude')
lon=ncvar_get(nc,'longitude')
dim(lat);
dim(lon);

t=ncvar_get(nc,'time')

ncatt_get(nc,'time')

timestamp=as_datetime(c(t*60*60),origin='1900-01-01')

data=ncvar)get(nc,'t2m')

nc_close(nc)

## does not work:
library(reticulate)
use_condaenv(condaenv = 'ecmwf', conda='/home/delgado/local/miniconda3/bin/conda')
py_config()
ecmwf <- import('ecmwfapi')

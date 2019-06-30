## this works, but make sure you copy .ecmwfapirc to your home directory (check 3.2 here: https://dominicroye.github.io/en/2018/access-to-climate-reanalysis-data-from-r/#connection-and-download-with-the-ecmwf-api):
Sys.setenv(RETICULATE_PYTHON='/home/delgado/local/miniconda3/envs/ecmwf/bin/python')
library(reticulate)
py_config()
ecmwf <- import('ecmwfapi')

server = ecmwf$ECMWFDataServer(verbose=TRUE)
query = r_to_py(list(
  class='ei',
  dataset='interim',
  date='2018-01-01/to/2018-01-02',
  expver='1',
  grid='0.125/0.125',
  levtype='sfc',
  param='167.128', # air temperature (2m), check parameter db in https://apps.ecmwf.int/codes/grib/param-db
  area='31/4/30/5', # N/W/S/E
  step='0',
  stream='oper',
  time='00/12',
  type='an',
  format='netcdf',
  target='era_test.nc'
  ))


server$retrieve(query)

v=get(load('./data/vartable.RData'))

library(scraping)


my_dataset='GPCC'
my_var='precipitation'

    require(dplyr)


vartable=tibble(variable='2 metre temperature',varname='165.128',dataset='era-interim') %>%
  bind_rows(v,.) %>% mutate(dataset=tolower(dataset))

  devtools::use_data(vartable,pkg='.')
  usethis::use_data(vartable,pkg='scraping')

  vartable




getwd()

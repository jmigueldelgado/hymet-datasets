## this works:
Sys.setenv(RETICULATE_PYTHON='/home/delgado/local/miniconda3/envs/ecmwf/bin/python')
library(reticulate)
py_config()
ecmwf <- import('ecmwfapi')

## does not work:
library(reticulate)
use_condaenv(condaenv = 'ecmwf', conda='/home/delgado/local/miniconda3/bin/conda')
py_config()
ecmwf <- import('ecmwfapi')

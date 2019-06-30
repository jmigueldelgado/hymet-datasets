#!/usr/bin/env python
from ecmwfapi import ECMWFDataServer

server = ECMWFDataServer()

server.retrieve({
    'stream'    : "oper",
    'levtype'   : "sfc",
    'param'     : "165.128/166.128/167.128",
    'dataset'   : "interim",
    'step'      : "0",
    'grid'      : "0.75/0.75",
    'time'      : "00/06/12/18",
    'date'      : "2014-07-01/to/2014-07-31",
    'type'      : "an",
    'class'     : "ei",
    'area'      : "73.5/-27/33/45",
    'format'    : "netcdf",
    'target'    : "interim_2014-07-01to2014-07-31_00061218.nc"
 })

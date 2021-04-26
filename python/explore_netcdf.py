import fiona
from shapely.geometry import shape, polygon, mapping, Point
import json
import pandas
from geopandas import GeoDataFrame
import geopandas
import numpy as np
from functools import reduce
import IPython
import xarray as xr
from urllib.request import urlopen

dataDIR = './data/test3.nc'
DS = xr.open_dataset(dataDIR)

# da=DS.u10.isel(latitude=10,longitude=10)

da=DS.u10.sel(latitude=88.0,longitude=28.0,method='nearest')
da=da.sel(time=slice('2018-01-01T00:00:00','2018-01-03T00:00:00'))
da.plot()

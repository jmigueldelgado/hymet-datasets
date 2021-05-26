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
from os import listdir
from os import path
# # Get the csv with peak location
# df=pandas.read_csv('./data/peak_coordinates_revised3_WGS84.csv')
# df_clean=df[(df.LON>-361) & (df.LAT>-91)]
# geometry = [Point(xy) for xy in zip(df_clean.LON, df_clean.LAT)]
# crs = {'init': 'epsg:4326'} #http://www.spatialreference.org/ref/epsg/2263/
# geo_df = GeoDataFrame(df_clean, crs=crs, geometry=geometry)

DS

ncdir=path.join(path.expanduser('~'),'proj','hymet-datasets','data','nc')
ncarray=listdir(ncdir)

def netcdf_open(ncpath):
    DS = xr.open_dataset(ncpath)
    return DS.assign(wind10m=(DS.u10**2+DS.v10**2)**0.5)

def daily_mean(da):
    return da.resample(time='1D').mean()

def daily_max(da):
    return da.resample(time='1D').max()

def daily_min(da):
    return da.resample(time='1D').min()

DSdailymean=list()
for ncfile in ncarray:
    DS=netcdf_open(path.join(ncdir,ncfile))
    DSdailymean.append(daily_mean(DS))

xr.concat(DSdailymean,'time').to_dataframe().to_csv(path.join(path.expanduser('~'),'proj','hymet-datasets','data','out','daily_mean.csv'))

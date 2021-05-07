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

# Get the csv with peak location
df=pandas.read_csv('./data/peak_coordinates_revised3_WGS84.csv')
df_clean=df[(df.LON>-361) & (df.LAT>-91)]
geometry = [Point(xy) for xy in zip(df_clean.LON, df_clean.LAT)]
crs = {'init': 'epsg:4326'} #http://www.spatialreference.org/ref/epsg/2263/
geo_df = GeoDataFrame(df_clean, crs=crs, geometry=geometry)


# dataDIR = './data/precipitation.nc'
dataDIR = './data/1979-01.nc'
DS = xr.open_dataset(dataDIR)

# da=DS.u10.isel(latitude=10,longitude=10)
DS

da=DS.sel(latitude=geo_df['LAT'],longitude=geo_df['LON'],method='nearest')
# da=da.sel(time=slice('2018-01-01T00:00:00','2018-01-03T00:00:00'))
da
# DS.time.dt.dayofweek

daily_mean=da.groupby("time.day").mean()
daily_max=da.groupby("time.day").max()

xr.concat([daily_mean,daily_mean],'time')

DSdaily=DS.groupby("time.day").mean()
DSdaily.tp.sel(latitude=88.0,longitude=28.0,method='nearest').to_dataframe()

df=DS.to_dataframe()

df.head()
df.groupby("time")
df.index
df.describe

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
df=pandas.read_csv('/home/delgado/proj/hymet-datasets/data/peak_coordinates_revised3_WGS84.csv')
df_clean=df[(df.LON>-361) & (df.LAT>-91)]
geometry = [Point(xy) for xy in zip(df_clean.LON, df_clean.LAT)]
crs = {'init': 'epsg:4326'} #http://www.spatialreference.org/ref/epsg/2263/
geo_df = GeoDataFrame(df_clean, crs=crs, geometry=geometry)
bounds=geo_df.buffer(0.5).total_bounds

# [north, west, south, east]
# bounds




import cdsapi
c = cdsapi.Client()

dataset = 'reanalysis-era5-single-levels'
# flag to download data
download_flag = True

dataset = 'reanalysis-era5-pressure-levels'
# params = {
#     'format': 'netcdf',
#     'product_type': 'reanalysis',
#     'variable': 'temperature',
#     'pressure_level':'1000',
#     'year':['2020'],
#     'month':['01','02'],
#     'day': ['01'],
#     'time': ['12:00'],
#     'grid': [0.25, 0.25],
#     'area': [49.38, -102.67, 47.84, -100.95],
#     }

params = {
    'format': 'netcdf',
    'product_type': 'reanalysis',
    'variable': 'temperature',
    'date': '2020-01-01',
    'hour': ['12:00','13:00','14:00'],
    'pressure_level':'1000',
    'grid': [0.25, 0.25],
    'area': [49.38, -102.67, 47.84, -100.95],
    }

params
# api parameters
# params = {
#     'format': 'netcdf',
#     'product_type': 'reanalysis',
#     'variable': '10m_u_component_of_wind',
#     # 'pressure_level':'1000',
#     'date': list(pandas.date_range('2020-01-01 12:00','2020-01-01 14:00', freq='H').strftime('%Y-%m-%d %H:%M')),
#     # 'year':['2020'],
#     # 'month':['01','02','03'],
#     # 'day': ['01'],
#     # 'time': ['12:00'],
#     'grid': [0.25, 0.25],
#     'area': [bounds[2],bounds[1],bounds[0],bounds[3]],
#     }

fl = c.retrieve(dataset, params)# download the file

if download_flag:
    fl.download("./output.nc")

# load into memory
with urlopen(fl.location) as f:
    ds = xr.open_dataset(f.read())

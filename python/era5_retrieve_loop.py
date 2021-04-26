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
bounds=geo_df.buffer(0.5).total_bounds


#!/usr/bin/env python3
import cdsapi

c = cdsapi.Client()

first_year = 1979
last_year = 1979
# last_year = 2020

# year=2018
# month=1

# from here: https://confluence.ecmwf.int/display/CKB/Climate+Data+Store+%28CDS%29+documentation#ClimateDataStore(CDS)documentation-Efficiencytips

# c.retrieve('reanalysis-era5-single-levels',request, "{year}-{month:02d}.nc".format(year=year, month=month))


for year in range(first_year, last_year + 1):
    for month in range(1, 13):
        print("=========================================================")
        print("Downloading {year}-{month:02d}".format(year=year, month=month))
        request={
            'product_type': 'reanalysis',
            'variable': [
                    '10m_u_component_of_wind', '10m_v_component_of_wind', '2m_temperature',
                    'snow_density', 'snow_depth', 'snowfall',
                    'temperature_of_snow_layer',
                ],
            'year': str(year),
            'month': "{month:02d}".format(month=month),
            'day': [
                '01', '02', '03',
                '04', '05', '06',
                '07', '08', '09',
                '10', '11', '12',
                '13', '14', '15',
                '16', '17', '18',
                '19', '20', '21',
                '22', '23', '24',
                '25', '26', '27',
                '28', '29', '30',
                '31',
            ],
            'time': [
                '00:00', '01:00', '02:00',
                '03:00', '04:00', '05:00',
                '06:00', '07:00', '08:00',
                '09:00', '10:00', '11:00',
                '12:00', '13:00', '14:00',
                '15:00', '16:00', '17:00',
                '18:00', '19:00', '20:00',
                '21:00', '22:00', '23:00',
            ],
            'area': [
                bounds[2],bounds[1],bounds[0],bounds[3],
            ],
            'format': 'netcdf',
        }

        c.retrieve('reanalysis-era5-single-levels',request,"{year}-{month:02d}.nc".format(year=year, month=month))

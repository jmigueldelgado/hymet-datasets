# to run in ipython in conda env gee

import ee
import fiona
from shapely.geometry import shape, polygon, mapping, Point
import json
import pandas
from geopandas import GeoDataFrame
import geopandas
import numpy as np
from functools import reduce
import IPython

# Get the csv with peak location
df=pandas.read_csv('/home/delgado/proj/hymet-datasets/data/peak_coordinates_revised3_WGS84.csv')
df_clean=df[(df.LON>-361) & (df.LAT>-91)]
geometry = [Point(xy) for xy in zip(df_clean.LON, df_clean.LAT)]
crs = {'init': 'epsg:4326'} #http://www.spatialreference.org/ref/epsg/2263/
geo_df = GeoDataFrame(df_clean, crs=crs, geometry=geometry)

# Authenticate with google account

ee.Authenticate()
ee.Initialize()

# Create `ee.FeatureCollection`

g = [i for i in geo_df.geometry]
name = [i for i in geo_df.PKNAME]
features=[]
for i in range(len(g)):
    x,y = g[i].coords.xy
    cords = np.dstack((x,y)).tolist()
    double_list = reduce(lambda x,y: x+y, cords)
    single_list = reduce(lambda x,y: x+y, double_list)

    g=ee.Geometry.Point(single_list)
    feature = ee.Feature(g).set("peakname",name)
    features.append(feature)
eeFeatureCollection = ee.FeatureCollection(features)


# //IMPORT COLLECTION
# era5_pre = ee.ImageCollection('ECMWF/ERA5_LAND/MONTHLY').filterDate("1981-01-01T00:00:00","2020-11-01T00:00:00").select('u_component_of_wind_10m')
era5_pre = ee.ImageCollection('ECMWF/ERA5_LAND/MONTHLY').filterDate("1981-01-01T00:00:00","1981-11-01T00:00:00").select('u_component_of_wind_10m')


# .filterDate(ee.Date.fromYMD(2013,12,13), ee.Date.fromYMD(2014,1,15))

# // Empty Collection to fill
ft = ee.FeatureCollection(ee.List([]))

def fill(img, ini):
    # // type cast
    inift = ee.FeatureCollection(ini)

    # // gets the values for the points in the current img
    ft2 = img.reduceRegions(eeFeatureCollection, ee.Reducer.first(),3000)

    # // gets the date of the img
    date = img.date().format()

    # // writes the date in each feature
    def mapfunc(ft):
        return ft.set("date", date)
    ft3 = ft2.map(mapfunc)

    # // merges to the FeatureCollections
    return inift.merge(ft3)

# // Iterates over the ImageCollection
newft = ee.FeatureCollection(era5_pre.iterate(fill, ft))

task=ee.batch.Export.table.toDrive(collection=newft,description='u_wind_timeseries',fileNamePrefix='u_wind_timeseries')
task.start()
task.status()

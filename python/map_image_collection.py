# following this example: https://gis.stackexchange.com/questions/258344/reduce-image-collection-to-get-annual-monthly-sum-precipitation
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

geoms = [i for i in geo_df.geometry]
name = [i for i in geo_df.PKNAME]
features=[]
for i in range(len(geoms)):
    # IPython.embed()
    x,y = geoms[i].coords.xy
    cords = np.dstack((x,y)).tolist()
    double_list = reduce(lambda x,y: x+y, cords)
    single_list = reduce(lambda x,y: x+y, double_list)

    g=ee.Geometry.Point(single_list)
    feature = ee.Feature(g).set("peakname",name[i])
    features.append(feature)
eeFeatureCollection = ee.FeatureCollection(features)


# map

u_component='u_component_of_wind_10m'
v_component='v_component_of_wind_10m'
start_date="1981-01-01"
end_date="1981-05-31"
# //IMPORT COLLECTION
# era5_pre = ee.ImageCollection('ECMWF/ERA5_LAND/MONTHLY').filterDate("1981-01-01T00:00:00","2020-11-01T00:00:00").select('u_component_of_wind_10m')
era5_pre = ee.ImageCollection('ECMWF/ERA5_LAND/MONTHLY').filterDate(start_date,end_date).select([u_component,v_component])


# map over collection to obtain intensities
def intensity(image):
    """A function to compute intensity."""
    W=image.expression('float((b("u_component_of_wind_10m")**2 + b("v_component_of_wind_10m")**2)**0.5)').rename('W')
    return image.addBands(W)

era5_w=era5_pre.map(intensity)


# // Empty Collection to fill
ft = ee.FeatureCollection(ee.List([]))

def fill(img, ini):
    # // type cast
    inift = ee.FeatureCollection(ini)

    # // gets the values for the points in the current img.
    # Since we expect only one value per point we use the reducer .first().
    # 10000 m is approximately the resolution of the dataset
    ft2 = img.reduceRegions(eeFeatureCollection, ee.Reducer.first(),10000)

    # // gets the date of the img
    date = img.date().format()

    # // writes the date in each feature
    def mapfunc(ft):
        return ft.set("date", date)
    ft3 = ft2.map(mapfunc)

    # // merges to the FeatureCollections
    return inift.merge(ft3)


newft = ee.FeatureCollection(era5_w.iterate(fill, ft))

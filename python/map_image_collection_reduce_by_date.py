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


# for i in range(len(geoms)):
for i in range(3):
    # IPython.embed()
    x,y = geoms[i].coords.xy
    cords = np.dstack((x,y)).tolist()
    double_list = reduce(lambda x,y: x+y, cords)
    single_list = reduce(lambda x,y: x+y, double_list)

    g=ee.Geometry.Point(single_list)
    feature = ee.Feature(g).set("peakname",name[i])
    features.append(feature)


eeFeatureCollection = ee.FeatureCollection(features)


u_component='u_component_of_wind_10m'
v_component='v_component_of_wind_10m'
start_date="1981-01-01T00:00:00"
end_date="1990-01-01T00:00:00"
# end_date="2020-11-01T00:00:00"
# //IMPORT COLLECTION
# era5_pre = ee.ImageCollection('ECMWF/ERA5_LAND/MONTHLY').filterDate("1981-01-01T00:00:00","2020-11-01T00:00:00").select('u_component_of_wind_10m')

# filter and select relevant bands

era5_pre = ee.ImageCollection('ECMWF/ERA5_LAND/HOURLY').filterDate(start_date,end_date).select([u_component,v_component])


# clip image to bounding box of peaks

bounds=geo_df.buffer(0.5).total_bounds
eePolygon = ee.Geometry.Polygon(
          [[[bounds[0], bounds[1]],
            [bounds[0], bounds[3]],
            [bounds[2], bounds[3]],
            [bounds[2], bounds[1]]]])

def Clip(image):
    return image.clip(eePolygon)

era5_clipped = era5_pre.map(Clip)

# map over collection to obtain intensities
def intensity(image):
    """A function to compute intensity."""
    W=image.expression('float((b("u_component_of_wind_10m")**2 + b("v_component_of_wind_10m")**2)**0.5)').rename('W')
    return image.addBands(W)

era5_w=era5_clipped.map(intensity).select('W')



# make list of dates

ee_start_date=ee.Date(start_date)
ee_end_date=ee.Date(end_date)
# // Create list of dates for time series
n_days = ee_end_date.difference(ee_start_date,'day').round().subtract(1)
dates = ee.List.sequence(0,n_days,1);

def make_datelist(n):
    return ee_start_date.advance(n,'day');

dates = dates.map(make_datelist);

# save projection data
Wproj=ee.Image(era5_w.first()).projection()


# // Function to calculate wind for 1 day

def dailyW(date):
    startDate=ee.Date(date)
    endDate = startDate.advance(1, 'day')
    filtered = era5_w.filter(ee.Filter.date(startDate, endDate))
    img_dummy = filtered.reduce(ee.Reducer.first())
    img_out = filtered.reduce(ee.Reducer.max())
    img_proj = img_out.setDefaultProjection(Wproj)
    return img_proj.set({'system:time_start':startDate.millis(),
        'system:time_end':endDate.millis()})

Wmax_daily = ee.ImageCollection(dates.map(dailyW))

# // Empty Collection to fill
ft = ee.FeatureCollection(ee.List([]))

def fill(img, ini):
    # // type cast
    inift = ee.FeatureCollection(ini)

    # // gets the values for the points in the current img. 10000 m is approximately the resolution of the dataset
    ft2 = img.select('W_max').reduceRegions(eeFeatureCollection, ee.Reducer.first(),10000)

    # rename new field "first" to "W"

    # // gets the date of the img
    date = img.date().format()

    # // writes the date in each feature
    def mapfunc(ft):
        return ft.set("date", date)
    ft3 = ft2.map(mapfunc)

    # // merges to the FeatureCollections
    return inift.merge(ft3)

# // Iterates over the ImageCollection
newft = ee.FeatureCollection(Wmax_daily.iterate(fill, ft))



task=ee.batch.Export.table.toDrive(collection=newft,description='maximum daily wind velocity',fileNamePrefix='Wmax'+'_'+start_date+'_'+end_date)
task.start()
task.status()

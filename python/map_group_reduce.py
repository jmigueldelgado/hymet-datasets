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

chosen_variable='v_component_of_wind_10m'
start_date="1981-01-01"
end_date="2020-10-31"
# //IMPORT COLLECTION
# era5_pre = ee.ImageCollection('ECMWF/ERA5_LAND/MONTHLY').filterDate("1981-01-01T00:00:00","2020-11-01T00:00:00").select('u_component_of_wind_10m')
era5_pre = ee.ImageCollection('ECMWF/ERA5_LAND/HOURLY').filterDate(start_date,end_date).select(chosen_variable)

var modis = ee.ImageCollection('MODIS/MOD13A1');

var months = ee.List.sequence(1, 12);

// Group by month, and then reduce within groups by mean();
// the result is an ImageCollection with one image for each
// month.
var byMonth = ee.ImageCollection.fromImages(
      months.map(function (m) {
        return modis.filter(ee.Filter.calendarRange(m, m, 'month'))
                    .select(1).mean()
                    .set('month', m);
}));






var imageCollection = ee.ImageCollection("LANDSAT/LT05/C01/T1");
var months = ee.List.sequence(1, 12);

var composites = ee.ImageCollection.fromImages(months.map(function(m) {
  var filtered = imageCollection.filter(ee.Filter.calendarRange({
    start: m,
    field: 'month'
  }));
  var composite = ee.Algorithms.Landsat.simpleComposite(filtered);
  return composite.normalizedDifference(['B4', 'B3']).rename('NDVI')
      .set('month', m);
}));
print(composites);

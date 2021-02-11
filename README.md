# hymet-datasets
This started by being an r package for retrieving reanalysis and monitoring datasets of several sorts. Due to the advent of google earth engine (gee) I changed the development towards the gee python API. I am not 100% happy about using google services for everything, so expect to see some changes in the future for the sake of diversity.

Some sources for this work:

- [Map reduce means after geom and date filtering](https://stackoverflow.com/questions/42237278/google-earthengine-getting-time-series-for-reduceregion)
- [exporting several pixel values by points](https://gis.stackexchange.com/questions/265392/extracting-pixel-values-by-points-and-converting-to-table-in-google-earth-engine)
- [another option for exporting pixel values by points]( https://stackoverflow.com/questions/42742742/extract-pixel-values-by-points-and-convert-to-a-table-in-google-earth-engine?newreg=02a799d032314818a92facfe624f5975). This was the one I used.

# Download ERA5-land

Open IPython and run the get_era5.py script by copying and pasting and editing the respective fields (csv file with location of pixels and dates). For some reason running `ee` on the current conda environment as a jupyter notebook won't work.

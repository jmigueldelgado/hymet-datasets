##### calculate reference ET for forested catchment  and reference ET for current LU
##### Reference ET
##### get time series of daily rainfall
##### calculate ET



require(ggplot2)
require(etfao)
require(sf)
setwd("/home/baseno/proj/SUDS_Famalicao/CAPITULO_2/finalizar")

pt <- data.frame(lon=-8.0,lat=41.4) %>% ### add to mvoe the point a bit to the right (original latitude was -8.516667) in order to avoid getting the closest point over the ocean.
    st_as_sf(.,coords=c(1,2)) %>%
    st_set_crs(.,4326)


DF <- list()

varname='air'
for(yeari in seq(2007,2017))
{
    prefix='ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis/surface_gauss/'
    fname=paste0('air.2m.gauss.',yeari,'.nc')
    DF[[as.character(yeari)]] <- get_reanalysis(pt,prefix,fname,varname)
}

df <- do.call("rbind",DF)
saveRDS(df,paste0(varname,".rds"))




DF <- list()

varname='rhum'
for(yeari in seq(2007,2017))
{
    prefix='ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis/surface/'
    fname=paste0('rhum.sig995.',yeari,'.nc')
    DF[[as.character(yeari)]] <- get_reanalysis(pt,prefix,fname,varname)
}

df <- do.call("rbind",DF)
saveRDS(df,paste0(varname,".rds"))




DF <- list()

varname='vwnd'
for(yeari in seq(2007,2017))
{
    prefix='ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis/surface/'
    fname=paste0('vwnd.sig995.',yeari,'.nc')
    DF[[as.character(yeari)]] <- get_reanalysis(pt,prefix,fname,varname)
}

df <- do.call("rbind",DF)
saveRDS(df,paste0(varname,".rds"))


DF <- list()

varname='uwnd'
for(yeari in seq(2007,2017))
{
    prefix='ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis/surface/'
    fname=paste0('uwnd.sig995.',yeari,'.nc')
    DF[[as.character(yeari)]] <- get_reanalysis(pt,prefix,fname,varname)
}

df <- do.call("rbind",DF)
saveRDS(df,paste0(varname,".rds"))





DF <- list()
varname='prate'
for(yeari in seq(2007,2017))
{
    prefix='ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface_gauss/'
    fname=paste0(varname,'.sfc.gauss.',yeari,'.nc')
 
    DF[[as.character(yeari)]] <- get_reanalysis(pt,prefix,fname,varname)
}

df <- do.call("rbind",DF)
saveRDS(df,paste0(varname,".rds"))







DF <- list()

for(yeari in seq(2007,2017))
{
    prefix='ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface_gauss/'
    fname=paste0('gflux.sfc.gauss.',yeari,'.nc')
    varname='gflux'
    DF[[as.character(yeari)]] <- get_reanalysis(pt,prefix,fname,varname)
}

df <- do.call("rbind",DF)
saveRDS(df,paste0(varname,".rds"))





DF <- list()

for(yeari in seq(2007,2017))
{
    prefix='ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface_gauss/'
    fname=paste0('dswrf.sfc.gauss.',yeari,'.nc')
    varname='dswrf'
    DF[[as.character(yeari)]] <- get_reanalysis(pt,prefix,fname,varname)
}

df <- do.call("rbind",DF)
saveRDS(df,paste0(varname,".rds"))



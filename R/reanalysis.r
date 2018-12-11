#' download ncdf
#' @param request is a data_frame obtained from def_request
#' @importFrom curl curl_download
#' @export
download_nc <- function(request)
{
    fname <- paste0(request$fname[1],'.',request$year[1],'.nc')
    fpath <- paste0(request$prefix[1],request$fname[1],'.',request$year[1],'.nc')
    if(!file.exists(fname))
    {
        cat("wget ",fpath,'\n')
        curl_download(fpath,file.path(getwd(),fname))
    }

    if(file.exists(fname))
    {
        cat(" downloaded ",fname,"\n")
    } else
    {
        cat("problems downloading from NCEP server\n")
    }
}

#' get ncdf from NCEP
#' @param request_all is a data_frame obtained from def_request
#' @importFrom dplyr distinct
#' @export
get_nc <- function(request_all)
{
    request <- distinct(request_all,varname,year,.keep_all=TRUE)
    for(i in seq(1,nrow(request)))
    {
        download_nc(request[i,])
    }
}
#' convert ncdf into data frame and save
#' @importFrom lubridate ymd_hms hours as_datetime
#' @import dplyr
#' @import ncdf4
#' @import lwgeom
#' @importFrom sf st_coordinates st_as_sf st_set_crs st_distance
#' @importFrom reshape2 melt
#' @export
nc2rds <- function(request_all)
{

    for(v in distinct(as_data_frame(request_all),varname) %>% pull(varname))
    {
        request <- request_all %>%
            filter(varname==v)

        DF <- list()
        for(i in seq(1,nrow(request)))
        {
            fname <- paste0(request$fname[i],'.',request$year[i],'.nc')
            if(file.exists(fname))
            {
                nc=nc_open(fname)
                tt=ncvar_get(nc,varid="time")
                tformat= ymd_hms("1800-01-01 00:00:00")+hours(tt)
                lat=ncvar_get(nc,varid="lat")
                lon=ncvar_get(nc,varid="lon")
                nlatlon <- def_spatial_domain(nc,request[i,])
                var=lookup_ncep(v) %>% pull(variable)
                x <- ncvar_get(nc,v,start=c(min(nlatlon[[1]]),min(nlatlon[[2]]),1),count=c(length(nlatlon[[1]]),length(nlatlon[[2]]),length(tformat)))

                dimnames(x)[[1]] <- lon[nlatlon[[1]]]
                dimnames(x)[[2]] <- lat[nlatlon[[2]]]
                dimnames(x)[[3]]  <- as.numeric(tformat)

                xmelt <- melt(x)
                colnames(xmelt) <- c("lon","lat","time","value")


                DF[[i]] <- xmelt %>% mutate(time=as_datetime(time),var=var)
                nc_close(nc)
            } else {cat(fname," not found.")}
            df <- do.call("rbind",DF)
            saveRDS(df,paste0(v,".rds"))
        }
    }
}

# coor <- data.frame(l=12,r=14,b=50,t=53)
# var <- c('temperature')
# years <- c('2008')
# library(scraping)
# require(dplyr)
# require(sf)
# require(ncdf4)
# require(lubridate)
# require(tidyr)
# require(reshape2)
# coor
# request <- def_request(coor,var,years)
# request=request[1,]
# v='air'
# i=1
#
# nc=nc_open('~/proj/scraping/air.2m.gauss.2008.nc')

#' defines spatial domain for polygon and points
#' @importFrom sf st_join st_intersects st_coordinates st_as_sf st_set_crs st_distance st_geometry
#' @importFrom reshape2 melt
#' @export
def_spatial_domain <- function(nc,request)
{
  lat=ncvar_get(nc,varid="lat")
  lon=ncvar_get(nc,varid="lon")
  gr=expand.grid(lon,lat)
  colnames(gr) <- c("lon","lat")
  grsf <- st_as_sf(gr,coords=c(1,2)) %>% st_set_crs(.,4326)

  geomclass=st_geometry(request) %>% class %>% .[1]

  if(geomclass=='sfc_POINT')
  {
    ncpt=grsf[which.min(st_distance(grsf,request)),]
  } else if(geomclass=='sfc_POLYGON')
  {
    ncpt = st_join(grsf,request, join = st_intersects) %>% filter(!is.na(variable))
  }

  nlon=which(lon %in% st_coordinates(ncpt)[,1])
  nlat=which(lat %in% st_coordinates(ncpt)[,2])

  if(length(nlon)==1)
  {
    nlon[2]=nlon[1]+1
  }
  if(length(nlat)==1)
  {
    nlat[2]=nlat[1]+1
  }

  return(list(nlon,nlat))
}



#' lookup variable names in NCEP
#' @param var a meteorological variable name as a string such as 'temperature','relative humidity','u wind','v wind','soil heat flux','net radiation','precipitation rate'
#' @importFrom dplyr filter
#' @importFrom tibble data_frame
#' @export
lookup_var <- function(var)
{
    lookup <- data_frame(variable=c('temperature','relative humidity','u wind','v wind','soil heat flux','net radiation','precipitation rate'),varname=c('air','rhum','uwnd','vwnd','gflux','dswrf','prate')) %>%
        filter(variable %in% var)
    return(lookup)
}

#' lookup NCEP variable names
#' @param ncepname ncep variable name as a string such as 'air','rhum'
#' @importFrom dplyr filter
#' @importFrom tibble data_frame
#' @export
lookup_ncep <- function(ncepname)
{
    lookup <- data_frame(variable=c('temperature','relative humidity','u wind','v wind','soil heat flux','net radiation','precipitation rate'),varname=c('air','rhum','uwnd','vwnd','gflux','dswrf','prate')) %>%
        filter(varname %in% ncepname)
    return(lookup)
}

#' define request
#' @importFrom dplyr left_join
#' @importFrom sf st_as_sf st_set_crs st_polygon st_sfc st_sf
#' @importFrom tidyr crossing
#' @return request
#' @export
def_request <- function(coor,var,years)
{

    lookup <- lookup_var(var) %>%
        left_join(.,getPrefix())

    if('l' %in% colnames(coor) & 'r' %in% colnames(coor)& 't' %in% colnames(coor)& 'b' %in% colnames(coor))
    {
      l=coor$l[1]
      r=coor$r[1]
      t=coor$t[1]
      b=coor$b[1]
      geom=list(cbind(c(l,r,r,l,l),c(b,b,t,t,b))) %>%
        st_polygon %>%
        st_sfc %>%
        st_sf %>%
        st_set_crs(.,4326)
    } else {
      geom <- data.frame(longitude=coor[,1],latitude=coor[,2]) %>%
          st_as_sf(.,coords=c(1,2)) %>%
          st_set_crs(.,4326)
    }

    y <- data.frame(year=years)

    request <- crossing(y,lookup,geom) %>% st_as_sf
    return(request)
}

#' get prefix
#' importFrom tibble data_frame
#' @export
getPrefix <- function()
{
    prefix=data_frame(varname=c('air','rhum','uwnd','vwnd','prate','gflux','dswrf'),
               prefix=c('ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis/surface_gauss/',
                        'ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis/surface/',
                        'ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis/surface/',
                        'ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis/surface/',
                        'ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface_gauss/',
                        'ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface_gauss/',
                        'ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface_gauss/'),
               fname=c('air.2m.gauss',
                       'rhum.sig995',
                       'uwnd.sig995',
                       'vwnd.sig995',
                       'prate.sfc.gauss',
                       'gflux.sfc.gauss',
                       'dswrf.sfc.gauss'))
    return(prefix)
}

#' download ncdf
#' @param request is a data_frame obtained from def_request
#' @export
download_nc <- function(request)
{
    fname <- paste0(request$fname[1],'.',request$year[1],'.nc')
    fpath <- paste0(request$prefix[1],request$fname[1],'.',request$year[1],'.nc')
    if(!file.exists(fname))
    {
        cat("wget ",fpath)
        system(paste0("wget ",fpath))
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
#' @importFrom lubridate ymd_hms hours
#' @import dplyr
#' @import ncdf4
#' @import lwgeom
#' @importFrom sf st_coordinates st_as_sf st_set_crs st_distance
#' @export
nc2rds <- function(request_all)
{
    # coor <- data.frame(lon=13.40,lat=52.52)
    # var <- c('temperature','relative humidity')
    # years <- c('2000','2001')

    request_all <- def_request(coor,var,years)

    v='air'
    i=1
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
                gr=expand.grid(lon,lat)
                colnames(gr) <- c("lon","lat")
                grsf <- st_as_sf(gr,coords=c(1,2)) %>% st_set_crs(.,4326)
                ncpt=grsf[which.min(st_distance(grsf,request[i,])),]
                nlon=which(lon==st_coordinates(ncpt)[1])
                nlat=which(lat==st_coordinates(ncpt)[2])

                var=lookup_ncep(v) %>% pull(variable)
                x <- ncvar_get(nc,v,start=c(nlon,nlat,1),count=c(1,1,-1))
                DF[[i]] <- data.frame(time=tformat,var=var,value=x,lon=lon[nlon],lat=lat[nlat])
                nc_close(nc)
            } else {cat(fname," not found.")}
            df <- do.call("rbind",DF)
            saveRDS(df,paste0(v,".rds"))
        }
    }
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
#' @importFrom sf st_as_sf st_set_crs
#' @importFrom tidyr crossing
#' @return request
#' @export
def_request <- function(coor,var,years)
{

    lookup <- lookup_var(var) %>%
        left_join(.,getPrefix())

    pt <- data.frame(longitude=coor[,1],latitude=coor[,2]) %>%
        st_as_sf(.,coords=c(1,2)) %>%
        st_set_crs(.,4326)

    y <- data.frame(year=years)

    request <- crossing(y,lookup,pt) %>% st_as_sf

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

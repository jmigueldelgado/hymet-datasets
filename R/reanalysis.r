#' download ncdf
#' @param request is a data_frame obtained from def_request
#' @importFrom curl curl_download
#' @export
download_nc <- function(request)
{
    not_yet_downloaded <- function(fname)
    {
      if(file.exists(fname))
      {
        cat(fname," already exists: not downloading\n")
        return(FALSE)
      } else
      {
        cat("atempting to download ",fname,'\n')
        return(TRUE)
      }
    }


    if(request$dataset=='gpcc')
    {
      fname <- paste0(request$fname[1],'_',request$year[1],'.nc.gz')
      remote_path <- paste0(request$prefix[1],fname)
      if(not_yet_downloaded(fname)) curl_download(remote_path,file.path(getwd(),fname))
    } else if (request$dataset=='ncep'){
      fname <- paste0(request$fname[1],'_',request$year[1],'.nc')
      remote_path <- paste0(request$prefix[1],fname)
      if(not_yet_downloaded(fname)) curl_download(remote_path,file.path(getwd(),fname))
    } else if(request$dataset=='reanalysis-era5-complete')
    {
      download_with_python(request)

    }

}




#' download netcdf from ecmwf using ecmwfapi with python/reticulate. miniconda3 should be installed!
#'
#' @importFrom reticulate py_config import r_to_py
#' @importFrom sf st_bbox
#' @export
download_with_python <- function(request)
{
  ## this works, but make sure you copy .ecmwfapirc to your home directory (check 3.2 here: https://dominicroye.github.io/en/2018/access-to-climate-reanalysis-data-from-r/#connection-and-download-with-the-ecmwf-api):

  cat('Make sure you installed conda and the required environment previous to calling this function! Please  check the vignette in https://github.com/jmigueldelgado/scraping/blob/master/vignettes/example_era5.Rmd\n')
  sys=Sys.info()
  if(sys['sysname']!='Linux')
  {
    cat('Sorry, but currently we only support Linux \n')
  }

  if(!file.exists('~/.cdsapirc')) cat('Please add your user information in .cdsapirc to your home directory.')
  conda_location = readline("Please enter the absolute location of your conda installation (for default press return):")
  if(conda_location=='') conda_location = '~/local/miniconda3'

  conda_env = readline("Please enter the name of the conda environment containing the ecmwfapi python package  (for default press return):")
  if(conda_env=='') conda_env = 'ecmwf'

  Sys.setenv(RETICULATE_PYTHON=paste0(conda_location,'/envs/',conda_env,'/bin/python'))
  py_config()
  cds <- import('cdsapi')
  gridsize=0.125

  bb=st_bbox(geom)

  client=cds$Client()
  r_query=list(
    class='ea',
    expver='1',
    stream='oper',
    type='an',
    levtype=request$levtype,
    param=request$param, # 2m temperature
    grid=paste0(gridsize,'/',gridsize),
    area=paste0(bb[4],'/',bb[1],'/',bb[2],'/',bb[3]), # N/W/S/E
    date=paste0(request$year,'-01-01/to/',request$year,'-12-31'),
    time='00/to/23/by/6',
    format='netcdf'
    )
  if(request$levtype != 'sfc') r_query[["levelist"]] = '100/800'

  query = r_to_py(r_query)

  client$retrieve(request$dataset,query,target=paste0(request$fname,'_',request$year,'.nc'))

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

#' obtain ncdf metadata, inclusing units
#' @importFrom dplyr %>% filter slice
#' @importFrom ncdf4 nc_open ncatt_get
#' @importFrom R.utils gunzip
#' @export
get_nc_meta <- function(request,var)
{
  requesti = request %>% filter(variable==var) %>% slice(1)
  if(requesti$dataset=='gpcc')
  {
    fname <- paste0(requesti$fname[1],'_',requesti$year[1],'.nc')
    } else if(requesti$dataset=='era5')
    {
      fname <- paste0(requesti$fname[1],'.nc')
    } else
  {
      fname <- paste0(requesti$fname[1],'.',requesti$year[1],'.nc')
  }
  if(file.exists(fname))
    {
      nc=nc_open(fname)
      return(ncatt_get(nc,requesti$varname[1]))
    } else {cat(fname," not found.")}

}



#' get ncdf average spatial resolution for this domain
#' @importFrom dplyr left_join distinct filter pull slice %>% data_frame mutate
#' @importFrom ncdf4 nc_open ncvar_get nc_close
#' @importFrom reshape2 melt
#' @importFrom geosphere distGeo
#' @export
get_nc_spatial_res <- function(request_all)
{
  DF <- list()

    for(v in distinct(as_data_frame(request_all),varname) %>% pull(varname))
    {
        request <- request_all %>%
            filter(varname==v) %>%
            slice(1)

        if(request$dataset[1]=='gpcc')
        {
            fname <- paste0(request$fname[1],'_',request$year,'.nc')
        } else
        {
            fname <- paste0(request$fname[1],'.',request$year,'.nc')
        }
        if(file.exists(fname))
        {
            nc=nc_open(fname)
            lat=ncvar_get(nc,varid="lat")
            lon=ncvar_get(nc,varid="lon")
            nlatlon <- def_spatial_domain(nc,request[1,])
            x <- ncvar_get(nc,v,start=c(median(nlatlon[[1]]),median(nlatlon[[2]]),1),count=c(2,2,1))
            dimnames(x)[[1]] <- lon[nlatlon[[1]]]
            dimnames(x)[[2]] <- lat[nlatlon[[2]]]

            xmelt <- melt(x)
            colnames(xmelt) <- c("lon","lat","value")
            nc_close(nc)

            DF[[v]]=data_frame(varname=v,dataset=request$dataset[1],zonal=max(xmelt$lon)-min(xmelt$lon),meridional=max(xmelt$lat)-min(xmelt$lat),x=distGeo(p1=c(median(xmelt$lon),max(xmelt$lat)),p2=c(median(xmelt$lon),min(xmelt$lat))),y=distGeo(p1=c(max(xmelt$lon),median(xmelt$lat)),p2=c(min(xmelt$lon),median(xmelt$lat))))
          } else {cat(fname," not found.")}
    }
    res=do.call("rbind",DF)
    return(left_join(request_all,res,by=c('varname','dataset')))
}






#' convert ncdf into data frame and save
#' @importFrom lubridate ymd_hms hours as_datetime days
#' @importFrom dplyr left_join distinct filter pull slice %>% data_frame as_data_frame mutate
#' @importFrom ncdf4 nc_open ncvar_get nc_close
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
            if(request$dataset[i]=='gpcc')
            {
                fname <- paste0(request$fname[i],'_',request$year[i],'.nc')
            } else if(request$dataset=='era5')
            {
              fname <- paste0(request$fname[1],'.nc')
            } else            {
                fname <- paste0(request$fname[i],'.',request$year[i],'.nc')
            }
            if(file.exists(fname))
            {
                nc=nc_open(fname)
                tt=ncvar_get(nc,varid="time")
                if(request$dataset[i]=='gpcc')
                {
                  tformat= ymd_hms(paste0(request$year[i],"-01-01 00:00:00"))+days(tt)
                } else if (request$dataset[i]=='era5')
                {
                  tformat= ymd_hms("1900-01-01 00:00:00")+hours(tt)
                } else
                {
                  tformat= ymd_hms("1800-01-01 00:00:00")+hours(tt)
                }
                lat=ncvar_get(nc,varid="lat")
                lon=ncvar_get(nc,varid="lon")
                nlatlon <- def_spatial_domain(nc,request[i,])
                x <- ncvar_get(nc,v,start=c(min(nlatlon[[1]]),min(nlatlon[[2]]),1),count=c(length(nlatlon[[1]]),length(nlatlon[[2]]),length(tformat)))

                dimnames(x)[[1]] <- lon[nlatlon[[1]]]
                dimnames(x)[[2]] <- lat[nlatlon[[2]]]
                dimnames(x)[[3]]  <- as.numeric(tformat)

                xmelt <- melt(x)
                colnames(xmelt) <- c("lon","lat","time","value")


                DF[[i]] <- xmelt %>% mutate(time=as_datetime(time),var=v,dataset=request$dataset[i])
                nc_close(nc)
            } else {cat(fname," not found.")}
            df <- do.call("rbind",DF)
            saveRDS(df,paste0(v,".rds"))
        }
    }
}


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



#' lookup variable names in NCEP and GPCC
#' @param my_var a meteorological variable name as a string such as 'temperature','relative humidity','u wind','v wind','soil heat flux','net radiation','precipitation rate'
#' @importFrom dplyr filter %>%
#' @importFrom tibble data_frame
#' @export
lookup_var <- function(my_var,my_dataset)
{
  data(vartable)
  lookup <- vartable %>% filter(dataset==my_dataset) %>%
      filter(grepl(my_var,.$variable))
  return(lookup)
}

#' define request
#' @importFrom dplyr left_join
#' @importFrom sf st_as_sf st_set_crs st_polygon st_sfc st_sf st_bbox
#' @importFrom tidyr crossing
#' @return request
#' @export
def_request <- function(var,geom,years,dataset,level=NA,levtype=NA)
{
    if(dataset=='reanalysis-era5-complete' & is.na(levtype))
    {
      cat('Sorry but you must define level type as ml, pl or sfc (model level, pressure level or surface level) and level respectively\n')
    }
    lookup <- lookup_var(var,dataset)

    y <- data.frame(year=years)
    levs=data.frame(level=level,levtype=levtype)
    request <- crossing(y,lookup,levs,geom) %>% st_as_sf
    return(request)
}

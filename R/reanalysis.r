


#' get reanalysis data from NCEP
#' @param pt an sf point object in lat long
#' @param lubri a lubridate object or a list of two objects defining the time domain or the query
#' @importFrom lubridate year
#' @import dplyr
#' @import ncdf4
#' @export
get_reanalysis <- function(pt,prefix,fname,varname)
{
    if(!file.exists(fname))
    {
        system(paste0("wget ",prefix,fname))
    }
    
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
        ncpt=grsf[which.min(st_distance(grsf,pt)),]
        nlon=which(lon==st_coordinates(ncpt)[1])
        nlat=which(lat==st_coordinates(ncpt)[2])
                
        x <- ncvar_get(nc,varname,start=c(nlon,nlat,1),count=c(1,1,-1))
        df <- data.frame(time=tformat,var=varname,value=x)
    } else {cat("problems downloading from NCEP server")}
    
      
nc_close(nc)

return(df)
}


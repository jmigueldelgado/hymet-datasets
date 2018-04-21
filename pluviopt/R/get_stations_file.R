#' Georeference metada
#' @import readr
#' @import dplyr
#' @import sf
#' @export
georef_meta <- function(tbl)
{
    tbl <- st_as_sf(tbl,coords=c(5,4)) %>% st_set_crs(4326)
    return(tbl)
}


#' Get pluvio station metadata and ids from local downloaded file with all automatic stations
#' @import readr
#' @import dplyr
#' @export
get_stations_pluvio <- function()
{
    tbl <- read_csv("./dados/rede_Pluviometrica.csv",skip=5,na=c("",NA,"-"),col_names=F) %>% select(c(1,2,3,4,5)) %>% rename(`Código`=X1,Nome=X2,altitude=X3,latitude=X4,longitude=X5)
    ids <- read_csv("./dados/ids.tbl",col_names=F)
    colnames(ids) <- c("ref","Nome","Código")
    tbl <- inner_join(tbl,ids)
    tbl <- georef_meta(tbl)
    return(tbl)
}

#' Get meteo station metadata and ids from local downloaded file with all automatic stations
#' @import readr
#' @import dplyr
#' @export
get_stations_meteo <- function()
{
    tbl <- read_csv("./dados/rede_Meteorologica.csv",skip=5,na=c("",NA,"-"),col_names=F) %>% select(c(1,2,3,4,5)) %>% rename(`Código`=X1,Nome=X2,altitude=X3,latitude=X4,longitude=X5)
    ids <- read_csv("./dados/ids.tbl",col_names=F)
    colnames(ids) <- c("ref","Nome","Código")
    tbl <- inner_join(tbl,ids)
    tbl <- georef_meta(tbl)
    return(tbl)
}


#' Get csv from snirh for given station and dates
#' @import readr
#' @import dplyr
#' @import rvest
#' @import lubridate
#' @export
get_pluvio_web <- function(ref,start,end)
{

#tmin <- "01/08/2017"
                                        #tmax <- "20/08/2017"
    path <- paste0("http://snirh.apambiente.pt/snirh/_dadosbase/site/janela_verdados.php?sites=",ref,"&pars=100744007&tmin=",start,"&tmax=",end)
    raw <- read_html(path) %>%
        html_nodes(".tbl_val") %>%
        html_text() %>%
        matrix(.,nrow=2)  %>%
        t() %>%
        gsub("\r","",.) %>%
        gsub("\n","",.)%>%
        gsub("\t","",.)%>%
        gsub("  ","",.)

    raw[,1] <- paste0(raw[,1],":00")
    tbl <- tibble(datetime=dmy_hms(raw[,1]),value=as.numeric(raw[,2]))
        
    return(tbl)
}


#' Get csv from snirh for given station and dates
#' @import readr
#' @import dplyr
#' @import rvest
#' @import lubridate
#' @export
get_temp_web <- function(ref,start,end)
{

#tmin <- "01/08/2017"
                                        #tmax <- "20/08/2017"
    path <- paste0("http://snirh.apambiente.pt/snirh/_dadosbase/site/janela_verdados.php?sites=",ref,"&pars=100745177&tmin=",start,"&tmax=",end)
    raw <- read_html(path) %>%
        html_nodes(".tbl_val") %>%
        html_text() %>%
        matrix(.,nrow=2)  %>%
        t() %>%
        gsub("\r","",.) %>%
        gsub("\n","",.)%>%
        gsub("\t","",.)%>%
        gsub("  ","",.)

    raw[,1] <- paste0(raw[,1],":00")
    tbl <- tibble(datetime=dmy_hms(raw[,1]),value=as.numeric(raw[,2]))
        
    return(tbl)
}


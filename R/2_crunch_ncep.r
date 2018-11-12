require(lubridate)
require(dplyr)
varname='air'

setwd("/home/delgado/proj/SUDS_Famalicao/CAPITULO_2/finalizar/et")

t <- readRDS(paste0(varname,".rds")) %>%
    group_by(day=floor_date(time,"day")) %>%
    summarise(tmax=max(value),tmin=min(value))

varname='rhum'
rh <- readRDS(paste0(varname,".rds")) %>%
    group_by(day=floor_date(time,"day")) %>%
    summarise(rhmax=max(value),rhmin=min(value))


varname='vwnd'
v <- readRDS(paste0(varname,".rds")) %>%
    group_by(day=floor_date(time,"day")) %>%
    summarise(v=mean(abs(value))) %>%
    mutate(v2=v^2)

varname='uwnd'
u <- readRDS(paste0(varname,".rds")) %>%
    group_by(day=floor_date(time,"day")) %>%
    summarise(u=mean(abs(value))) %>%
    mutate(u2=u^2)

w <- data.frame(day=v$day,varname='wnd',value=sqrt(u$u2 + v$v2))


varname='gflux'
g <- readRDS(paste0(varname,".rds"))

varname='dswrf'
rn <- readRDS(paste0(varname,".rds"))


varname <- 'prate'
prate <- readRDS(paste0(varname,".rds")) %>%
     mutate(value=value*60*60)### in mm/h

nrow(t)
nrow(rh)
nrow(w)
nrow(g)
nrow(rn)
nrow(prate)



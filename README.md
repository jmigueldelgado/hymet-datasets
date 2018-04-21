# scraping
A collection of simple scripts that were used in the past for scraping meteorological data from the internet.

## pluviopt
A [rvest](https://blog.rstudio.com/2014/11/24/rvest-easy-web-scraping-with-r/) based package to harvest near real-time pluviometry data from SNIRH/Portugal.

Data is publicly available at [SNIRH](http://snirh.apambiente.pt/) from the Portuguese Environemntal Agency. Right now it is possible to obtain rainfall data from the telemetry database. Objective is to make it easier to retrieve data from the website directly into an R workflow. Work in progress...

## download_hidroweb.py

A selenium-based script for downloading the complete time-series of hundreds of hydro-meteorological stations in the São Francisco river basin.
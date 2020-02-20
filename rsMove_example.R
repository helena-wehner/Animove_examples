### rs move package ###
#######################

### Waldrapp Data ###

#######################
library(sp)
library(rgdal)
library(raster)
library(rsMove)
library(geosphere)
library(move)

### related paper: RSMOVE - An R package to bridge remote sensing and movement ecology

### Loading Movement Data
# Movement data of NBI 1 bird western and 1 bird eastern migration route
# Sonic (western)
# (eastern)

setwd("C:/Users/Lenovo/Desktop/")

q3_19 <- readOGR("GPS_data_Helena/2019_Q3.shp")
q3_19
head(q3_19)

### working with east und west routes
# loading data



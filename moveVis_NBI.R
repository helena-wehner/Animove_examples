### moveVis Waldrapp ###
########################
library(sp)
library(raster)
library(rgdal)
library(moveVis)
library(geosphere)
library(move)

####################################################################################################
setwd("C:/Users/Lenovo/Desktop/")
getwd()
# loading movement data

# loading as data.frame
charlie <- read.table("GPS Daten/Generation 2016/Charlie.txt", header = T, sep = "\t",dec = ".")
head(charlie)
names(charlie)
plot(charlie)

# loading as spatialpointsdataframe
nbi <- readOGR("GPS Daten/Generation 2016/Charlie_2018.shp")
head(nbi)
plot(nbi)

# creating a move object
move_c <- move(x=charlie$lon, y=charlie$lat, time=as.POSIXct(charlie$timestamp, format="%Y-%m-%d %H:%M:%S", tz="UTC"), data=charlie, proj=CRS("+proj=longlat +ellps=WGS84"),animal="Charlie", sensor="GPS")
head(move_c)
plot(move_c)
unique(timestamps(move_c))
unique(unlist(timeLag(move_c, units = "secs")))
move <- align_move(move_c,res = 60,unit ="mins")
head(move)

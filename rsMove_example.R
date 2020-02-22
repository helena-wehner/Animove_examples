#######################
### rs move package ###
#######################
# related Papers:
# RSMOVE - An R package to bridge remote sensing and movement ecology
# Linking animal movement and remote sensing – mapping resource suitability from a remote sensing perspective
# following example: Costs of migratory decisions: a comparison across eight white stork populations
##########################################################################################

# example from: Predicting Resource Suitability with rsMove
# https://cran.r-project.org/web/packages/rsMove/vignettes/resource_suitability.html
# based on this paper: https://www.datarepository.movebank.org/handle/10255/move.417

#########################################################################################
# data used:
# White Stork movement data (MPIO)
# NDVI timeseries data

########################################################################################
# loading and installing needed packages

library(geosphere)
library(sp)
library(rgdal)
library(rsMove)
library(raster)

########################################################################################
# getting the data
data("shortMove") # movement data
head(shortMove)

file <- list.files(system.file('extdata','', package="rsMove"),'ndvi.tif', full.names=TRUE)
ndvi <- stack(file) # environmental predictors
plot(ndvi)
#########################################################################################
# focus only on feeding behaviour, since samples to resting sites are limited

# movement data pre-processing
# remove redundant data points

plot(shortMove)

# moveReduce() due to the coarser remote sensing data resolution
obs.time <- strptime(paste0(shortMove$date,"",shortMove$time), format = "%Y/%m/%d %H:%M:%S ") # format observation time
reduced.samples <- moveReduce(shortMove, ndvi, obs.time, derive.raster = T) # remove redundant data points
head(reduced.samples)
plot(reduced.samples$total.time) # show total time image

# pixel standing out with about 400 min --> nesting site
# since we are only ineterested in feeding sites we will filter this pixel
# moreover we will filter all pixels with 0 min
# these are pixels which did not record more than one consecutive GPS point suggesting that the animal did not stop within them
# we use the raster package to create a mask , identify the usable pixels and use them to build a new shapefile that will contain our presence samples
# note: sample selection performed with moveReduce() is more informative when using high-resolution movement data
# we are building a mask from all visited pixels
# one way to do so would be to use rasterize() function to identify all pixels that overlap with the movement data

upper.limit <- quantile(reduced.samples$total.time, 0.95) # identify upper treshold using 0.95%-percentile
move.mask <- reduced.samples$total.time > 0 & reduced.samples$total.time < upper.limit # build sample mask
usable.pixels <- which.max(move.mask)
usable.pixels # identify relevant pixels
presence.samples <- SpatialPoints(xyFromCell(move.mask, usable.pixels), proj4string = crs(shortMove))
presence.samples # build shapefile from samples (presences)

# Identifying absence samples
# we collected samples that are likely related to feeding sites
# to distinguish them from the rest of the landscape, we need to collect background samples that describe "unattractive" environmental conditions

# backSample(): uses presence samples as informants, these are used to collect samples from rs data and identity pixels where the environmental conditions
# are statistical different while preserving fuzzy borders between presence and background samples

# we will aggregate samples within 60 m of each other (i.e. 2 pixels)

sample.id <- labelSample(presence.samples, ndvi, agg.radius = 60) # aggregate samples in space
absence.samples <- backSample(presence.samples, ndvi, sample.id, sampling.method = "pca") # identify absence samples
absence.samples # show samples
 
# Derive and Validate Predict Model
# predictResource(): perform the training and validation steps

env.presences <- extract(ndvi, presence.samples) # extract environmental data fro presences
env.absences <-  extract(ndvi, absence.samples) # extract environmental data for absences
resourceModel1 <- predictResources(env.presences, env.absences, sample.id, env.data = ndvi) # build model

# now lets have a look in the result
# first, lets make a mask from the output probability map with a treshold of 0.5
# the lets overlap the presence samples

plot(resourceModel1$probabilities >= 0.5) # probability map
points(presence.samples) # presences 

# how accurate is the output
# for that consult the F1-scores for presences and absences
resourceModel1$f1

# the accuracies were comparatively higher for absences suggesting an unbalance between both classes
# this indicates that the chosen environmental predictors might not be suitable to distinguish the selected resources from their surroundings
# but what if we had used random background sampling instead of the porposed approach?

absence.samples2 <- backSample(presence.samples, ndvi, sampling.method = "random") # identify absence samples (random)
env.absences2 <- extract(ndvi, absence.samples2) # extract environmental data for absences
resourceModel2 <- predictResources(env.presences, env.absences2, sample.id, env.data = ndvi) # build model

plot(resourceModel2$probabilities >= 0.5) # probability map
points(presence.samples) # presences
kable_styling(kable(head(resourceModel2$f1,1), format="html", align="c", fullwidth=T), "stripped", bootstrap_options="responsive")

resourceModel2$f1
# F1-score for presence was NaN suggesting that the independent presence regions failed to predict each other

# Plausibility Test
# ideal to verify results if they fit to our expectations
# plausibilityTest(): allows to compare presence-absence maps derived with different modelling approaches against existing categorical information
# such as landcover maps
# to test this tool, we can use the land cover data provided through rsMove

landCover <- raster(system.file("extdata","landCover.tif", package="rsMove"))

# lets apply the function using the probability maps derived with "pca" and "random" sampling
# considering only probabilities higher than 0.5
# we will also specify the class labels

class.labels <- c("Arable land","Land without use","Open spaces","Wetlands","Permament crops","Extraction/Dump sites","Industrial areas","Green urban areas")
probMask <- stack(resourceModel1$probabilities > 0.5, resourceModel2$probabilities > 0.5) # stack of probabilities pca and random
ptest <- plausibilityTest(probMask, landCover, class.labels = class.labels)
ptest

# the output suggests very similar results between both sampling approaches
# conderidering that the White Stork is reportedly attracted by agriculture
# the output of plausibiliyTest() suggests we build a reasonable predictive model





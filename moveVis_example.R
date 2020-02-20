### moveVis ###
### example: White Stork ###
### taken from the moveVis package ###
### http://movevis.org/index.html
###################################################################################################

install.packages("moveVis")

# get all the necessary packages

library(sp)
library(raster)
library(rgdal)
library(moveVis)

###################################################################################################
data("whitestork_data")
head(df)
m <- align_move(m,res = 180,digit = 0,unit = "mins")
head(m)

# creating a spatial frame
frames <- frames_spatial(m, trace_show = T, equidistant = F, map_service = "osm", map_type = "terrain_bg")
frames[[200]] # plots a single frame

# creating a graph frame
# display movement trajectories as two-dimensional, non-spatial graph
# e.g. displaying frame time on the x-axis and the values of cells visited by individuals on the y-axis, or a cumulative histogram


# customize/adapt created frames
frames <- frames %>%
  add_labels(title="White Storks (Ciconia ciconia) Migration 2018",
             caption="Trajectory data: Cheng et al. (2019); Fiedler et al. (2013-2019), doi:...
             Map: OpenStreetMap/Stamen; Projection: Geographic, WGS84",
             x="Longitude", y="Latitude") %>%
  add_timestamps(type = "label") %>%
  add_progress(colour = "white") %>%
  add_northarrow(colour = "white", position = "bottomleft") %>%
  add_scalebar(colour = "black", position = "bottomright", distance = 600)

plot(frames[[200]]) # plots a single frame

# rendering frames into an animation
animate_frames(frames, out_file = "moveVis_example_WhiteStork.gif")

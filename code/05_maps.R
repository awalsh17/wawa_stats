library(ggplot2)
library(ggmap)

# register_google('fasdfjioemafakekey', write = T)
# ran this first to register with my google maps API key

# creating a sample data.frame with your lat/lon points
# new_wawa <- c(-75.155848, 40.098564)
# mapdf <- rbind(wawa_df[,c("long","lat")], new_wawa)

mapdf <- wawa_df[,c("long","lat")]
mapdf$new <- c(rep("exists",nrow(wawa_df)-1),"new")

# long <- c(-38.31,-35.5) # testing it out on fake data
# lat <- c(40.96, 37.5)
# mapdf <- as.data.frame(cbind(long,lat))

# getting the map
mapgilbert <- get_map(location = c(lon = mean(mapdf$long), lat = mean(mapdf$lat)), zoom = 8,
                      maptype = "hybrid", scale = 2)

# plotting the map with some points on it
ggmap(mapgilbert) +
  geom_point(data = mapdf, aes(x = long, y = lat, fill = new, alpha = 0.9), size = 2, shape = 21) +
  guides(fill=FALSE, alpha=FALSE, size=FALSE)

# ZOOM in on new wawa
new_wawa <- data.frame(long = c(-75.155848, -75.155848-0.005, -75.155848+0.005),
                       lat = c(40.098564, 40.098564-0.005, 40.098564+0.005))
map_new <- get_map(location = c(lon = new_wawa$long[1], lat = new_wawa$lat[2]), zoom = 15,
                      maptype = "hybrid", scale = 2)

# plotting the map with some points on it
ggmap(map_new) +
  geom_point(data = new_wawa, aes(x = long, y = lat, fill = "red", alpha = 0.9), size = 2, shape = 21) +
  guides(fill=FALSE, alpha=FALSE, size=FALSE) + 
  scale_y_continuous(limits = c(40.098564-0.005, 40.098564+0.005)) +
  scale_x_continuous(limits = c(-75.155848-0.005, -75.155848+0.005)) +
  NULL

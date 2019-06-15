#
# This script returns a data.frame with data queried from OSM
# Alice Walsh
#


# Data on road by address: speed limit, number of lanes/width
# https://nominatim.org/release-docs/develop/api/Reverse/
# https://developers.google.com/maps/documentation/roads/speed-limits


library(httr)
library(jsonlite)
library(osmdata)
library(dplyr)

#
# Build queries with wawa lat lons ----
#
wawa_loc <- wawa_df[,c("lat","long")]
urls <- paste0('https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=',
               wawa_loc$lat, '&lon=', wawa_loc$long, '&zoom=17&extratags=1')
#&zoom=17
raw_results <- lapply(urls, GET)

# Format into data.frame 
jsonRespTexts <- lapply(raw_results, function(rr) content(rr,as="text") )
res_list <- lapply(jsonRespTexts, fromJSON)

osm_df <- bind_rows(lapply(res_list, function(rr) 
  bind_cols(purrr::flatten(rr))
))


#
# Try osmdata package to query ----
#

# test
# dat1 <- opq(bbox = 'Kunming, China') %>%
#   add_osm_feature(key = 'building', value = 'house')  %>%
#   osmdata_sf()

# Create helper functions to return interesting things
house_count <- function(coords){
  mybb <- matrix(coords,nrow=2, byrow = T)
  rownames(mybb) = c("y","x")
  colnames(mybb) = c("min","max")
  q <- opq(bbox = mybb, timeout = 100) %>%
    add_osm_feature(key = 'building', value = 'house') 
  res <-  osmdata_sf(q)
  houses <- nrow(res$osm_polygons)
  houses
}
motorway_count <- function(coords){
  mybb <- matrix(coords,nrow=2, byrow = T)
  rownames(mybb) = c("y","x")
  colnames(mybb) = c("min","max")
  q <- opq(bbox = mybb, timeout = 100) %>%
    add_osm_feature(key = 'highway', value = 'motorway') 
  res <-  osmdata_sf(q)
  # print(res)
  houses <- nrow(res$osm_lines)
  houses
}

# house_count(c(40.082143148568,40.122190646723,-75.194120407104,-75.136098861694))

# Each degree of latitude is approximately 69 miles
# Add 0.005 degrees in each direction to wawa 

wawa_loc$lat_min <- as.numeric(wawa_loc$lat) - 0.005
wawa_loc$lat_max <- as.numeric(wawa_loc$lat) + 0.005
wawa_loc$lon_min <- as.numeric(wawa_loc$long) - 0.005
wawa_loc$lon_max <- as.numeric(wawa_loc$long) + 0.005

# new_wawa <- c(40.098564, -75.155848)
# new_wawa_box <- c(40.098564- 0.005, 40.098564+0.005, -75.155848-0.005, -75.155848+0.005)
# house_count(new_wawa_box)

# Run for all
wawa_list <- split(wawa_loc[,3:6], seq(nrow(wawa_loc)))

all_house_counts <- sapply(wawa_list, function(x) house_count(unlist(x)))
# Merge back into main wawa df
wawa_df$house_count <- unlist(replace_na(all_house_counts))
wawa_df$house_count[is.na(wawa_df$house_count)] <- 0 #these are 0s

# Find all BIG highways
all_hw_counts <- sapply(wawa_list, function(x) motorway_count(unlist(x)))
# Merge back into main wawa df
wawa_df$hw_count <- unlist(replace_na(all_hw_counts))
wawa_df$hw_count[is.na(wawa_df$hw_count)] <- 0 #these are 0s

# end

# OTHER STUFF I TRIED ----
#
# Build queries with wawa address - without number...
#
# query <- gsub("\\s","&",paste(gsub("^[0-9][0-9|-]+","",wawa_df$address), wawa_df$city, wawa_df$state))
# urls <- paste0('https://nominatim.openstreetmap.org/search/', query, 
#                    '?format=json&addressdetails=1&limit=1&extratags=1')
# raw_results <- lapply(urls[1:10], GET)
# 
# jsonRespTexts <- lapply(raw_results, function(rr) content(rr,as="text") )
# res_list <- lapply(jsonRespTexts, fromJSON)
# 
# osm_df2 <- bind_rows(lapply(res_list, function(rr) 
#   bind_cols(purrr::flatten(rr)[-c(5)])
# ))
# 
# 
# jsonRespText <- content(raw_result,as="text")
# res_list <- fromJSON(jsonRespText)
# res_df <- bind_cols(purrr::flatten(res_list)[-c(5)])


# Testing on single url ----
# test_url <- 'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=-34.44076&lon=-58.70521'
# test_url <- 'https://nominatim.openstreetmap.org/reverse?format=jsonv2&osm_type=W&osm_id=135632917&extratags=1&zoom=16'
# raw_result <- GET(test_url)
# jsonRespText <- content(raw_result,as="text")
# res_list <- fromJSON(jsonRespText)
# res_df <- bind_cols(purrr::flatten(res_list))

# Testing osmdata ----
# c(xmin, ymin, xmax, ymax)
# mybb <- matrix(c(40.082143148568,40.122190646723,-75.194120407104,-75.136098861694),nrow=2, byrow = T)
# rownames(mybb) = c("y","x")
# colnames(mybb) = c("min","max")
# q <- opq(bbox = mybb, timeout = 100) %>%
#   add_osm_feature(key = 'building', value = 'house') 
# res <-  osmdata_sf(q)
# houses <- nrow(res$osm_polygons)

# opq_string(q)
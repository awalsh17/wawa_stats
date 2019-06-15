#
# This script creates a data.frame wawa_df with locations of wawas from wawa.com
# Alice Walsh
#

library(httr)
library(jsonlite)


# Build urls for grid of lat/long around PHL ----
lats <- c(39.9526 - seq(0.1,0.6,0.2) ,39.9526 + seq(0,0.6,0.2) )
longs <- c(-75.1652 - seq(0.1,0.6,0.2), -75.1652 + seq(0,0.6,0.2))
all_combs <- tidyr::crossing(lats, longs)
urls <- paste0('https://www.wawa.com/Handlers/LocationByLatLong.ashx?limit=50&lat=',all_combs$lats, '&long=',all_combs$longs)

# GET API as list ----
raw_results_wawa <- lapply(urls, GET)
# Convert json to data.frame
jsonRespTexts <- lapply(raw_results_wawa, function(rr) content(rr,as="text") )
res_list_wawa <- lapply(jsonRespTexts, fromJSON)
res_list_wawa <- lapply(res_list_wawa, function(rr) rr$locations) 
# Expand addresses and fuelTypes and amenities fields to make flat df ----
friendly_address <- select(bind_rows(lapply(res_list_wawa, function(rr) filter(bind_rows(rr$addresses), context=="friendly"))), -loc)
phys_address <- select(bind_rows(lapply(res_list_wawa, function(rr) filter(bind_rows(rr$addresses), context=="physical"))), loc)
phys_address <- as.data.frame(t(data.frame(phys_address$loc)))
colnames(phys_address) <- c("lat","long")
amenities <- bind_rows(lapply(res_list_wawa, function(rr) rr$amenities))
res_df <- bind_rows(lapply(res_list_wawa, function(rr) select(rr, -addresses, -fuelTypes, -amenities)))
wawa_df <- unique(cbind(res_df, friendly_address, phys_address, amenities))

# Add a row for the *new* wawa
new_row <- c(NA, "NEW", "24hours", NA, NA, NA, FALSE, NA, NA, TRUE,
             NA, NA, F, NA, NA, "200 S Easton Rd.","Glenside","PA",19038, 40.098564,-75.155848,
             T, T, T, F, F)
wawa_df <- rbind(wawa_df, new_row)

# Want lat/long to be numeric
wawa_df$lat <- as.numeric(wawa_df$lat)
wawa_df$long <- as.numeric(wawa_df$long)


# Calc interwawa distance ----
# For each location, how far is nearest?
# First find in same zip, then compare
all_min_dist <- lapply(1:nrow(wawa_df), function(nn) min(geosphere::distVincentyEllipsoid(wawa_df[,c("long","lat")][c(nn),], 
                                                                                          wawa_df[,c("long","lat")][-c(nn),])))

wawa_df$min_dist_wawa <- unlist(all_min_dist)
# single test
# geosphere::distVincentyEllipsoid(wawa_df[,c("long","lat")][c(1),], wawa_df[,c("long","lat")][c(1,4),]) #results in meters
# 1609.34 meters in a mile


# 
# single testing ----
# 
# url <- 'https://www.wawa.com/Handlers/LocationByLatLong.ashx?limit=50&lat=40.0958615&long=-75.17204879999997'
# url <- 'https://www.wawa.com/Handlers/LocationByLatLong.ashx?limit=50&lat=40.0958615&long=-75.17204879999997'

# raw_result <- GET(url)
# # Convert json to data.frame
# jsonRespText <- content(raw_result,as="text") 
# res_df1 <- fromJSON(jsonRespText)
# res_df1 <- res_df1$locations
# # Expand addresses and fuelTypes fields to make flat df
# friendly_address <- res_df$addresses %>% bind_rows() %>% filter(context=="friendly")
# # physical_address <- res_df$addresses %>% bind_rows() %>% filter(context=="physical")
# 
# res_df_expand <- cbind(select(res_df, -addresses), 
#                        # physical_address$loc, 
#                        select(friendly_address, address, city, state, zip))

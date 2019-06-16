# Analyze merged data

library(tidyverse)

# Merge with wawa data ----
# Have col names lat state city in both
wawa_osm <- cbind(rename(wawa_df, lat_wawa = lat, lon_wawa = long, state_ab = state), 
                  rename(osm_df, osm_city = city))

wawa_osm$maxspeed_num <- as.numeric(gsub(" mph","",wawa_osm$maxspeed))
wawa_osm$lanes_num <- as.numeric(wawa_osm$lanes)



# Tables just wawa ----

with(wawa_df, table(openType, exclude = NULL))
with(wawa_df, table(fuel, exclude = NULL))
with(wawa_df, table(restrooms, exclude = NULL))
with(wawa_df, table(state, exclude = NULL))

with(wawa_df, table(fuel,hw_count>0, exclude = NULL))
with(wawa_df, table(fuel,sidewalk_count>=25, exclude = NULL))

# Tables road data ----
table(wawa_osm$lanes, wawa_osm$fuel, exclude = NULL)

table(wawa_osm$maxspeed, wawa_osm$fuel, exclude = NULL)

table(wawa_osm$type, wawa_osm$fuel, exclude = NULL)

# Plots on Wawa ----
wawa_osm %>% filter(!is.na(lanes)) %>% 
  count(lanes, fuel, name = "wawa") %>% 
  group_by(fuel) %>% mutate(fraction = wawa/sum(wawa)) %>% 
  ggplot(aes(x = lanes, y=fraction, fill=fuel)) + geom_col(position = "dodge")

wawa_osm %>% filter(!is.na(maxspeed)) %>% 
  mutate(maxspeed = factor(maxspeed), fuel = factor(fuel)) %>% 
  count(maxspeed, fuel, name = "wawa",.drop=F) %>%
  group_by(fuel) %>% mutate(fraction = wawa/sum(wawa)) %>% 
  ggplot(aes(x = maxspeed, y=fraction, fill=fuel)) + geom_col(position = "dodge") + 
  theme_minimal() 

wawa_df %>% filter(state %in% c("NJ","PA")) %>% 
  ggplot(aes(y = sidewalk_count, x=fuel)) + 
  geom_hline(yintercept = 25, color="red", linetype = 2) + 
  ggbeeswarm::geom_quasirandom() +
  facet_wrap(~state) +
  theme_minimal()

wawa_osm %>% filter(state_ab %in% c("NJ","PA")) %>% 
  ggplot(aes(y = maxspeed_num, x=fuel)) + 
  geom_hline(yintercept = 25, color="red", linetype = 2) + 
  geom_boxplot(outlier.shape = NA) + 
  geom_jitter(height = 0, width = 0.2, alpha=0.5) + 
  facet_wrap(~state_ab) +
  labs(title = "Speed Limits", 
       subtitle = "Dotted red line shows proposed Wawa",
       y="Max Speed Limit (mph)", x="Does the Wawa have gas?")+
  theme_minimal()

new_dist <- wawa_df$min_dist_wawa[wawa_df$storeName=="NEW"]

wawa_df %>% filter(state %in% c("NJ","PA")) %>% 
  ggplot(aes(x=fuel, y=min_dist_wawa/1609.34)) + 
  geom_hline(yintercept = new_dist/1609.34, color="red", linetype = 2) + 
  geom_boxplot(outlier.shape = NA) + geom_jitter(height = 0, width = 0.2, alpha=0.5) + 
  facet_wrap(~state) +
  ylim(c(0,10)) +
  labs(title = "Distance to nearest Wawa", 
       subtitle = "Dotted red line shows proposed Wawa",
       y="Distance (miles)", x="Does the Wawa have gas?")+
  theme_minimal()


# Cluster data with interesting variables

clust_vars <- c("lanes_num","maxspeed_num","house_count","hw_count","sidewalk_count")
myannotation <- wawa_osm[,c("openType","fuel"), drop=F]
myannotation$fuel <- as.character(myannotation$fuel)
pheatmap::pheatmap(t(wawa_osm[,clust_vars]),
                   annotation_col = myannotation,
                   show_colnames = F,
                   scale= "none")

# Inspect ----
wawa_osm %>% filter(maxspeed == "25 mph") %>% View()
wawa_osm %>% filter(maxspeed %in% c("25 mph", "30 mph"), fuel==T) %>% View()




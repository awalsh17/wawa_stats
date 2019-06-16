Is the new Wawa unusual?
================
Alice Walsh
6/15/2019

New Wawa in Glenside
====================

Motivation
----------

Goodman Properties is planning a Wawa with gas (“Super Wawa”) at the corner of Easton Road and Waverly Road in Glenside, PA.

Concerns from neighbors and the community were raised about safety, traffic, and the juxtaposition with smaller scale properties and businesses in the area.

There are also two other Wawa locations already in close proximity.

-   Are other Super Wawa locations in similar areas?
-   Are other Super Wawa locations this close to other Wawas?

Step 1: Query data on Wawa locations in Northeast
-------------------------------------------------

Retrieved the Wawa locations from wawa.com for the area around Glenside, PA. *Retrieved data on 485 unique Wawa locations (PA, NJ, DE, MD).* Wawa.com data does not include detailed information on location size, number of pumps, etc.

-   470/485 Wawa locations are open 24 hours
-   280/485 Wawa locations have gas
-   280/485 Wawa locations have restrooms

Here is a map of all the locations in the dataset:

    ## Source : https://maps.googleapis.com/maps/api/staticmap?center=39.985222,-75.074544&zoom=8&size=640x640&scale=2&maptype=hybrid&language=en-EN&key=xxx

    ## Warning in strptime(x, fmt, tz = "GMT"): unknown timezone 'zone/tz/2019a.
    ## 1.0/zoneinfo/America/New_York'

![](wawa_report_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-2-1.png)

### Proposed new Wawa site

The proposed Wawa is at [200 S Easton Rd.](https://www.google.com/maps/place/200+S+Easton+Rd,+Glenside,+PA+19038/@40.0986321,-75.1580774,17z/data=!3m1!4b1!4m5!3m4!1s0x89c6ba0ab50e862d:0xda87770daaf8ea23!8m2!3d40.098628!4d-75.1558834)

    ## Source : https://maps.googleapis.com/maps/api/staticmap?center=40.093564,-75.155848&zoom=15&size=640x640&scale=2&maptype=hybrid&language=en-EN&key=xxx

    ## Scale for 'y' is already present. Adding another scale for 'y', which
    ## will replace the existing scale.

    ## Scale for 'x' is already present. Adding another scale for 'x', which
    ## will replace the existing scale.

    ## Warning: Removed 1 rows containing missing values (geom_rect).

![](wawa_report_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-3-1.png)

Step 2: Annotate Wawa locations with data from OpenStreetMaps
-------------------------------------------------------------

1.  Calculate the distance to the nearest Wawa for each location

2.  Retrieve number of lanes and max speed limit of road

-   May be misleading because nearest road might be a driveway or side road off of a major highway
-   Lanes and max speed limit are not available for most Wawa coordinates

1.  Count the number of houses, highways, and sidewalks in a set area around Wawa location

-   Not all buildings are on openstreetmaps - we need a better data source
-   Considered 'highway=motorways' as highways (<https://wiki.openstreetmap.org/wiki/Key:highway>)
-   Considered 'footway=sidewalk' as sidewalks

*These results could be sensitive to the size of the area selected. Here I used a 0.01 degree latitude and longitude rectangle centered around the location. This is approximately a 0.69 x 0.53 mile rectangle. See above map for the area around the proposed Wawa as an example.*

Results: The new Wawa will be unusually close to another Wawa location
----------------------------------------------------------------------

The distance to the nearest Wawa from each Wawa location was calculated in meters. The shortest distance between the Wawa coordinates was calculated according to the 'Vincenty (ellipsoid)' method as implemented in the 'geosphere' R package.

The closest Wawa to the proposed location will be 1028.0010513 meters from the nearest Wawa. That is 0.6387718 miles.

The median distance between locations is 2645.1198825 meters.

    ## Warning: Removed 2 rows containing missing values (position_quasirandom).

    ## Warning: Removed 2 rows containing missing values (position_quasirandom).

![](wawa_report_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-5-1.png)

Results: Most Wawa locations with gas are on higher speed roads
---------------------------------------------------------------

This is imperfect because the OpenStreetMap data was missing for some roads and the roads might be a driveway or service road off a larger (higher speed) road.

From this data, I do see that locations with gas are on higher speed limit roads.

![](wawa_report_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-6-1.png)

Results: Most Wawa locations are in less residential/walkable areas
-------------------------------------------------------------------

Here, I use the number of sidewalks from OpenStreetMaps as a surrogate measure of the area's walkability. The proposed Wawa area has **25** sidewalks.

-   28/485 \[5.8%\] current Wawa locations have as many or more sidewalks than the proposed site
-   Of these 28, 13 have gas
-   Of these 28, 10 are in Philadelphia

<!-- -->

    ##          
    ## gas_label FALSE TRUE
    ##    Gas      267   13
    ##    No Gas   190   15

    ## # A tibble: 17 x 2
    ##    city             n
    ##    <chr>        <int>
    ##  1 Philadelphia     5
    ##  2 PHILADELPHIA     5
    ##  3 Downingtown      2
    ##  4 Easton           2
    ##  5 Newark           2
    ##  6 ABINGTON         1
    ##  7 Absecon          1
    ##  8 Cherry Hill      1
    ##  9 Jenkintown       1
    ## 10 Kulpsville       1
    ## 11 Maple Shade      1
    ## 12 Media            1
    ## 13 NEWARK           1
    ## 14 READING          1
    ## 15 Warrington       1
    ## 16 Willow Grove     1
    ## 17 WYNCOTE          1

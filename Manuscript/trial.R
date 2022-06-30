
# code courtesy of Paco Rodriguez.
library(sf)
library(raster)
library(rasterVis)
library(tidyverse)
crs.geo <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
crs.laea <- "+proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +units=m +no_defs"

library(data.table)
data <- read.table("Data/iberian_bees.csv.gz", header = T, quote = "\"", sep = ",")

# Prepare data
data$Longitude <- as.numeric(data$Longitude)
data$Latitude <- as.numeric(data$Latitude)
data <- data %>% filter(!is.na(Latitude) & !is.na(Longitude))
# Keep points on balearic islands
data_1 <- data %>% filter(Province == "Balears, Illes")
data_1$Country_1 <- NA

# Filter points in Spain and Portugal
data$Country_1 <- NA
data$Country_1 <- maps::map.where(x = data$Longitude, y = data$Latitude)
data <- data %>% filter(Country_1 == "Spain" | Country_1 == "Portugal")
# Rbind points that are in Spain with the ones of Balearic islands
dat <- rbind(data, data_1)

datos.sf <- st_as_sf(dat,
                     coords = c("Longitude", "Latitude"),
                     crs = crs.geo
)

datos.laea <- st_transform(datos.sf,
                           crs = crs.laea
)

ras <- raster(datos.laea, resolution = 10000)

ras.counts <- rasterize(datos.laea[, "Accepted_name"], ras,
                        field = "Accepted_name", fun = "count"
)

levelplot(log(ras.counts+1), margin = FALSE, scales = list(draw = FALSE),
          par.settings = viridisTheme())




# install.packages("ggplot2")
library(ggplot2)
library(viridis)
# Data
set.seed(1)
df <- data.frame(x = rnorm(2000), y = rnorm(2000))

ggplot(dat, aes(x = Longitude, y = Latitude)) +
  stat_binhex(aes(fill=..count..)) + scale_fill_viridis() + theme_bw()

ggplot(dat, aes(Longitude, Latitude)) + stat_binhex(bins=60, aes(fill=log(..count..))) +
  scale_fill_viridis() + theme_bw()


library(giscoR) #map of europe

#gisco
#gisco_countrycode
eu2016 <- c(gisco_countrycode[gisco_countrycode$eu, ]$CNTR_CODE)

#Select data
europe_map <- gisco_get_nuts(
  year = "2016",
  epsg = "3035",
  resolution = "3",
  nuts_level = "2",
  country = eu2016) %>%
  sf::st_transform(crs = 4326) 


# Borders
borders <- gisco_get_countries(
  epsg = "3035",
  year = "2016",
  resolution = "3",
  country = eu2016) %>%
  sf::st_transform(crs = 4326) 

vars <- c("ES",  "PT")
#Extract counties of interest
euro_map <- filter(europe_map, CNTR_CODE %in% vars)

datos.sf <- st_as_sf(dat,
                     coords = c("Longitude", "Latitude"),
                     crs = crs.geo)

#Plot map
ggplot(data=dat, aes(Longitude, Latitude)) + stat_binhex(bins=60, aes(fill=log(..count..))) +
  scale_fill_viridis() + theme_bw() + geom_sf(data=euro_map, aes(fill = CNTR_CODE))


 ggplot()+  
geom_sf(data=euro_map, aes(fill = CNTR_CODE), color = NA, alpha = 0.3) +
  guides(fill=FALSE) +  ylim(36,44)+xlim(-10,5) 
 
 +
   stat_binhex(data=dat, bins=60, aes(x=Longitude, y=Latitude, fill=log(..count..))) 


world <- map_data("world")

ibera <- world %>% filter(region == "Spain" | region == "Portugal")

ggplot(data=dat, aes(Longitude, Latitude)) +
 geom_map(data = ibera, map = ibera,
                     aes(long, lat, map_id = region), color = "white", 
                     fill = "white", size = 0.1) +
  stat_binhex(bins=60, aes(fill=log(..count..))) + theme(panel.grid.major = element_line(color = gray(0.5), linetype = "dashed", 
size = 0.5), panel.background = element_rect(fill = "aliceblue"),
panel.border = element_rect(colour = "black", fill=NA, size=1)) +
  scale_fill_viridis()


library(data.table)
data <- read.table("Data/iberian_bees.csv.gz",  header=T, quote="\"", sep=",")

master <- read.csv("Data/Processing_iberian_bees_raw/Iberian_species_masterlist.csv", stringsAsFactors = FALSE)
master$accepted_name <- paste(master$Genus, master$Species, sep = " ")
colnames(data)
colnames(master)
data[which(!data$accepted_name %in% master$accepted_name),] #OK
master[which(!master$accepted_name %in% data$accepted_name),] 
#we are missing ~100 species, mostly parasites!
length(unique(data$accepted_name))
nrow(master)


ESPTmap <- map_data("world", region = c("Portugal", "Spain"))

data$Latitude <- as.numeric(data$Latitude)
data$Longitude <- as.numeric(data$Longitude)


get_density <- function(x, y, ...) {
  dens <- MASS::kde2d(x, y, ...)
  ix <- findInterval(x, dens$x)
  iy <- findInterval(y, dens$y)
  ii <- cbind(ix, iy)
  return(dens$z[ii])
}

library(viridis)
library(maps)
data <- data %>% filter(!is.na(Latitude) & !is.na(Longitude))

#Keep points on balearic islands
data_1 <- data %>% filter(Province=="Balears, Illes")
data_1$Country_1 <- NA

#Filter points in Spain and Portugal
data$Country_1 <- NA
data$Country_1 <- maps::map.where(x = data$Longitude, y = data$Latitude)
data <- data %>% filter(Country_1=="Spain" | Country_1=="Portugal")
#Rbind points that are in Spain with the ones of Balearic islands
data <- rbind(data, data_1)

data$density <- get_density(data$Longitude, data$Latitude, n = 100)

ggplot() + geom_map(data = ESPTmap, map = ESPTmap,aes(long, lat, map_id = region), color = "white", 
fill = "lightgray") + 
geom_point(data=data, aes(Longitude, Latitude, color = density), shape=".") +
xlab("Longitude") + ylab("Latitude") +   theme(axis.title.x=element_blank(), axis.text.x=element_blank(),  # don't display x and y axes labels, titles and tickmarks 
axis.ticks.x=element_blank(),axis.title.y=element_blank(),   
axis.text.y=element_blank(), axis.ticks.y=element_blank(),
#text=element_text(size=18),legend.position = c(.9, .15),       # size of text and position of the legend
panel.grid.major = element_blank(),                            # eliminates grid lines from background
panel.background = element_blank())  + scale_color_viridis(direction = -1)


 
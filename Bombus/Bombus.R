#load data

dat <- read.csv("data/data_clean.csv")
head(dat)

library(maptools)
library(maps)
library(mapdata)

bombus <- subset(dat, Genus == "Bombus")
sp <- unique(bombus$Species)
#accepted_name
#Year Month Day
#Latitude Longitude 

#points + perimeter
for(i in sp){
        png(file = paste("Bombus/", i,"_map_bolean.png", sep = ""), width = 400, height = 400,
            bg = "transparent")
        id <- subset(bombus, Species == i)
        map('worldHires', fill = FALSE,
            regions = c('Spain(?!:Ceuta)(?!:Melilla)', 'Portugal'), 
            interior = FALSE, xlim = c(-10, 4.4), ylim = c(36, 44))
        points(x = id$Longitude,
               y = id$Latitude,
               pch=19, col = rgb(red=64/255, green=76/255, blue=86/255,
                                 alpha=0.1) , cex=2.5) 
        #cex can be 0.5 if needed
        #alpha can be increased also
        dev.off()
}

#beautiful
for(i in sp){
        png(file = paste("Bombus/", i,"_map.png", sep = ""), width = 400, height = 400,
                bg = "transparent")
        id <- subset(bombus, Species == i)
        map('worldHires', fill = TRUE, col = rgb(red=0.9, green=0.9, blue=0.9),
            border = NA, regions = c('Spain(?!:Ceuta)(?!:Melilla)', 'Portugal'), 
            interior = FALSE, xlim = c(-10, 4.4), ylim = c(36, 44))
        points(x = id$Longitude,
               y = id$Latitude,
               pch=19, col = rgb(red=64/255, green=76/255, blue=86/255,
                                 alpha=0.1) , cex=2.5) 
        #cex can be 0.5 if needed
        #alpha can be increased also
        dev.off()
}

#only points
for(i in sp){
        png(file = paste("Bombus/", i,"_points_map.png", sep = ""), width = 400, height = 400,
            bg = "transparent")
        id <- subset(bombus, Species == i)
        map('worldHires', fill = FALSE, col = rgb(red=0.9, green=0.9, blue=0.9),
            regions = c('Spain(?!:Ceuta)(?!:Melilla)', 'Portugal'), 
            interior = FALSE, xlim = c(-10, 4.4), ylim = c(36, 44), type = "n")
        points(x = id$Longitude,
               y = id$Latitude,
               pch=19, col = rgb(red=64/255, green=76/255, blue=86/255,
                                 alpha=0.1) , cex=2.5) #111, 123, 134
        #cex can be 0.5 if needed
        #alpha can be increased also
        dev.off()
}

source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template


#Add online data ----
#Process together inaturalist and gbif 

#Read data
newdat <- read.csv(file = "Data/Rawdata/online/i2_inaturalist.csv")[,-1]
head(newdat)

compare_variables(check, newdat)

#Rename cols first
colnames(newdat)[which(colnames(newdat)=="species")] <- "Species"
colnames(newdat)[which(colnames(newdat)=="decimalLatitude")] <- "Latitude"
colnames(newdat)[which(colnames(newdat)=="decimalLongitude")] <- "Longitude"
colnames(newdat)[which(colnames(newdat)=="coordinatePrecision")] <- "Coordinate.precision"
colnames(newdat)[which(colnames(newdat)=="year")] <- "Year"
colnames(newdat)[which(colnames(newdat)=="month")] <- "Month"
colnames(newdat)[which(colnames(newdat)=="day")] <- "Day"
colnames(newdat)[which(colnames(newdat)=="identifiedBy")] <- "Determined.by"
colnames(newdat)[which(colnames(newdat)=="recordedBy")] <- "Collector"
colnames(newdat)[which(colnames(newdat)=="stateProvince")] <- "Province"
colnames(newdat)[which(colnames(newdat)=="locality")] <- "Locality"

#Add cols based on sex col
newdat$Female <- ifelse(newdat$sex %in% c("FEMALE", "female", "queen"), 1, 0)
newdat$Male <- ifelse(newdat$sex %in% c("MALE", "male"), 1, 0)
newdat$Worker <- ifelse(newdat$sex %in% c("worker"), 1, 0)
newdat$Not.specified <- ifelse(is.na(newdat$sex) | newdat$sex == "males_and_females", 1, 0)

#Add missing cols
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat)

#Now create Genus col by selecting 1st element of the string
newdat$Genus <-  word(newdat$Species, 1)
newdat$Subspecies <-  word(newdat$Species, 3)
newdat$Species <-  word(newdat$Species, 2)
#Check
#s <-  data.frame(unique(newdat$Genus)) #Looks fine

#Check species level
#Fix empty spaces
newdat$Locality[newdat$Locality==""] <- NA
#Set coord here to NA
newdat$Locality[newdat$Locality==" 40.586979, -3.702713 "] <- NA
newdat$Locality <- gsub("- ", "", newdat$Locality, fixed = TRUE)
#Delete leading and trailing spaces
newdat$Locality <- trimws(newdat$Locality)
newdat$Locality <- gsub('"', "", newdat$Locality, fixed = TRUE)
newdat$Locality <- gsub('-', "", newdat$Locality, fixed = TRUE)
newdat$Locality <- gsub('\\', "", newdat$Locality, fixed = TRUE)
newdat$Locality <- gsub('^,|.$', '', newdat$Locality)
#Run it again
newdat$Locality <- trimws(newdat$Locality)

#Add leading 0 to month column before merging
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)

#Add leading 0 to month column before merging
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)
#This black magic changes strings with numbers by NA
newdat$Collector[!grepl("[A-Za-z]+", newdat$Collector)] <- NA
#Convert first element of the string to cap
newdat$Collector <- str_to_title(newdat$Collector)
#Convert first element of the string to cap
newdat$Determined.by <- str_to_title(newdat$Determined.by)


#Tell Spanish province by coordinate (ine province names)
#Adapted from here (is fast :)
#https://stackoverflow.com/questions/8751497/latitude-longitude-coordinates-to-state-code-in-r
library(sf)
library(spData)
library(mapSpain)

## pointsDF: A data.frame whose first column contains longitudes and
##           whose second column contains latitudes.
##
## states:   An sf MULTIPOLYGON object with 50 states plus DC.
##
## name_col: Name of a column in `states` that supplies the states'
##           names.
lonlat_to_state <- function(pointsDF,
                            states = mapSpain::esp_get_prov(),
                            name_col = "ine.prov.name") {
  ## Convert points data.frame to an sf POINTS object
  pts <- st_as_sf(pointsDF, coords = 1:2, crs = 4326)
  
  ## Transform spatial data to some planar coordinate system
  ## (e.g. Web Mercator) as required for geometric operations
  states <- st_transform(states, crs = 3857)
  pts <- st_transform(pts, crs = 3857)
  
  ## Find names of state (if any) intersected by each point
  state_names <- states[[name_col]]
  ii <- as.integer(st_intersects(pts, states))
  state_names[ii]
}

#Add province name to the dataset
ine_province <- data.frame(x = newdat$Longitude, y = newdat$Latitude)
newdat$Province <- lonlat_to_state(ine_province)

#Now check country
#library(maps)
newdat$Country <- NA
newdat$Country_1 <- maps::map.where(x = newdat$Longitude, y = newdat$Latitude)
newdat$Country <- ifelse(is.na(newdat$Country) == FALSE, newdat$Country, newdat$Country_1)
#Delete col
newdat <- newdat %>% dplyr::select(-Country_1)

#Rename the spanish label of balearic islands
newdat$Country[grepl("Spain", newdat$Country)] <- "Spain"
unique(levels(factor(newdat$Country)))

newdat$Collector <- ifelse(is.na(newdat$Collector)==FALSE,  paste0("Online_", newdat$Collector), NA)
newdat$Determined.by <- ifelse(is.na(newdat$Determined.by)==FALSE,  paste0("Online_", newdat$Determined.by), NA)

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/i2_Inaturalist.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

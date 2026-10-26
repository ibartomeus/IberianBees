source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

#Read data
newdat <- read.csv(file = "Data/Rawdata/online/i1_Gbif_2026.csv")[,-1]


#Compare vars
compare_variables(check, newdat) #Many variables missing.

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

#Add missing variables
newdat <- add_missing_variables(check, newdat)

#Add cols based on sex col

newdat$Female <- ifelse(newdat$sex %in% c("Female"), 1, 0)
newdat$Male <- ifelse(newdat$sex %in% c("Male"), 1, 0)
newdat$Not.specified <- ifelse(is.na(newdat$sex) | newdat$sex == "Mixed", 1, 0)

#Now create Genus col by selecting 1st element of the string
newdat$Genus <-  word(newdat$species, 1)
newdat$Subspecies <-  word(newdat$species, 3)
newdat$Species <-  word(newdat$species, 2)
#Check
#s <-  data.frame(unique(newdat$Genus)) #Looks fine

#Check species level
#Fix empty spaces in locality

unique(newdat$Locality)

#newdat$Locality[newdat$Locality==""] <- NA
#Set coord here to NA
#newdat$Locality[newdat$Locality==" 40.586979, -3.702713 "] <- NA
newdat$Locality <- gsub("- ", "", newdat$Locality, fixed = TRUE)
#Delete leading and trailing spaces
newdat$Locality <- trimws(newdat$Locality)
newdat$Locality <- gsub('"', "", newdat$Locality, fixed = TRUE)
newdat$Locality <- gsub('-', "", newdat$Locality, fixed = TRUE)
newdat$Locality <- gsub('\\', "", newdat$Locality, fixed = TRUE)
newdat$Locality <- gsub('^,|.$', '', newdat$Locality)
#delete numbers
newdat$Locality <- gsub("[0-9]", "", newdat$Locality)
#Run it again
newdat$Locality <- trimws(newdat$Locality)
unique(newdat$Locality)

#Add leading 0 to month column before merging
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)

#Add leading 0 to month column before merging
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#This black magic changes strings with numbers by NA
newdat$Collector[!grepl("[A-Za-z]+", newdat$Collector)] <- NA
newdat$Collector[grepl("<U\\+[0-9A-Fa-f]+>", newdat$Collector)] <- NA
#Convert first element of the string to cap
newdat$Collector <- str_to_title(newdat$Collector)
unique(newdat$Collector)

#Remove the opening and closing tags, but not the URLs contained within the opening tags.
newdat$Determined.by <- gsub("<A[^>]*>|</A>", "", newdat$Determined.by, ignore.case = TRUE)
newdat$Determined.by[grepl("<U\\+[0-9A-Fa-f]+>", newdat$Determined.by)] <- NA
#Convert first element of the string to cap
newdat$Determined.by <- str_to_title(newdat$Determined.by)
unique(newdat$Determined.by)


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
newdat$Province
newdat$Province <- lonlat_to_state(ine_province)



#Now check country
library(maps)
newdat$Country <- NA
newdat$Country_1 <- maps::map.where(x = newdat$Longitude, y = newdat$Latitude)
newdat$Country <- ifelse(is.na(newdat$Country) == FALSE, newdat$Country, newdat$Country_1)
#remove Morocco
unique(newdat$Country)
newdat <- newdat[is.na(newdat$Country) | newdat$Country != "Morocco",]

#Delete col
newdat <- newdat %>% dplyr::select(-Country_1)
newdat <- newdat %>% dplyr::select(-uid)
#Rename the spanish label of balearic islands
newdat$Country[grepl("Spain", newdat$Country)] <- "Spain"
unique(levels(factor(newdat$Country)))

newdat$Collector <- ifelse(is.na(newdat$Collector)==FALSE,  paste0("Online_", newdat$Collector), NA)
newdat$Determined.by <- ifelse(is.na(newdat$Determined.by)==FALSE,  paste0("Online_", newdat$Determined.by), NA)

#Add missing cols
newdat <- add_missing_variables(check, newdat)

#Add unique identifier
newdat$uid <- paste("i1_Gbif", 1:nrow(newdat), sep = "_")

newdat <- drop_variables(check, newdat)

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/i1_Gbif.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

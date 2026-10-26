
source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template


library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(lubridate)
library(stringi)

#read data
newdat <- read.csv("Data/Rawdata/csvs/95_Ahlam_Sentil_et_al_2026.csv", sep = ",")

#filter by country to keep only Spain 

newdat <- newdat %>%
  filter(country == "Spain")

#Compare vars
compare_variables(check, newdat) #No vars missing, no extra vars.

#Correct genus, subgenus, species and subspecies variables according to the Template

newdat <- newdat %>%
  separate(scientificName,
           into = c("Genus", "Species"), sep = " ")

newdat$Subgenus <- newdat$subgenus
newdat$Subspecies <- newdat$infraspecificEpithet

#Country, province and locality

newdat$Country <- newdat$country
newdat$Province <- NA

#Fix dates 

newdat$Year <- newdat$startYear
newdat$Month <- newdat$startMonth
newdat$Day <- newdat$startDay

newdat$Start.date <- newdat$endEventDate
newdat$End.date <- newdat$endEventDate

#fix sex columns: The sex of the individual(s) represented in the data. 
#Different entries: F (female); M (male); M&F (both), H (hermaphrodite); 
#I (males of social bees); Q (queen); W (worker); U (unindentified).

newdat$Sex <- newdat$sex
unique(newdat$sex)

#remove social bees, M&F (both), hermaphrodite and the unidentified will be included as not.specified
unique(newdat$sex)
newdat <- newdat %>%
  filter(Sex %in% c("F", "M", "W", "Q")) 
newdat <- newdat %>%
  mutate(
    Female = ifelse(Sex %in% c("F", "Q"), 1, 0),
    Male = ifelse(Sex == "M", 1, 0), 
    Worker = ifelse(Sex == "W", 1, 0))

#Add "1" in Not.specified where all Female, Male, Not.specified are NAs.
newdat$Not.specified <- ifelse((newdat$Female == 0 & newdat$Male == 0),1,0)


#Tell Spanish province by coordinate (ine province names)
#Adapted from here (is fast :)
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

newdat$Longitude <- newdat$decimalLongitude
newdat$Latitude <- newdat$decimalLatitude
ine_province <- data.frame(x = newdat$Longitude, y = newdat$Latitude)

newdat$Province <- lonlat_to_state(ine_province)

#Delete leading and trailing spaces
newdat$Locality <- newdat$verbatimLocality
newdat$Locality <- trimws(newdat$Locality)
newdat$Locality <- gsub('"', "", newdat$Locality, fixed = TRUE)
newdat$Locality <- gsub('-', "", newdat$Locality, fixed = TRUE)
newdat$Locality <- gsub('\\', "", newdat$Locality, fixed = TRUE)
newdat$Locality <- gsub('^,|.$', '', newdat$Locality)
newdat$Locality <- gsub("<U\\+[^>]*>.*", "", newdat$Locality)
#delete numbers
newdat$Locality <- gsub("[0-9]", "", newdat$Locality)
#Run it again
newdat$Locality <- trimws(newdat$Locality)

#add and complete missing variables

newdat$Collector <-  NA
newdat$Determined.by <-  NA
newdat$Reference.doi <- "https://doi.org/10.1038/s41597-026-06644-2"
newdat$Flowers.visited <- NA
newdat$Local_ID <- "NA"
newdat$Authors.to.give.credit <- "A full list of authors and their affiliations appears at the end of the paper, see DOI"
newdat$Any.other.additional.data <- NA
newdat$Notes.and.queries <- NA
newdat$uid <- NA

#Fix latitude, longitude and coordinate.precision

newdat$Longitude <- round(newdat$decimalLongitude, 2)
newdat$Latitude <- round(newdat$decimalLatitude, 2)

#Round to 2 decimals to remove any possible duplicate locations. 

newdat$Coordinate.precision <- newdat$coordinateUncertaintyInMeters

unique(newdat$Coordinate.precision)

newdat <- newdat %>%
  select(Genus, Subgenus, Species, Subspecies, Country, Province, Locality, 
         Latitude, Longitude, Coordinate.precision, Year, Month, Day, 
         Start.date, End.date, Collector, Determined.by, Female, Male,
         Worker, Not.specified, Reference.doi, Flowers.visited, Local_ID, 
         Authors.to.give.credit, Any.other.additional.data, Notes.and.queries, uid)

#Save data
write.table(x = newdat, 
            file = "Data/Processed_raw_data/95_Ahlam_Sentil_et_al_2026.csv", 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

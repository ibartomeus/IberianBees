source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template


library(here)
library(readxl)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)

#read data
newdat <- read.csv(here("Data/Rawdata/csvs/89_Gbif_PT_bees.csv"), sep = ";")

#Compare vars
compare_variables(check, newdat) #Many variables missing.

#clean: select only variables to work with

newdat <- newdat %>%
  select(institutionID, collectionID ,datasetName, catalogNumber, recordedBy, individualCount, 
         sex, associatedReferences, otherCatalogNumbers, previousIdentifications, eventDate, 
         startDayOfYear, endDayOfYear, year, month, day, fieldNotes, countryCode, stateProvince, 
         municipality, locality, verbatimLocality, decimalLatitude, decimalLongitude, coordinatePrecision, 
         georeferencedBy, identificationID, verbatimIdentification, identifiedBy,identifiedByID, 
         identificationReferences, genus, subgenus,specificEpithet, issue, species)

#Add missing variables
newdat <- add_missing_variables(check, newdat)

newdat$Any.other.additional.data <- newdat$previousIdentifications

#Create Genus and species col by selecting 1st and 2nd element of the string in Species column
unique(newdat$species)
newdat$Genus <-  word(newdat$species, 1)
newdat$Species <-  word(newdat$species, 2)
newdat$Subgenus <-  newdat$subgenus

#fix countries, province and localities
#only three entries have "ZZ" which has no information from where was collected so I deleted: Bombus terrestris
#Bombus pascuorum and Xylocopa violacea.

unique(newdat$countryCode) 
newdat$Country <- newdat$countryCode
newdat <- newdat %>%
  filter(Country %in% c("PT")) 
newdat$Country[newdat$Country == "PT"] <- "Portugal"
newdat$Province <- newdat$stateProvince
newdat$Locality <- newdat$locality

#fix latitude and longitude

newdat$Longitude <- newdat$decimalLongitude
newdat$Latitude <- newdat$decimalLatitude
newdat$Coordinate.precision <- newdat$coordinatePrecision

#fix dates and keep the rows with NAs

newdat$Year <- newdat$year
newdat$Month <- newdat$month
newdat$Day <- newdat$day


#fix collector and determined by
newdat$Collector <- newdat$recordedBy
newdat$Determined.by <- newdat$identifiedBy

#Fix sexes 
unique(newdat$sex)
newdat$Female <- ifelse(newdat$sex == "FEMALE", 1, 0)
newdat$Male <- ifelse(newdat$sex == "MALE", 1, 0)

#Add "1" in Not.specified where all Female, Male, Not.specified are NAs.
newdat$Not.specified <- ifelse((newdat$Female == 0 & newdat$Male == 0), 1, 0)

#add missing variables 

newdat$Reference.doi <- newdat$institutionID
newdat$Local_ID <- newdat$collectionID
newdat$Notes.and.queries <- newdat$catalogNumber

#Add unique identifier
newdat$uid <- paste("89_Gbif_PT_bees", 1:nrow(newdat), sep = "_")

#Drop variables
newdat <- drop_variables(check, newdat)


#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/89_Gbif_PT_bees.csv", 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)




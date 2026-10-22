library(here)
library(readxl)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)

data <- read.csv(here("Data/Rawdata/csvs/89_Gbif_PT_bees.csv"), sep = ";")

#clean: select only variables to work with

newdata <- data %>%
  select(institutionID, collectionID ,datasetName, catalogNumber, recordedBy, individualCount, 
         sex, associatedReferences, otherCatalogNumbers, previousIdentifications, eventDate, 
         startDayOfYear, endDayOfYear, year, month, day, fieldNotes, countryCode, stateProvince, 
         municipality, locality, verbatimLocality, decimalLatitude, decimalLongitude, coordinatePrecision, 
         georeferencedBy, identificationID, verbatimIdentification, identifiedBy,identifiedByID, 
         identificationReferences, genus, subgenus,specificEpithet, issue, species)

##check with old identifications: The dataset includes information about previous identifications that are included in the template
#as additional data to not lose this information

species_check <- newdata %>%
  select(previousIdentifications, species) 

species_check <- species_check %>%
  separate(previousIdentifications,
           into = c("Previous_id", "ID_by"), sep = ",") 

species_check$valor <- ifelse(species_check$Previous_id == species_check$species, "same", "Dif")

table(species_check$valor)

newdata$Any.other.additional.data <- newdata$previousIdentifications

#Fix species categories

unique(newdata$genus)

newdata <- newdata %>%
  separate(species,
           into = c("Genus", "Species"), sep = " ")  %>%
  mutate(Genus = coalesce(genus, Genus))

newdata$Subgenus <- newdata$subgenus

newdata$Subspecies <- NA

#fix countries, province and localities

unique(newdata$countryCode) 
#only three entries have "ZZ" which has no information from where was collected so I deleted: Bombus terrestris
#Bombus pascuorum and Xylocopa violacea.

newdata$Country <- newdata$countryCode

newdata <- newdata %>%
  filter(Country %in% c("PT")) 

newdata$Province <- newdata$stateProvince

newdata$Locality <- newdata$locality

#fix latitude and longitude

newdata$Longitude <- newdata$decimalLongitude
newdata$Latitude <- newdata$decimalLatitude
newdata$Coordinate.precision <- newdata$coordinatePrecision

#fix dates and keep the rows with NAs

newdata$Year <- newdata$year
newdata$Month <- newdata$month
newdata$Day <- newdata$day

#fix start dates and end dates

newdata$fecha <- as.Date(newdata$startDayOfYear - 1, origin = paste0(newdata$Year, "-01-01"))
newdata$dia_mes <- as.integer(format(newdata$fecha, "%d"))

#check if start and end date match with Day and if so, merge

check_dates <- newdata %>%
  select(fecha, dia_mes, Day, Month, Year, Start.date)

newdata$Start.date <- newdata$startDayOfYear
newdata$End.date <- newdata$endDayOfYear

colnames(newdata)

#fix collector and determined by

newdata$Collector <- newdata$recordedBy

newdata$Determined.by <- newdata$identifiedBy

#Fix sexes 
unique(newdata$sex)
newdata$Female <- ifelse(newdata$sex == "FEMALE", 1, 0)
newdata$Male <- ifelse(newdata$sex == "MALE", 1, 0)
newdata$Worker <- NA

#Add "1" in Not.specified where all Female, Male, Not.specified are NAs.
newdata$Not.specified <- ifelse((newdata$Female == 0 & newdata$Male == 0), 1, 0)

#add missing variables 

newdata$Subgenus <- newdata$subgenus
newdata$Reference.doi <- newdata$institutionID
newdata$Flowers.visited <- NA
newdata$Local_ID <- newdata$collectionID
newdata$Authors.to.give.credit <- NA
newdata$Notes.and.queries <- newdata$catalogNumber

#Select columns for final template csv 

newdata <- newdata %>%
  select(Genus, Subgenus, Species, Subspecies, Country, Province, Locality, 
         Latitude, Longitude, Coordinate.precision, Year, Month, Day, 
         Start.date, End.date, Collector, Determined.by, Female, Male,
         Worker, Not.specified, Reference.doi, Flowers.visited, Local_ID, 
         Authors.to.give.credit, Any.other.additional.data, Notes.and.queries)

#Save data
write.table(x = newdata, file = "Data/Processed_raw_data/89_Gbif_PT_bees.csv", 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)




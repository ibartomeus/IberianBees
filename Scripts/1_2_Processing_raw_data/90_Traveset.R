library(here)
library(readxl)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)


data <- read.csv(here("Data/Rawdata/csvs/90_Traveset.csv"), sep = ";")

#Subset bees: subset Hymenoptera with only Apidae as bee group
newdata <- subset(data, family == "Apidae")

#This database contained specificEpithet that refers to species and infraspecificepithets that are subpecies
#
newdata$Genus <- newdata$genus
newdata$Subgenus <- NA
newdata$Species <- newdata$specificEpithet
newdata$Subspecies <- newdata$infraspecificEpithet

newdata <- newdata %>%
  mutate(Species = word(Species, 1)) #remove species and subspecies from the same column

#fix country, province and locality

newdata$Country <- newdata$country
newdata <- newdata %>%
  mutate(Country = recode(Country, 
                          "Espanya" = "Spain"))

newdata$Province <- newdata$stateProvince
newdata$Locality <- newdata$locality

#fix coordinates

newdata$Longitude <- newdata$decimalLongitude
newdata$Latitude <- newdata$decimalLatitude
newdata$Coordinate.precision <- newdata$coordinateUncertaintyInMeters


#fix dates

newdata <- newdata %>%
  separate(verbatimEventDate,
           into = c("Day", "Month", "Year"),
           sep = "/")

#fix sexes

newdata$Female <- 0
newdata$Male <- 0
newdata$Worker <- 0

#Add "1" in Not.specified where all Female, Male, Not.specified are NAs.
newdata$Not.specified <- ifelse((newdata$Female == 0 & newdata$Male == 0),1,0)


#add missing variables

newdata$Collector <- NA
newdata$Determined.by <- NA
newdata$Start.date <- NA
newdata$End.date <- NA
newdata$Reference.doi <- "https://ipt.gbif.es/resource?r=imedea-insecta&v=1.14"
newdata$Flowers.visited <- NA
newdata$Local_ID <- newdata$id
newdata$Authors.to.give.credit <- "Traveset, A; Díaz-Lorca, A"
newdata$Any.other.additional.data <- newdata$municipality 
newdata$Notes.and.queries <- newdata$datasetName 

#Select columns for final template csv

newdata <- newdata %>%
  select(Genus, Subgenus, Species, Subspecies, Country, Province, Locality, 
         Latitude, Longitude, Coordinate.precision, Year, Month, Day, 
         Start.date, End.date, Collector, Determined.by, Female, Male,
         Worker, Not.specified, Reference.doi, Flowers.visited, Local_ID, 
         Authors.to.give.credit, Any.other.additional.data, Notes.and.queries)

#Save data
write.table(x = newdata, file = "Data/Processed_raw_data/90_Traveset", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)


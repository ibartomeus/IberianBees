source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

library(here)
library(readxl)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)
library(stringi)

#read data
newdat <- read.csv(here("Data/Rawdata/csvs/88_Baptista_et_al_2026.csv"), sep = ";")

#Compare vars
compare_variables(check, newdat) #Many variables missing.

#Add missing variables
newdat <- add_missing_variables(check, newdat)

#Create Genus and species col by selecting 1st and 2nd element of the string in Species column
unique(newdat$species)
newdat$Genus <-  word(newdat$species, 1)
newdat$Species <-  word(newdat$species, 2)
newdat$Subspecies <-  newdat$infraspecificEpithet
#remove rows with NA in Species 
newdat <- newdat[!is.na(newdat$Species), ]

#fix date column

newdat$Day <- newdat$day
newdat$Month <- newdat$month
newdat$Year <- newdat$year

#fix country, province and localilties

newdat$Country <- newdat$countryCode
newdat$Country <- "Portugal"
unique(newdat$Country)

newdat$Province <- newdat$stateProvince
newdat$Locality <- newdat$locality

#fix longitude and latitude

newdat$Latitude <- newdat$decimalLatitude
newdat$Longitude <- newdat$decimalLongitude
newdat$Coordinate.precision <- newdat$coordinatePrecision

#fix collector and determined by 
newdat$Collector <- newdat$recordedBy
newdat$Determined.by <- newdat$identifiedBy

newdat$Reference.doi <- "https://doi.org/10.3897/BDJ.14.e188597"
newdat$Local_ID <- newdat$catalogNumber
newdat$Authors.to.give.credit <- "Martim Baptista; Paulo de Sousa & Roberto A. Keller"

#catalogue number add as additional information so it doesn´t get lost
newdat$Any.other.additional.data <- newdata$catalogNumber
newdat$Notes.and.queries <- NA

#Add unique identifier
newdat$uid <- paste("88_Baptista_et_al_2026", 1:nrow(newdat), sep = "_")

#Drop variables
newdat <- drop_variables(check, newdat)

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/88_Baptista_et_al_2026.csv", 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

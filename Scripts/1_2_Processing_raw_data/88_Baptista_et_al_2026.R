
library(here)
library(readxl)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)
library(stringi)

data <- read.csv(here("Data/Rawdata/csvs/88_Baptista_et_al_2026.csv"), sep = ";")

## fix Species column 

newdata <- data %>%
  separate(species,
           into = c("Genus", "Species"), sep = " ") %>%
  mutate(Genus = coalesce(genus, Genus))


#fix date column

newdata$Day <- as.numeric(newdata$day)
newdata$Month <- as.numeric(newdata$month)
newdata$Year <- as.numeric(newdata$year)

#fix country, province and localilties

newdata$Country <- newdata$countryCode
newdata$Country <- "Portugal"

unique(newdata$Province)

newdata$Province <- newdata$stateProvince

newdata <- newdata %>%
  mutate(
    Province = recode(Province, 
                      "SantarÃ©m" = "Santarem",
                      "BraganÃ§a" = "Braganza", 
                      "RegiÃ£o AutÃ³noma da Madeira" = "Regiao Autonoma de Madeira", 
                      "SetÃºbal" = "Setubal", 
                      "RegiÃ£o AutÃ³noma dos AÃ§ores" = "Regiao Autonoma de Azores", 
                      "Ã‰vora" = "Evora"))
                

newdata$Locality <- newdata$locality

#fix longitude and latitude

newdata$Latitude <- newdata$decimalLatitude
newdata$Longitude <- newdata$decimalLongitude
newdata$Coordinate.precision <- newdata$coordinatePrecision

#fix collector and determined by 
newdata$Collector <- newdata$recordedBy
newdata$Determined.by <- newdata$identifiedBy


##add missing variables 

newdata$Subgenus <- NA
newdata$Subspecies <- NA
newdata$Start.date <- NA
newdata$End.date <- NA
newdata$Female <- NA
newdata$Male <- NA
newdata$Worker <- NA
newdata$Not.specified <- NA
newdata$Flowers.visited <- NA
newdata$Reference.doi <- "https://doi.org/10.3897/BDJ.14.e188597"
newdata$Local_ID <- NA
newdata$Authors.to.give.credit <- "Martim Baptista; Paulo de Sousa & Roberto A. Keller"

#catalogue number add as additional information so it doesn´t get lost
newdata$Any.other.additional.data <- newdata$catalogNumber
newdata$Notes.and.queries <- NA

#Seleccionar columnas para csv final 

newdata <- newdata %>%
  select(Genus, Subgenus, Species, Subspecies, Country, Province, Locality, 
         Latitude, Longitude, Coordinate.precision, Year, Month, Day, 
         Start.date, End.date, Collector, Determined.by, Female, Male,
         Worker, Not.specified, Reference.doi, Flowers.visited, Local_ID, 
         Authors.to.give.credit, Any.other.additional.data, Notes.and.queries)

#Add unique identifier
newdata$uid <- paste("88_Baptista_et_al_2026", 1:nrow(newdata), sep = "")


#Save data
write.table(x = newdata, file = "Data/Processed_raw_data/88_Baptista_et_al_2026.csv", 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

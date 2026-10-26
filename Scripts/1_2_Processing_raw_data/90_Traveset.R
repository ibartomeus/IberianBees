source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template


library(here)
library(readxl)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)


newdat <- read.csv(here("Data/Rawdata/csvs/90_Traveset.csv"), sep = ";")

#Subset bees: subset Hymenoptera with only Apidae as bee group
newdat <- subset(newdat, family == "Apidae")

#Compare vars
compare_variables(check, newdat) #Many variables missing.

#Add missing variables
newdat <- add_missing_variables(check, newdat)
head(newdat)

#This database contained specificEpithet that refers to species and infraspecificepithets that are subpecies
#
newdat$Genus <- newdat$genus
newdat$Species <- newdat$specificEpithet
newdat$Subspecies <- newdat$infraspecificEpithet

#fix country, province and locality

newdat$Country <- newdat$country
newdat <- newdat %>%
  mutate(Country = recode(Country, 
                          "Espanya" = "Spain"))

newdat$Province <- newdat$stateProvince
newdat$Locality <- newdat$locality

#fix coordinates

newdat$Longitude <- newdat$decimalLongitude
newdat$Latitude <- newdat$decimalLatitude
newdat$Coordinate.precision <- newdat$coordinateUncertaintyInMeters


#fix dates

newdat <- newdat %>%
  separate(verbatimEventDate,
           into = c("Day", "Month", "Year"),
           sep = "/")

#fix sexes

newdat$Female <- 0
newdat$Male <- 0
newdat$Worker <- 0

#Add "1" in Not.specified where all Female, Male, Not.specified are NAs.
newdat$Not.specified <- ifelse((newdat$Female == 0 & newdata$Male == 0),1,0)


#add missing variables

newdat$Reference.doi <- "https://ipt.gbif.es/resource?r=imedea-insecta&v=1.14"
newdat$Local_ID <- newdata$id
newdat$Authors.to.give.credit <- "Traveset, A; Díaz-Lorca, A"

#Add unique identifier
newdat$uid <- paste("90_Traveset", 1:nrow(newdat), sep = "_")

#Drop variables
newdat <- drop_variables(check, newdat)

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/90_Traveset", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)


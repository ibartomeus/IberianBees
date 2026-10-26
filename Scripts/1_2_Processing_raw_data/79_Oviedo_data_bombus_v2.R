source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template


library(here)
library(readxl)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/79_Oviedo_data_bombus_v2.csv', sep = ";")

#Compare vars
compare_variables(check, newdat) #Many variables missing.

#Add missing variables
newdat <- add_missing_variables(check, newdat)

#Fix species level and select only the one identified to species level. Some identifications are missing 

unique(newdat$scientificName)

newdat <- newdat %>%
  separate(scientificName,
           into = c("Genus","Subgenus", "Subspecies", "Species"), sep = " ", fill = "right") 

newdat <- newdat %>%
  mutate(Subgenus = str_remove_all(Subgenus, "[()]")) %>%
  filter(!is.na(Genus), trimws(Genus) != "") #remove NA and empty values

#Filter only Spain data and correct provinces and localities

newdat$Country <- newdat$country

newdat <- newdat %>%
  filter(Country == "Spain")

newdat$Province <- newdat$stateProvince
newdat$Locality <- newdat$locality

#Fix dates

newdat$Year <- newdat$year
newdat$Month <- newdat$month
newdat$Day <- newdat$day

#Fix Collector and determined by

newdat$Collector <- newdat$recordedBy
newdat$Determined.by <- newdat$identifiedBy


#Fix sex information. There are female, male, worker and queen id

newdat$Sex <- newdat$sex

newdat <- newdat %>%
  mutate(
    Female = ifelse(Sex %in% c("Female", "Queen"), 1, 0),
    Male = ifelse(Sex == "Male", 1, 0), 
    Worker = ifelse(Sex == "Worker", 1, 0))

#Add "1" in Not.specified where all Female, Male, Not.specified are NAs.
unique(newdat$Not.specified)
newdat$Not.specified <- ifelse((newdat$Female == 0 & newdat$Male == 0),1,0)

#Fix latitude, longitude and coordinate.precision

newdat$Longitude <- newdat$decimalLongitude
newdat$Latitude <- newdat$decimalLatitude
newdat$Coordinate.precision <- newdat$coordinateUncertaintyInMeters


##complete variables from the template
newdat$Reference.doi <- "https://doi.org/10.15470/kdd3tb"

newdat$Local_ID <- newdat$catalogNumber
newdat$Authors.to.give.credit <- "Nuñez Carbajal A, Doblas-Bajo M, Fernandez-Enriquez O, Castro Santos L, Torrado-Blanco L, F. Ojanguren A, Orizaola G"

unique(newdat$Year)

#Add unique identifier
newdat$uid <- paste("79_Oviedo_data_bombus_v2", 1:nrow(newdat), sep = "_")

#Drop variables
newdat <- drop_variables(check, newdat)


#Save data
write.table(x = newdat, 
            file = "Data/Processed_raw_data/79_Oviedo_data_bombus_v2.csv", 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

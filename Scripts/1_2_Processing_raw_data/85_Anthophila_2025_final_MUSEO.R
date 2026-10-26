source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

library(here)
library(readxl)
library(dplyr)
library(lubridate)

#read data
newdat <- read.csv(here("Data/Rawdata/csvs/85_Anthophila_2025_final_MUSEO.csv"), sep= ";")

#Compare vars
compare_variables(check, newdat) #Many variables missing.

#Add missing variables
newdat <- add_missing_variables(check, newdat)

newdat$Genus <- newdat$GENERO
newdat$Subgenus <- newdat$SUBGEN
newdat$Species <- newdat$ESPECIE

#fix dates

newdat <- newdat %>%
  separate(fecha.standard,
           into = c("Day", "Month", "Year"), sep = "/") 

#fix sex columns

unique(newdat$SEXO)
newdat <- newdat %>%
  mutate(
    Female = ifelse(SEXO == "hembra", 1, 0),
    Male = ifelse(SEXO == "macho", 1, 0))

#Add "1" in Not.specified where all Female, Male, Not.specified are NAs.
newdat$Not.specified <- ifelse((newdat$Female == 0 & newdat$Male == 0),1,0)
newdat$Country <- newdat$PAIS
#rename Spain
newdat$Country[newdat$Country == "España"] <- "Spain"
#add provinces and localities
newdat$Province <- newdat$PROVINCIA
unique(newdat$Province)
newdat$Locality <- newdat$LOCALIDAD_ACTUAL

newdat$Collector <- newdat$COLECTOR
newdat$Determined.by <- newdat$DETERM

newdata$Authors.to.give.credit <- "Piluca Alvarez Fidalgo and MNCN"

#Add unique identifier
newdat$uid <- paste("85_Anthophila_2025_final_MUSEO", 1:nrow(newdat), sep = "_")


#Drop variables
newdat <- drop_variables(check, newdat)


#export final dataset
write.table(x = newdat, file = "Data/Processed_raw_data/85_Anthophila_2025_final_MUSEO.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)



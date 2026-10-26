source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

library(here)
library(readxl)
library(dplyr)
library(lubridate)

#Read data

newdat <- read.csv(here("Data/Rawdata/csvs/86_COMPLEX_Apoidea_Barthomeus_2021.csv"), sep = ";")

#Compare vars
compare_variables(check, newdat) #Many variables missing.

#Add missing variables
newdat <- add_missing_variables(check, newdat)

#Add genus, species, subg and ssp

newdat$Genus <- newdat$tGenero
newdat$Species <- newdat$tEspecie
newdat$Subgenus <- newdat$tSubgenero
newdat$Subspecies <- newdat$Infra

#rename country and add provinces and localities
newdat$Country <- newdat$Pais
#rename Spain
newdat$Country[newdat$Country == "España"] <- "Spain"

newdat$Province <- newdat$Provincia
newdat$Locality <- newdat$LocalidadOrig

#fix sex
newdat$Female <- ifelse(newdat$tSexo == "hembra", 1, 0)
newdat$Male <- ifelse(newdat$tSexo == "macho", 1, 0)

#Add "1" in Not.specified where all Female, Male, Not.specified are NAs.
newdat$Not.specified <- ifelse(
  (newdat$Female == 0 & newdat$Male == 0), 1, 0)

#fix dates
newdat$Year <- newdat$nAnio
newdat$Month <- newdat$nMes
newdat$Day <- newdat$nDia

newdat$Collector <- newdat$tColector
newdat$Determined.by <- newdat$tAutorDeterminacion
newdat$Local_ID <- newdat$nNoCatalogo

#Add unique identifier
newdat$uid <- paste("86_COMPLEX_Apoidea_Barthomeus_2021", 1:nrow(newdat), sep = "_")

#Drop variables
newdat <- drop_variables(check, newdat)


#export csv final
write.table(x = newdat, file = "Data/Processed_raw_data/86_COMPLEX_Apoidea_Barthomeus_2021.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)


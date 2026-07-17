library(here)
library(readxl)
library(dplyr)
library(lubridate)

#Read data

data <- read.csv(here("Data/Rawdata/csvs/86_COMPLEX_Apoidea_Barthomeus_2021.csv"), sep = ";")
colnames(data)

#cambiar nombres de las columnas al formato del Template

newdata <- data %>%
  rename(
    Genus = "tGenero",
    Subgenus = "tSubgenero", 
    Species = "tEspecie", 
    Country = "Pais", 
    Province = "Provincia", 
    Locality = "tLocalidad", 
    Day = "nDia", 
    Month ="nMes",
    Year = "nAnio", 
    Collector = "tColector", 
    Determined.by = "tAutorDeterminacion", 
    Worker = "tProcedencia", 
    Authors.to.give.credit = "tAutor", 
    Notes.and.queries = "tNotas",
    Any.other.additional.data = "tNotasCaptura")

#corregir columna Sexo

unique(newdata$tSexo)
newdata$tSexo <- tolower(newdata$tSexo)

newdata$Female <- ifelse(newdata$tSexo == "hembra", 1, 0)
newdata$Male <- ifelse(newdata$tSexo == "macho", 1, 0)

#Add "1" in Not.specified where all Female, Male, Not.specified are NAs.
newdata$Not.specified <- ifelse(
  (newdata$Female == 0 & newdata$Male == 0), 1, 0)

#add missing variables 

newdata$Subspecies <- NA
newdata$Latitude <- NA
newdata$Longitude <- NA
newdata$Coordinate.precision <- NA
newdata$Start.date <- NA
newdata$End.date <- NA
newdata$Reference.doi <- "MNCN"
newdata$Flowers.visited <- NA
newdata$Local_ID <- NA
newdata$Any.other.additional.data <- NA
newdata$Notes.and.queries <- NA

#Seleccionar columnas para csv final 

newdata <- newdata %>%
  select(Genus, Subgenus, Species, Subspecies, Country, Province, Locality, 
         Latitude, Longitude, Coordinate.precision, Year, Month, Day, 
         Start.date, End.date, Collector, Determined.by, Female, Male,
         Worker, Not.specified, Reference.doi, Flowers.visited, Local_ID, 
         Authors.to.give.credit, Any.other.additional.data, Notes.and.queries)

#exportar csv final
write.table(x = newdata, file = "Data/Processed_raw_data/86_COMPLEX_Apoidea_Barthomeus_2021.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)


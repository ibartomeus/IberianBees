
library(readxl)
library(dplyr)
library(lubridate)


data <- read.csv(here("Data/Rawdata/csvs/85_Anthophila_2025_final_MUSEO.csv"), sep= ";")

#cambiar nombres de las columnas al formato del Template

newdata <- data %>%
  rename(
    Genus = "GENERO",
    Subgenus = "SUBGEN", 
    Species = "ESPECIE", 
    Country = "PAIS", 
    Province = "PROVINCIA", 
    Locality = "LOCALIDAD_ACTUAL", 
    Year = "ANHO_DETERM", 
    Date_collection = "fecha standard", 
    Collector = "COLECTOR", 
    Determined.by = "DETERM", 
    Worker = "PROCEDENCIA")

#corregir formato fecha
newdata$Date_collection <- as.Date(as.numeric(newdata$Date_collection), origin = "1899-12-30")
newdata$Day   <- format(newdata$Date_collection, "%d")
newdata$Month <- format(newdata$Date_collection, "%m")
newdata$Year  <- format(newdata$Date_collection, "%Y")

#fix sex columns

unique(newdata$SEXO)
newdata <- newdata %>%
  mutate(
    Female = ifelse(SEXO == "hembra", 1, 0),
    Male = ifelse(SEXO == "macho", 1, 0)
  )

#Add "1" in Not.specified where all Female, Male, Not.specified are NAs.
newdata$Not.specified <- ifelse((newdata$Female == 0 & newdata$Male == 0),1,0)


#a?adir columnas del template que no tienen datos y completar

newdata$Subspecies <- NA
newdata$Latitude <- NA
newdata$Longitude <- NA
newdata$Coordinate.precision <- NA
newdata$Start.date <- NA
newdata$End.date <- NA
newdata$Reference.doi <- NA
newdata$Flowers.visited <- NA
newdata$Local_ID <- NA
newdata$Authors.to.give.credit <- "Piluca ?lvarez Fidalgo and MNCN"
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
write.table(x = newdata, file = "C:/Users/maria/OneDrive/Escritorio/Maria_Jose/Proyectos_git/IberianBees/Data/Processed_raw_data/85_Anthophila_2025_final_MUSEO.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)



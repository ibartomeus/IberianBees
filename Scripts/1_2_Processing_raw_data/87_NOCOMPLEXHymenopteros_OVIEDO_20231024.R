
#cargar paquetes
library(here)
library(readxl)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)
library(stringi)

data <- read.csv(here("Data/Rawdata/csvs/87_NOCOMPLEXHymenopteros_OVIEDO_20231024.csv"), sep = ";")

#Subset bees
sort(unique(newdata$Familia))
newdata <- subset(data,
                  Familia == "Apidae" |
                    Familia == "Andrenidae" |
                    Familia == "Colletidae" | 
                    Familia == "Halictidae" | 
                    Familia == "Megachilidae" | 
                    Familia == "Melittidae")

## fix Species column 

unique(data$Especie)

newdata <- newdata %>%
  separate(
    col = Especie,
    into = c("Genus", "Species"),
    sep = " ",  extra = "merge",
    fill = "right")%>%
  separate(
    col = Species,
    into = c("Subgenus", "Species"),
    sep = " ",  extra = "merge",
    fill = "left")

#fix date column

newdata$Fecha <- as.Date(as.numeric(newdata$Fecha), origin = "1899-12-30")
newdata$Day   <- format(newdata$Fecha, "%d")
newdata$Month <- format(newdata$Fecha, "%m")
newdata$Year  <- format(newdata$Fecha, "%Y")

newdata$Year <- str_extract(newdata$Fecha, "\\b19\\d{2}\\b|\\b20\\d{2}\\b") #When a four-digit starts with either "19" or "20", assign it to Year.

newdata$Month <- as.integer(sub(".*[-_/](\\d{2})[-_/].*", "\\1", newdata$Fecha))

newdata$Day <- ifelse(grepl("^\\d{4}-\\d{2}-\\d{2}$", newdata$Fecha),
                      as.integer(sub(".*-(\\d{2})$", "\\1", newdata$Fecha)), #Note that only days have an underscore.
                      NA)

#fix localilties, provinces and country

newdata$Province <- newdata$Provincia
newdata$Locality <- newdata$Localidad
newdata$Country <- newdata$Pa?s

#Fix sexes: just one "Zangano" so I leave it out. Same with 

newdata$Female <- ifelse(newdata$Sexo == "Hembra", 1, NA)
newdata$Male <- ifelse(newdata$Sexo == "Macho", 1, NA)

#Add "1" in Not.specified where all Female, Male, Not.specified are NAs.
newdata$Not.specified <- ifelse(
  (newdata$Female == 0 & newdata$Male == 0) |
    (is.na(newdata$Female) & is.na(newdata$Male)), 1, 0)


#fix collector
newdata$Collector <- newdata$Recolector

#Merge Identificador-vars and put in Determined.by

newdata$Determined.by <- apply(newdata[, c("Identificador", "Identificador 2", "Identificador 3")],
                               1,  function(x) paste(x[!is.na(x) & x != ""], collapse = ", "))

#no data about longitude or latitude

newdata$Latitude <- newdata$latitud
newdata$Longitude <- newdata$longitud

##add missing variables 

newdata$Subspecies <- NA
newdata$Coordinate.precision <- NA
newdata$Start.date <- NA
newdata$End.date <- NA
newdata$Worker <- NA
newdata$Reference.doi <- NA
newdata$Flowers.visited <- NA
newdata$Local_ID <- NA
newdata$Authors.to.give.credit <- "Oviedo Museum"
newdata$Any.other.additional.data <- newdata$H?bitat
newdata$Notes.and.queries <- newdata$Observaciones

#Seleccionar columnas para csv final 

newdata <- newdata %>%
  select(Genus, Subgenus, Species, Subspecies, Country, Province, Locality, 
         Latitude, Longitude, Coordinate.precision, Year, Month, Day, 
         Start.date, End.date, Collector, Determined.by, Female, Male,
         Worker, Not.specified, Reference.doi, Flowers.visited, Local_ID, 
         Authors.to.give.credit, Any.other.additional.data, Notes.and.queries)

#Add unique identifier
newdata$uid <- paste("87_NOCOMPLEXHymenopteros_OVIEDO_20231024", 1:nrow(newdata), sep = "")


#Save data
write.table(x = newdata, file = 'C:/Users/maria/OneDrive/Escritorio/Maria_Jose/Proyectos_git/IberianBees/Data/Processed_raw_data/87_NOCOMPLEXHymenopteros_OVIEDO_20231024.csv', 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

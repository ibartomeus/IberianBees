setwd("C:/Users/maria/Dropbox/Spanish_Bees/done/Data_MJ")


#cargar paquetes
library(here)
library(readxl)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)
library(stringi)

#upload dataset 
data <- read.csv(here("Data/Rawdata/csvs/79_Oviedo_museum.csv"), sep = ";")

#Subset bees
newdat <- subset(data,
                 Familia == "Apidae" |
                   Familia == "Andrenidae" |
                   Familia == "Colletidae" | 
                   Familia == "Halictidae" | 
                   Familia == "Megachilidae" | 
                   Familia == "Melittidae")

#Put some additional info from variables Hábitat and Observaciones.

newdat$Subgenus <- NA
newdat$Subspecies <- NA
newdat$Latitude <- NA
newdat$Longitude <- NA
newdat$Coordinate.precision <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$Worker <- NA
newdat$Reference.doi <- NA
newdat$Flowers.visited <- NA
newdat$Local_ID <- newdat$?..ID
newdat$Authors.to.give.credit <- "Oviedo Museum"
newdat$Any.other.additional.data <- newdat$H?.bitat
newdat$Notes.and.queries <- newdat$Observaciones


#Merge Identificador-vars and put in Determined.by
newdat$Determined.by <- ifelse(newdat$Identificador.3 != "",
                               paste(newdat$Identificador, newdat$Identificador.2, newdat$Identificador.3, sep = ", "),
                               paste(newdat$Identificador, newdat$Identificador.2, sep = ", "))

newdat$Determined.by <- trimws(newdat$Determined.by, whitespace = ", ")

#fix collector

newdat$Collector <- newdat$Recolector
newdat$Collector <- stri_trans_general(newdat$Collector, "Latin-ASCII")


#Fix sexes. There is only one observation of zángano, so I'm ignoring/removing this one. 
newdat$Female <- ifelse(newdat$Sexo == "Hembra", 1, NA)
newdat$Male <- ifelse(newdat$Sexo == "Macho", 1, NA)

#Add "1" in Not.specified where all Female, Male, Not.specified are NAs.
newdat$Not.specified <- ifelse(
  (newdat$Female == 0 & newdat$Male == 0) |
    (is.na(newdat$Female) & is.na(newdat$Male) | is.na(newdat$Worker)), 1, 0)


## fix Species column 

newdat <- newdat %>%
  separate(
    col = Especie,
    into = c("Genus", "Species"),
    sep = " ",  extra = "merge",
    fill = "right")

#Fix countries, provincies and localities. 

newdat$Locality <- newdat$Localidad
newdat$Province <- newdat$Provincia
newdat$Country <- newdat$Pa?.s
newdat <- newdat %>%
  mutate(
    Country = recode(Country, 
                     "México" = "Mexico", 
                     "España" = "Spain", 
                     "Francia" = "France"))

newdat <- newdat %>%
  mutate(
    Locality = recode(Locality, 
                  "S. Lázaro" = "S. Lazaro",
         "Tereñes" = "Tere?es", "Gijón" = "Gijon", "San Martín" = "San Martin", 
"Muros de Nalón" = "Muros de Nalon", "Peón" = "Peon", "León" = "Leon", "Panjón" = "Panjon", 
"Universidad Laboral Gijón" = "Universidad Labora de Gijon", "Serín" = "Serin", "Río Cares" = "Rio Cares", "Santa Mª del Mar" = "Santa Maria del Mar", 
"Orlé" = "Orle", "S. Martín de Podes" = "San Martin de Podes", "Cabueñes" = "Cabue?es", 
"Palomas (río)" = "Palomas (r?o)", "Peñaullán" = "Pe?aullan", "Polígono de Silvota" = "Poligono de Silvota", 
"Ablaña" = "Abla?a", "Agüera" = "Aguera", "Agüero" = "Aguero","Agües" = "Aguanes", "Avín" = "Avin", 
"Avilés" = "Aviles", "Bárcena" = "Barcena","Bañugues" = "Banuges",  "Baiña" = "Bahia","Beleño" = "Beleno",
"Boñar" = "Bonar", "Brañace (Aramo)" = "Branace", "Brañes" = "Branes","Cáceres" = "Caceres", "Cármenes" = "Carmenes", 
"Cabañaquinta" = "Cabanaquinta", "Cabezón de Pisuerga" = "Cabezon de Pisuerga", "Cabuérniga" = "Cabuerniga","Cabueñes" = "Cabue?es", 
"Campos próximos al Masaveu" = "Campos proximos al Masaveu", "Candás" = "Candas", 
"Castañeda" = "Castaneda", "Cayés" = "Cayes", "Ceares (Gijón)" = "Ceares (Gijon)","Cerbón" = "Cerbon",
"Ciaño" = "Cianu", "Doñajuandi" = "Donajuandi", "El Berrón" = "El Berron", "El Campón (Salinas)" = "Camping Salinas",
"El Carbayo (Ciaño)" = "El Carbayo (Ciano)", "El Fondón (San Justo9" = "El Fondin (San Justo)","El Orrín (Infiesto)" = "El Orrin (Infiesto)",
"El playón de Bayas" = "El playon de Bayas", "El Subidorio (Valle de Turón" = "El Subidorio (Valle del Turon", 
"El Vallín (Luarca)" = "El Vallin (Luarca)","Elgóibar" = "Elgoibar", "Embalse de S. Andrés" = "Embalse de San Andres", 
"Ereño" = "Ereno", "F. Biológicas (Oviedo)" = " F. Biologicas (Oviedo)", "Fabarín" = "Fabarin", 
"Fernán Caballero" = "Fernan Caballero","Fuenterrabía" = "Fuenterrabia", "Geras de Gordón" = "Geras de Gordon", 
"Gijón" = "Gijon","Gijón (Los Compones)" = "Gijon (Los Compones)", "Hoces de Río Pino" = "Hoces de Rio Pino", 
"Huétor Santillán" = "Huetor Santillan","Infanzón" = "Infanzon", "La Barraca-Riaño" = "La Barraca", 
"La Bañeza" = "La Ba?eza", "La Candamia (León)" = "La Candamia (Leon)","La Luz (Avilés)" = "La Luz (Aviles)", 
"La Peña" = " La pena", "Ablaña" = "Ablana", "Aboño" = "Abono", "Ajuyán (Brañes)" = "Ajuyan (Branes)", 
"Los Maizales (Gijón)" = "Los Maizales (Gijon)", "Somió" = "Somio"))

#Fix dates.

newdat$Year <- str_extract(newdat$Fecha, "\\b19\\d{2}\\b|\\b20\\d{2}\\b") #When a four-digit starts with either "19" or "20", assign it to Year.

newdat$Month <- as.integer(sub(".*[-_/](\\d{2})[-_/].*", "\\1", newdat$Fecha))

newdat$Day <- ifelse(grepl("^\\d{4}-\\d{2}-\\d{2}$", newdat$Fecha),
                     as.integer(sub(".*-(\\d{2})$", "\\1", newdat$Fecha)), #Note that only days have an underscore.
                     NA)

selection <- select(newdat, Fecha, Year, Month, Day)
#View(selection) #There are some Fechas that have weird formats, eg 13/?/1993, 25/03 ó 04/1975, 1/2 Septiembre.
#These are very few (around 20), hence I don't spend time fixing all these. Years tho are always fixed.

#Seleccionar columnas para csv final 

newdat <- newdat %>%
  select(Genus, Subgenus, Species, Subspecies, Country, Province, Locality, 
         Latitude, Longitude, Coordinate.precision, Year, Month, Day, 
         Start.date, End.date, Collector, Determined.by, Female, Male,
         Worker, Not.specified, Reference.doi, Flowers.visited, Local_ID, 
         Authors.to.give.credit, Any.other.additional.data, Notes.and.queries)



#Save data
write.table(x = newdat, file = 'C:/Users/maria/OneDrive/Escritorio/Maria_Jose/Proyectos_git/IberianBees/Data/Processed_raw_data/79_Oviedo_museum_v2.csv', 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

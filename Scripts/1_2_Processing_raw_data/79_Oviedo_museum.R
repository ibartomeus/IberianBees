source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 79_Oviedo_museum ---- (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/79_Oviedo_museum.csv', sep = ";")

#Compare vars
compare_variables(check, newdat) #All variables missing. 

#Note that this dataset doesn't contain any coordinates.

#Add missing variables
newdat <- add_missing_variables(check, newdat)  #All variables added since the original dataset has everything in Spanish.


#Subset bees
newdat <- subset(newdat,
                 Familia == "Apidae" |
                   Familia == "Andrenidae" |
                   Familia == "Colletidae" | 
                   Familia == "Halictidae" | 
                   Familia == "Megachilidae" | 
                   Familia == "Melittidae")

newdat <- filter(newdat, newdat$Especie != "Apis mellifera")

#Merge Identificador-vars and put in Determined.by
newdat$Determined.by <- ifelse(newdat$Identificador.3 != "",
                               paste(newdat$Identificador, newdat$Identificador.2, newdat$Identificador.3, sep = ", "),
                               paste(newdat$Identificador, newdat$Identificador.2, sep = ", "))

newdat$Determined.by <- trimws(newdat$Determined.by, whitespace = ", ")

unique(newdat$Sexo)
#Fix sexes. There is only one observation of zángano, so I'm ignoring/removing this one. 
newdat$Female <- ifelse(newdat$Sexo == "Hembra", 1, NA)
newdat$Male <- ifelse(newdat$Sexo == "Macho", 1, NA)

#Add "1" in Not.specified where all Female, Male, Worker, Not.specified are NAs.
na_rows <- is.na(newdat$Female) & is.na(newdat$Male) & is.na(newdat$Worker) & is.na(newdat$Not.specified)
newdat$Not.specified[na_rows] <- 1

#Fix countries, provincies and localities. 
newdat$Country <- newdat$País
newdat <- newdat |>
  mutate(Country = recode(Country, "México" = "Mexico", "España" = "Spain", "Francia" = "France"))

newdat$Province <- newdat$Provincia
newdat$Locality <- paste(newdat$Localidad, newdat$Municipio, sep = ", ")

#Fix species.
newdat$Genus <- str_extract(newdat$Especie, "^\\S+")  #Extracts the first word as Genus
newdat$Species <- str_trim(str_replace(newdat$Especie, newdat$Genus, ""))  #Extracts the rest as Species
newdat$Species <- str_trim(newdat$Species) #Trim blank spaces

#Put some additional info from variables Hábitat and Observaciones.
newdat$Any.other.additional.data <- newdat$Hábitat
newdat$Notes.and.queries <- newdat$Observaciones
newdat$Local_ID <- newdat$ID

#Fix dates.
library(stringr)
newdat$Year <- str_extract(newdat$Fecha, "\\b19\\d{2}\\b|\\b20\\d{2}\\b") #When a four-digit starts with either "19" or "20", assign it to Year.

newdat$Month <- as.integer(sub(".*[-_/](\\d{2})[-_/].*", "\\1", newdat$Fecha))

newdat$Day <- ifelse(grepl("^\\d{4}-\\d{2}-\\d{2}$", newdat$Fecha),
                     as.integer(sub(".*-(\\d{2})$", "\\1", newdat$Fecha)), #Note that only days have an underscore.
                     NA)

selection <- select(newdat, Fecha, Year, Month, Day)
#View(selection) #There are some Fechas that have weird formats, eg 13/?/1993, 25/03 ó 04/1975, 1/2 Septiembre.
#These are very few (around 20), hence I don't spend time fixing all these. Years tho are always fixed.

#Drop variables
newdat <- drop_variables(check, newdat) #No valueable info lost.

#Add unique identifier
newdat$uid <- paste("79_Oviedo_museum", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/79_Oviedo_museum.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

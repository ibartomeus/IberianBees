source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 82_Aguado_asensio ---- (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/82_Aguado_asensio.csv', sep = ";")

#Note that this dataset doesn't contain any coordinates.

#Compare vars
compare_variables(check, newdat) #All variables missing.

#Add missing variables
newdat <- add_missing_variables(check, newdat)  #All variables added since the original dataset has everything in Spanish.

#Rearrange species
newdat$Genus <- newdat$GeNERO
newdat$Subgenus <- newdat$SUBGÃ.NERO
newdat$Species <- newdat$ESPECIE
newdat$Subspecies <- newdat$SUBESPECIE

#Fix sexes. 
unique(newdat$SEXO)
newdat$Female <- ifelse(newdat$SEXO == "Hembra", 1, NA)
newdat$Male <- ifelse(newdat$SEXO == "Macho", 1, NA)
newdat$Worker <- ifelse(newdat$SEXO == "Obrera", 1, NA)

#Add "1" in Not.specified where all Female, Male, Worker, Not.specified are NAs.
na_rows <- is.na(newdat$Female) & is.na(newdat$Male) & is.na(newdat$Worker) & is.na(newdat$Not.specified)
newdat$Not.specified[na_rows] <- 1

#Fix dates.
newdat$Year <- newdat$AÃ.O
newdat$Month <- newdat$MES
newdat$Day <- newdat$DÃ.A

#Fix localities.
newdat$Country <- "Spain"
newdat$Locality <- newdat$LOCALIDAD
newdat$Province <- newdat$PROVINCIA
#Assume that provincies "Va" is Valencia, and "Za" Zaragoza.
#No, Va is Valladolid, and Za I bet is also Va. 
newdat <- newdat |>
  mutate(Province = recode(Province, "Va" = "Valladolid", "va" = "Valladolid", "Za" = "Valladolid"))

#Fix other vars.
newdat$Collector <- newdat$COLECTOR
newdat$Determined.by <- newdat$DETERMINADOR
newdat$Flowers.visited <- newdat$en.quÃ..planta

#Drop variables
newdat <- drop_variables(check, newdat)

#Convert Localities to coordinates (taking the coordinates manually from excel file Locations)
coord_func <- function(locality) {
  
  locality <- tolower(locality)
  
  if (is.na(locality)) {
    return(NA)  #Ignore NA values
  } else if (locality == "zamaduenas") {
    return(c(latitude = "41.698036", longitude = "-4.708621", coord = "<100m")) #Site
  } else if (locality == "san bernardo") {
    return(c(latitude = "41.630245", longitude = "-4.26379", coord = "<100m")) #Site
  } else if (locality == "hornillos de eresma") {
    return(c(latitude = "41.36423743093631", longitude = "-4.715411602955436", coord = "<100m")) #Coord from Nacho
  } else if (locality == "olmedo") {
    return(c(latitude = "41.291901", longitude = "-4.710961", coord = ">10km")) #Municipality
  } else if (locality == "vilalba de los alcores") {
    return(c(latitude = "41.863753", longitude = "-4.859276", coord = ">10km")) #Municipality
  } else if (locality == "toro") {
    return(c(latitude = "41.51842374756675", longitude = "-5.399093214043979", coord = "<100m")) #Coord from Nacho
  } else if (locality == "auditorio delibes jardines ") { 
    return(c(latitude = "41.643131", longitude = "-4.748269", coord = "<100m")) #Site
  } else {
    return(NULL)  #Ignore other values
  }
}


#Use sapply to extract to relevant variables.
newdat$Latitude <- unlist(sapply(newdat$Locality, function(x) coord_func(x)["latitude"]))
newdat$Longitude <- unlist(sapply(newdat$Locality, function(x) coord_func(x)["longitude"]))
newdat$Coordinate.precision <- unlist(sapply(newdat$Locality, function(x) coord_func(x)["coord"]))

#Fix some typos. 
newdat$Locality <- gsub("zamaduenas", "Zamadueñas", newdat$Locality)
newdat$Locality <- gsub("zamadueñas", "Zamadueñas", newdat$Locality)
newdat$Locality <- gsub("san bernardo", "San Bernardo", newdat$Locality)
newdat$Locality <- gsub("hornillos de eresma", "Hornillos de Eresma", newdat$Locality)
newdat$Locality <- gsub("olmedo", "Olmedo", newdat$Locality)
newdat$Locality <- gsub("vilalba de los alcores", "Villalba de los Alcores", newdat$Locality)
newdat$Locality <- gsub("villalba de los alcores", "Villalba de los Alcores", newdat$Locality)
newdat$Locality <- gsub("toro", "Toro", newdat$Locality)
newdat$Locality <- gsub("auditorio delibes jardines ", "Auditorio delibes jardines", newdat$Locality) ##DOUBLECHECK

#Add unique identifier
newdat$uid <- paste("82_Aguado_asensio", 1:nrow(newdat), sep = "")

str(newdat)
head(newdat, 50)
#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/82_Aguado_asensio.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

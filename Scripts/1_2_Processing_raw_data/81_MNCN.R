source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 81_MNCN ---- (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/81_MNCN.csv', sep = ";")

#Note that this dataset doesn't contain any coordinates.

#Compare vars
compare_variables(check, newdat) #All variables missing.

#Add missing variables
newdat <- add_missing_variables(check, newdat)  #All variables added since the original dataset has everything in Spanish.

#Rearrange species
newdat$Genus <- newdat$tGenero
newdat$Subgenus <- newdat$tSubgenero
newdat$Species <- newdat$tEspecie

#Rearrange years
newdat$Year <- newdat$nAnio
newdat$Month <- newdat$nMes #Note that ~300 obs have two dates (Mes1,Mes2/Dia1,Dia2)
#that differ from each other that the 2 is about a week later.
#I'm only keeping the date 1, ie Mes1 and Dia1.
newdat$Day <- newdat$nDia

#Fix one row where day is "-31", assume 31.
newdat$Day <- gsub("-31", "31", newdat$Day)

#Rearrange locations
newdat$Locality <- paste(newdat$LocalidadOrig, newdat$tLocalidad, sep = ", ")
newdat$Province <- newdat$Provincia
newdat$Country <- newdat$Pais
newdat <- newdat |>
  mutate(Country = recode(Country, "Suiza" = "Switzerland", "España" = "Spain",
                                    "Francia" = "France", "Sahara Occidental" = "Western Sahara"))

#Rearrange other vars
newdat$Collector <- newdat$tColector
newdat$Determined.by <- newdat$tAutorDeterminacion
newdat$Authors.to.give.credit <- newdat$tAutorDeterminacion
newdat$Any.other.additional.data <- newdat$tProcedencia
newdat$Notes.and.queries <- newdat$tNotasTaxonomicas

#Fix sexes. 
unique(newdat$tSexo)
newdat$Female <- ifelse(tolower(newdat$tSexo) == "hembra", 1, NA)
newdat$Male <- ifelse(tolower(newdat$tSexo) == "macho", 1, NA)

#Add "1" in Not.specified where all Female, Male, Worker, Not.specified are NAs.
na_rows <- is.na(newdat$Female) & is.na(newdat$Male) & is.na(newdat$Worker) & is.na(newdat$Not.specified)
newdat$Not.specified[na_rows] <- 1

#Drop variables
newdat <- drop_variables(check, newdat)

#Add unique identifier
newdat$uid <- paste("81_MNCN", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/81_MNCN.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

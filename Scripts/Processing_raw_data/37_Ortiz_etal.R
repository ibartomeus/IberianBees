source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 37_Ortiz_etal  ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/37_Ortiz_etal.csv', sep = ";")

#Check vars
compare_variables(check, newdat)
help_species()
temp <- strsplit(x = as.character(newdat$UTM), split = ' ') 
lat <- c()
long <- c()
for (i in 1:length(newdat$UTM)){
  lat[i] <- temp[[i]][1] #for first split
  long[i] <- temp[[i]][2] #for second split
} 

#Fix coordinates
help_geo()
newdat$Latitude <- parzer::parse_lat(lat)
newdat$Longitude <- parzer::parse_lon(long)
newdat$Authors.to.give.credit <- "J. Ortiz, C. Ornosa, F. Torres"
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Rename country
newdat$Country <- gsub("España", "Spain", newdat$Country)
#Delete extra spaces
newdat$Locality <- gsub("El Raso.   Agoncillo" , 
                        "El Raso. Agoncillo" , newdat$Locality)
newdat$Locality <- gsub("Hayedo.       Ventosa" , 
                        "Hayedo. Ventosa" , newdat$Locality)
newdat$Locality <- gsub("La Tejera.    San Asensio" , 
                        "La Tejera. San Asensio" , newdat$Locality)
newdat$Locality <- gsub("Las Arenillas.    San Asensio" , 
                        "Las Arenillas. San Asensio" , newdat$Locality)
newdat$Locality <- gsub("Ribarrey.       Cenicero" , 
                        "Ribarrey. Cenicero" , newdat$Locality)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Delete extra spaces
newdat$Collector <- gsub("J.  Bosch"  , 
                         "J. Bosch"  , newdat$Collector)
#Fix this level
newdat$Collector <- gsub("673"  , 
                         NA  , newdat$Collector)
#Rename levels
newdat$Determined.by <- gsub("Bosch/ Ornosa"  , 
                             "J. Bosch, C. Ornosa"  , newdat$Determined.by)
newdat$Determined.by <- gsub("Torres/Ornosa"  , 
                             "Torres, Ornosa"  , newdat$Determined.by)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '37_Ortiz_etal_')

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/37_Ortiz_etal.csv', 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

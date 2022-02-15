source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 49_Ornosa_etal  ----

#Check help of the function CleanR
help_structure()

#read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/49_Ornosa_etal.csv', sep = ";")

#Add vars
compare_variables(check, newdat)

#Fix dates
(temp <- extract_date(newdat$Date, "%d-%m-%Y"))
newdat$Day <- temp$day
newdat$Month <- temp$month
newdat$Year <- temp$year

#fix coordinates
help_geo()
temp <- mgrs::mgrs_to_latlng(as.character(newdat$UTM)[which(!is.na(newdat$UTM))][-c(8,12,13)])
newdat$Latitude[which(!is.na(newdat$UTM))][-c(8,12,13)] <- temp$lat
newdat$Longitude[which(!is.na(newdat$UTM))][-c(8,12,13)] <- temp$lng

#Add vars
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Delete row with NA in genus
newdat <- newdat[!is.na(newdat$Genus),]

#Add country to some missing values
newdat$Country <- "Spain"

#Add missing provinces
newdat$Province[newdat$Locality=="La Pleta  Garraf"] <- "Barcelona"
newdat$Province[newdat$Locality=="Valencia"] <- "Valencia"
newdat$Province[newdat$Locality=="Cuenca"] <- "Cuenca"
newdat$Province[newdat$Locality=="Mallorca"] <- "Baleares"
newdat$Province[newdat$Locality=="Coll d´en Rebassa"] <- "Baleares"
newdat$Province[newdat$Locality=="Puerto Santa María"] <- "Cádiz"
newdat$Province[newdat$Locality=="Jerez"] <- "Cádiz"
newdat$Province[newdat$Locality=="Cartagena"] <- "Cádiz"
newdat$Province[newdat$Locality=="Esporlas"] <- "Baleares"
newdat$Province[newdat$Locality=="Esporlas"] <- "Baleares"

#Fix spacing in some levels
levels(factor(newdat$Collector))
newdat$Collector <- gsub("\\.", ". ", newdat$Collector)
newdat$Collector <- gsub("F. J. Haering", "F.J. Haering", newdat$Collector)
newdat$Collector <- gsub("M. A. Barón", "M.A. Barón", newdat$Collector)
newdat$Collector <- gsub("M. J. Sanz", "M.J. Sanz", newdat$Collector)
newdat$Collector <- gsub("S. V. Peris", "S.V. Peris", newdat$Collector)

#Fixed determined.by levels
levels(factor(newdat$Determined.by))
newdat$Determined.by <- gsub("A.Compte", "A. Compte", newdat$Determined.by)
newdat$Determined.by <- gsub("C Ornosa", "C. Ornosa", newdat$Determined.by)
newdat$Determined.by <- gsub("C.Ornosa", "C. Ornosa", newdat$Determined.by)
newdat$Determined.by <- gsub("C.P-Iñigo", "C.P. Iñigo", newdat$Determined.by)
newdat$Determined.by <- gsub("Domínguez, Serranoy Montagud", "Domínguez, Serrano, Montagud", newdat$Determined.by)
newdat$Determined.by <- gsub("E.Mingo", "E. Mingo", newdat$Determined.by)
newdat$Determined.by <- gsub("J. A. González", "J.A. González", newdat$Determined.by)

#C.Ornosa to credits?
newdat$Authors.to.give.credit <- "C. Ornosa"

#Add uid
newdat <- add_uid(newdat = newdat, '49_Ornosa_etal_')

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/49_Ornosa_etal.csv', 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)


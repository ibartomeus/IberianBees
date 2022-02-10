source("Processing_raw_data/Source_file.R") #Generate template


# 38_Ortiz_etal  ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Rawdata/csvs/38_Ortiz_etal.csv', sep = ";")
compare_variables(check, newdat)

#Fix coordinates
help_geo()
temp <- mgrs::mgrs_to_latlng(as.character(newdat$UTM)[!is.na(newdat$UTM)][-c(40,51,52)]) #40, 51, 52 fail
newdat$Latitude <- NA
newdat$Latitude[!is.na(newdat$UTM)][-c(40,51,52)] <- temp$lat
newdat$Longitude <- NA
newdat$Longitude[!is.na(newdat$UTM)][-c(40,51,52)] <- temp$lng
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat$Female <- as.character(newdat$Female)
newdat$Worker[which(newdat$Female == " obrera")] <- 1
newdat$Female[which(newdat$Female == " obrera")] <- 0
newdat$Authors.to.give.credit <- "J. Ortiz, F. Torres, C. Ornosa"
newdat <- add_uid(newdat = newdat, '38_Ortiz_etal_')

#Rename country
newdat$Country <- gsub("España", "Spain", newdat$Country)
#Fix province
newdat$Province <- gsub("Á06la", "Ávila", newdat$Province)
newdat$Province <- gsub("Sego06a", "Segovia", newdat$Province)
newdat$Province <- gsub("Albacetel", "Albacete", newdat$Province)
newdat$Province <- gsub("Lérida", "Lleida", newdat$Province)
newdat$Province <- gsub("Sierra Gádor", "Almería", newdat$Province)
#Fix localities
levels(factor(newdat$Locality))
newdat$Locality <- gsub("Cortijo de la Cruz. Dalías", 
                        "Sierra Gádor. Cortijo de la Cruz. Dalías", newdat$Locality)
newdat$Locality <- gsub("\\006", 
                        "vi", newdat$Locality)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Standardize collectors
newdat$Collector <- gsub("A  Vázquez", "A. Vázquez", newdat$Collector)
newdat$Collector <- gsub("C. Ornosa/F Torres", "C. Ornosa, F. Torres", newdat$Collector  )
newdat$Collector <- gsub("E  Manzano", "E. Manzano", newdat$Collector)
newdat$Collector <- gsub("P. Vargas/JL Blanco", "P. Vargas, J.L. Blanco", newdat$Collector  )
newdat$Collector <- gsub("Pablo Vargas", "P. Vargas", newdat$Collector  )
newdat$Collector <- gsub("Jesús Gomez", "J. Gomez", newdat$Collector  )
#Standardize determined.by
newdat$Determined.by <- gsub("C Ornosa", "C. Ornosa", newdat$Determined.by)
newdat$Determined.by <- gsub("F. Torres/ C. Ornosa", "F. Torres, C. Ornosa", newdat$Determined.by)
newdat$Determined.by <- gsub("J.  Ortiz", "J. Ortiz", newdat$Determined.by)
newdat$Determined.by <- gsub("J. Ortiz/C. Ornosa", "J. Ortiz, C. Ornosa", newdat$Determined.by)
newdat$Determined.by <- gsub("Félix Torres", "F. Torres", newdat$Determined.by)
levels(factor(newdat$Authors.to.give.credit))

#Save data
write.table(x = newdat, file = 'Data/Processing_raw_data/38_Ortiz_etal.csv', 
            quote = TRUE, sep = ',', col.names = FALSE, 
            row.names = FALSE)

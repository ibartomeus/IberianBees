source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 29_Hormaza_etal  ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/29_Hormaza_etal.csv', sep = ";")

#Check vars
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Few values are missing and seem the same of the rest of the columns
newdat$Country <- "Spain"
newdat$Province <- "Malaga"
newdat$Locality <- "Algarrobo"
newdat$Latitude <- 36.759
newdat$Longitude <- -4.04
newdat$Year <- 2018
newdat$Month <- 04
newdat$Collector <- "O. Aguado"
newdat$Determined.by <- "O. Aguado"
newdat$Authors.to.give.credit <- "O. Aguado, J.I. Hormaza, M.L. Alcaraz, V. Ferrero"

#Delete row with NA in genus
newdat <- newdat[!is.na(newdat$Genus),]

#Add unique identifier
newdat <- add_uid(newdat = newdat, '29_Hormaza_etal_')

#save data
write.table(x = newdat, file = 'Data/Processed_raw_data/29_Hormaza_etal.csv', 
            quote = TRUE, sep = ',', col.names = FALSE, 
            row.names = FALSE)

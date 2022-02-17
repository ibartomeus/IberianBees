source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 22_Nunez ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/22_Nunez.csv', sep = ";")

#Check vars
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
#reorder and drop variables
newdat <- drop_variables(check, newdat) 
summary(newdat)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Gsub, add space between name and surname
levels(factor(newdat$Collector))
newdat$Collector <- gsub("A.Núñez", 
                         "A. Núñez", newdat$Collector)
newdat$Collector <- gsub("D.Luna" , 
                         "D. Luna", newdat$Collector)
newdat$Collector <- gsub("M.Miñarro" , 
                         "M. Miñarro", newdat$Collector)
newdat$Collector <- gsub("R.Martínez" , 
                         "R. Martínez", newdat$Collector)
levels(factor(newdat$Determined.by))
newdat$Determined.by <- gsub("A.Núñez", 
                             "A. Núñez", newdat$Determined.by)
newdat$Determined.by <- gsub("C.Molina", 
                             "C. Molina", newdat$Determined.by)
newdat$Determined.by <- gsub("O.Aguado", 
                             "O. Aguado", newdat$Determined.by)

#Authors to give credit
newdat$Authors.to.give.credit <- "A. Núñez"

#Fix subspecies name
newdat$Subspecies <- gsub("spp.", "", newdat$Subspecies, fixed=T)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '22_Nunez_')

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/22_Nunez.csv', 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

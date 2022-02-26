source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 36_Nunez  ----

#Read data
newdat <- read.csv(file = "Data/Rawdata/csvs/36_Nunez.csv")

#Check cols
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("36_Nunez_", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24,28)]#reorder
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
newdat[131,4] <- NA
newdat$Authors.to.give.credit <- "Martínez-Núñez C., Rey P.J."
#Lat and Long mixed I think
temp <- newdat$Latitude
newdat$Latitude <- newdat$Longitude
newdat$Longitude <- temp

compare_variables(check, newdat)
#Rename variables
colnames(newdat)[which(colnames(newdat) == 'Coordinate.precision..e.g..GPS...10km.')] <- 'Coordinate.precision' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'month')] <- 'Month' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'day')] <- 'Day' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Reference..doi.')] <- 'Reference.doi' #Rename variables if needed

#Rename as others
newdat$Collector <- gsub("Martínez-Núñez C.",
                         "C. Martínez-Núñez", newdat$Collector)
newdat$Determined.by <- gsub("Martínez-Núñez C.",
                             "C. Martínez-Núñez", newdat$Determined.by)
newdat$Authors.to.give.credit <- gsub("Martínez-Núñez C., Rey P.J.",
                                      "C. Martínez-Núñez, P.J. Rey", newdat$Authors.to.give.credit)

#write
write.table(x = newdat, file = "Data/Processed_raw_data/36_Nunez.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

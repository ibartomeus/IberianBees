source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 35_Magrach  ----

#Read data
newdat <- read.csv(file = "Data/Rawdata/csvs/35_Magrach.csv")

#not formated, so let's start here
summary(newdat)
newdat$Subspecies <- NA
newdat <- subset(newdat, pollinator_group %in% c("Bumblebee", "other wild bee"))
#pollinator_species needs cleaning pollinator_species.1
unique(newdat$pollinator_species.1) #?
unique(newdat$pollinator_species)
newdat <- newdat[-which(newdat$pollinator_species == "sp"),]
newdat <- newdat[-grep(pattern = "sp_", 
                       x = newdat$pollinator_species, fixed = TRUE),]
newdat$pollinator_species <- gsub("-type", "", newdat$pollinator_species)
newdat$pollinator_species <- as.character(newdat$pollinator_species)
temp <- unlist(gregexpr(pattern = "_", fixed = TRUE, text = newdat$pollinator_species))
for(i in which(temp > 0)){
  newdat$Subspecies[i] <- substr(newdat$pollinator_species[i], start = temp[i]+1, 
                                 stop = nchar(newdat$pollinator_species[i]))
  newdat$pollinator_species[i] <- substr(newdat$pollinator_species[i], start = 1, 
                                         stop = temp[i]-1)
}                                             
#reshape structure
colnames(newdat)
#reorder
newdat$Subgenus <- NA
newdat$Province <- "Huelva"
newdat$Coordinate.precision <- "<1km"
newdat$Startday <- NA
newdat$Endday <- NA
newdat$Collector <- "Juan. P. Gonzalez-Varo"
newdat$Det <- "J. Ortiz"
newdat$Female <- NA
newdat$Male <- NA
newdat$Worker <- NA
newdat$Not.specified <- 1
newdat$Local_ID <- NA                 
newdat$Authors.to.give.credit <-  "J. Gonzalez-varo, M.Vilà" 
newdat$Any.other.additional.data <- NA
newdat$Notes.and.queries <- NA        
newdat$Reference.doi <- "10.1038/s41559-017-0249-9"
temp <- as.POSIXlt(newdat$date, format = "%m/%d/%Y") #extract month and day
newdat$month <- format(temp,"%m")
newdat$day <- format(temp,"%d")
newdat$uid <- paste("35_Magrach_", 1:nrow(newdat), sep = "")
newdat <- newdat[,c("pollinator_genus",
                    "Subgenus",
                    "pollinator_species",
                    "Subspecies",
                    "country",
                    "Province",
                    "site_id",
                    "latitude",
                    "longitude",
                    "Coordinate.precision",
                    "year",
                    "month",
                    "day",
                    "Startday",
                    "Endday",
                    "Collector",
                    "Det",
                    "Female",
                    "Male",
                    "Worker",
                    "Not.specified",
                    "Reference.doi",
                    "Plant_sp",
                    "Local_ID",                 
                    "Authors.to.give.credit",
                    "Any.other.additional.data",
                    "Notes.and.queries",
                    "uid")]
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged

#Check colnames and rename
compare_variables(check, newdat)
colnames(newdat)[which(colnames(newdat) == 'pollinator_genus')] <- 'Genus' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'pollinator_species')] <- 'Species' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'country')] <- 'Country' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'site_id')] <- 'Locality' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'latitude')] <- 'Latitude' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'longitude')] <- 'Longitude' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'year')] <- 'Year' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'month')] <- 'Month' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'day')] <- 'Day' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Startday')] <- 'Start.date' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Endday')] <- 'End.date' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Endday')] <- 'End.date' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Det')] <- 'Determined.by' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Plant_sp')] <- 'Flowers.visited' #Rename variables if needed
newdat <- drop_variables(check, newdat) #reorder and drop variables

#Fix collector
newdat$Collector <- gsub("Juan. P. Gonzalez-Varo", "Juan P. Gonzalez-Varo",
                         newdat$Collector)

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/35_Magrach.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

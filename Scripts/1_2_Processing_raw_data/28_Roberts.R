source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 28_Roberts.csv ----

#Check help of the function CleanR
help_structure()
newdat <- read.csv(file = 'Data/Rawdata/csvs/28_Roberts.csv', sep = ";")

#Check vars
compare_variables(check, newdat)

#Rename vars
colnames(newdat)[which(colnames(newdat) == 'Determiner')] <- 'Determined.by' 
colnames(newdat)[which(colnames(newdat) == 'Males')] <- 'Male' 
colnames(newdat)[which(colnames(newdat) == 'Females')] <- 'Female' 
colnames(newdat)[which(colnames(newdat) == 'Notes')] <- 'Notes.and.queries' 
temp <- extract_pieces(newdat$Gen.Species, species = TRUE)
newdat$Genus <- temp$piece2
newdat$Species <- temp$piece1

#Fix dates
(temp <- extract_date(newdat$Date, format_ = "%d/%m/%Y"))
newdat$Day <- temp$day
newdat$Month <- temp$month
newdat$Year <- temp$year

#Fix coordinates
help_geo()
(temp <- mgrs::mgrs_to_latlng(as.character(newdat$Grid.Reference)))
newdat$Latitude <- temp$lat
newdat$Longitude <- temp$lng
newdat$Authors.to.give.credit <- "Stuart Roberts"

#Reorder and drop variables
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) 
summary(newdat)

#Rename country
newdat$Country <- gsub("SPAIN", "Spain", newdat$Country)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '28_Roberts_')

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/28_Roberts.csv', 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

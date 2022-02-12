source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 26_Ornosa_etal ----
#(Old file name Vicente Martínez-López, maybe rename to Martinez?) 

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/26_Ornosa_etal.csv')

#Check vars
compare_variables(check, newdat)

#Rename cols
colnames(newdat)[which(colnames(newdat) == "Coordinate.precision..e.g..GPS...10km.")] <- "Coordinate.precision"
colnames(newdat)[which(colnames(newdat) == "month")] <- "Month"
colnames(newdat)[which(colnames(newdat) == "day")] <- "Day"
colnames(newdat)[which(colnames(newdat) == "End.Date")] <- "End.date"
colnames(newdat)[which(colnames(newdat) == "Determiner")] <- "Determined.by"
colnames(newdat)[which(colnames(newdat) == "Reference..doi.")] <- "Reference.doi"
colnames(newdat)[which(colnames(newdat) == "Collection.Location_ID")] <- "Local_ID"
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Fix coordinates
newdat$Latitude <- as.character(newdat$Latitude)
newdat$Longitude <- as.character(newdat$Longitude)
newdat$Latitude <- gsub("°", "", newdat$Latitude)
newdat$Longitude <- gsub("°", "", newdat$Longitude)
newdat$Latitude <- as.numeric(newdat$Latitude)
newdat$Longitude <- as.numeric(newdat$Longitude)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Change separator
newdat$Determined.by <- gsub("\\ y", ",", newdat$Determined.by)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '26_Ornosa_etal_')

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/26_Ornosa_etal.csv', 
            quote = TRUE, sep = ',', col.names = FALSE,
            row.names = FALSE)

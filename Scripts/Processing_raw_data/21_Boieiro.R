source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 21_Boieiro_etal ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/21_Boieiro_etal.csv', sep = ";")

#Check vars
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

#add unique identifier
newdat <- add_uid(newdat = newdat, '21_Boieiro_etal_')

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Replace hyphen by forward slash
newdat$Start.date <- gsub("-", "/", newdat$Start.date)
newdat$End.date <- gsub("-", "/", newdat$End.date)

#Convert to standard format of the database
#Start.date
newdat$Start.date <- as.Date(newdat$Start.date,format = "%Y/%d/%m")
newdat$Start.date <- format(newdat$Start.date, "%d/%m/%Y")
#End.date
newdat$End.date <- as.Date(newdat$End.date,format = "%Y/%d/%m")
newdat$End.date <- format(newdat$End.date, "%d/%m/%Y")

#Change separator to keep consistency
newdat$Collector <- gsub("\\ e", ",", newdat$Collector)
newdat$Determined.by <- gsub("\\ e", ",", newdat$Determined.by)
newdat$Authors.to.give.credit <- gsub("\\ e", ",", newdat$Authors.to.give.credit)

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/21_Boieiro_etal.csv', 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

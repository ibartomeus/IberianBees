source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 32_Valverde  ----

#Read data
newdat <- read.csv(file = "Data/Rawdata/csvs/32_Valverde.csv")

#Col names
colnames(newdat)[9] <- "precision" #just to see them both in two lines
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$uid <- paste("32_Valverde_", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,27,2:26,28)]
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
newdat$Start.date <- NA
newdat$End.Date <- NA
newdat$day #uses multiple days...
#manual, too specific to functionalize for now
newdat$day <- as.character(newdat$day)
for (i in 1:length(newdat$day)){
  temp <- as.numeric(unlist(strsplit(newdat$day[i], split = ";")))
  newdat$Start.date[i] <- paste(min(temp),newdat$Month[i],newdat$Year[i], sep = "-")
  newdat$End.Date[i] <- paste(max(temp),newdat$Month[i],newdat$Year[i], sep = "-")
  newdat$day[i] <- round(mean(temp),0)  
}

#Check variables
compare_variables(check, newdat)
#Rename cols
colnames(newdat)[which(colnames(newdat) == 'precision')] <- 'Coordinate.precision' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'day')] <- 'Day' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'End.Date')] <- 'End.date' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Reference..doi.')] <- 'Reference.doi' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Collection.Location_ID')] <- 'Local_ID' #Rename variables if needed

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Standardize separator
newdat$Determined.by <- gsub("\\ /", ",", newdat$Determined.by)

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/32_Valverde.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

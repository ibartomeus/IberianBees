source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 50_Heleno_etal  ----

#Read data
newdat <- read.csv(file = "Data/Rawdata/csvs/50_Heleno_etal.csv")

#Check cols
colnames(newdat)
colnames(newdat)[9] <- "precision" #just to see them both in two lines

#Subgenus missing.
newdat$Subgenus <- NA
newdat$uid <- paste("50_Heleno_etal_", 1:nrow(newdat), sep = "")
#Reorder
newdat <- newdat[,c(1,27,2:26,28)]

#Quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)

#Longitude and latitude in degrees minutes seconds...40.205835, -8.421204
newdat$Latitude <- 40.205835
newdat$Longitude <- -8.421204
newdat$Start.date <- NA
newdat$End.Date <- NA

#Compare vars
compare_variables(check, newdat)
#Rename columns
colnames(newdat)[which(colnames(newdat)=="precision")] <- "Coordinate.precision"
colnames(newdat)[which(colnames(newdat)=="day")] <- "Day"
colnames(newdat)[which(colnames(newdat)=="Reference..doi.")] <- "Reference.doi"
colnames(newdat)[which(colnames(newdat)=="Collection.Location_ID")] <- "Local_ID"
colnames(newdat)[which(colnames(newdat)=="End.Date")] <- "End.date"

newdat <- drop_variables(check, newdat) #reorder and drop variables

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/50_Heleno_etal.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

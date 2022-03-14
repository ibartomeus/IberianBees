source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template


# 51_Minarro  ----

#Read data
newdat <- read.csv(file = "Data/Rawdata/csvs/51_Minarro.csv")
nrow(newdat)
colnames(newdat)

#Move queri2 to determiner
newdat$Determined.by <- ifelse(is.na(newdat$Determined.by), 
                               newdat$Notes.and.queries..2.,
                               newdat$Determined.by)
unique(newdat$Notes.and.queries)
newdat <- newdat[,-25]
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("51_Minarro_", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24,28)]
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
newdat$Authors.to.give.credit <- "M. Miñarro, A. Núñez"

#Compare vars
compare_variables(check, newdat)
#Rename columns
colnames(newdat)[which(colnames(newdat)=="Coordinate.precision..e.g..GPS...10km.")] <- "Coordinate.precision"
colnames(newdat)[which(colnames(newdat)=="day")] <- "Day"
colnames(newdat)[which(colnames(newdat)=="Reference..doi.")] <- "Reference.doi"
colnames(newdat)[which(colnames(newdat)=="Collection.Location_ID")] <- "Local_ID"
colnames(newdat)[which(colnames(newdat)=="End.Date")] <- "End.date"
colnames(newdat)[which(colnames(newdat)=="month")] <- "Month"

#Drop variables and reorder
newdat <- drop_variables(check, newdat)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Add an extra space on collectors
newdat$Collector <- gsub("\\.", ". ", newdat$Collector)
newdat$Determined.by <- gsub("\\.", ". ", newdat$Determined.by)
newdat$Determined.by <- gsub("Identified by A. Núñez, O.  Aguado and/or J.  Ortiz", "A. Núñez, O.  Aguado, J.  Ortiz", newdat$Determined.by)

#Fix subspecies names
newdat$Subspecies <- gsub("spp.", "", newdat$Subspecies, fixed=T)
newdat$Subspecies <- gsub("ssp. ", "", newdat$Subspecies, fixed=T)

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/51_Minarro.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

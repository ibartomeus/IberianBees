source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 45_Nunez  ----

#Read data
newdat <- read.csv(file = "Data/Rawdata/csvs/45_Nunez.csv")

#old template, subgenus, start and end date missing
colnames(newdat)
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("45_Nunez_", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24,28)]#reorder
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)

#Rename variables
compare_variables(check, newdat)
colnames(newdat)[which(colnames(newdat)=="month")] <- "Month"
colnames(newdat)[which(colnames(newdat)=="day")] <- "Day"
colnames(newdat)[which(colnames(newdat)=="Reference..doi.")] <- "Reference.doi"
colnames(newdat)[which(colnames(newdat)=="Coordinate.precision..e.g..GPS...10km.")] <- "Coordinate.precision"
newdat <- drop_variables(check, newdat) #reorder and drop variables

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Add space after dot in collector and determined.by
levels(factor(newdat$Collector))
newdat$Collector <- gsub("\\.", ". ", newdat$Collector)
newdat$Determined.by <- gsub("\\.", ". ", newdat$Determined.by)

#Add author to give credit
newdat$Authors.to.give.credit <- "A. Núñez"

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/45_Nunez.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE)


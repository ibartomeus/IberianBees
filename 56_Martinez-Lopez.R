source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 55_Martinez-lopez  ----

#Read data
newdat <- read.csv(file = "Data/Rawdata/csvs/56_Martinez-lopez.csv", sep=",")

#Check vars
compare_variables(check, newdat)

#Rename cols
colnames(newdat)[which(colnames(newdat) == 'day')] <- 'Day'
colnames(newdat)[which(colnames(newdat) == 'End.Date')] <- 'End.date'
colnames(newdat)[which(colnames(newdat) == 'Determiner')] <- 'Determined.by'
colnames(newdat)[which(colnames(newdat) == 'Collection.Location_ID')] <- 'Local_ID'
colnames(newdat)[which(colnames(newdat) == 'Reference..doi.')] <- 'Reference.doi'
colnames(newdat)[which(colnames(newdat) == 'Coordinate.precision..e.g..GPS...10km.')] <- 'Coordinate.precision'
colnames(newdat)[which(colnames(newdat) == 'month')] <- 'Month'

#Add missing vars
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables

#Rename province
newdat$Province[newdat$Province=="Región de Murcia"] <- "Murcia"

#Delete degree symbol of coordinates
newdat$Latitude <- gsub("°", "", newdat$Latitude)
newdat$Longitude <- gsub("°", "", newdat$Longitude)

s <- data.frame(levels(factor(newdat$Authors.to.give.credit)))

#Add unique identifier
newdat$uid <- paste("56_Martinez-lopez.csv_", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/56_Martinez-lopez.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)





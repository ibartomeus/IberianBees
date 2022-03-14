source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template


# 52_Picanco  ----

#Read data
newdat <- read.csv(file = "Data/Rawdata/csvs/52_Picanco.csv")

#Check cols
colnames(newdat)
colnames(newdat)[9] <- "precision"
#Subgenus missing
newdat$Subgenus <- NA
newdat$Species <- as.character(newdat$Species)
newdat$Species <- trimws(newdat$Species) 
temp <- unlist(gregexpr(pattern = " ", fixed = TRUE, text = newdat$Species))
length(temp) == length(newdat$Species)
for(i in which(temp > 0)){
  newdat$Species[i] <- substr(newdat$Species[i], start = temp[i]+1, 
                              stop = nchar(newdat$Species[i]))
}
newdat$uid <- paste("52_Picanco_", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,27,2:26,28)]

#Compare cols
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)

#Compare vars
compare_variables(check, newdat)
#Rename cols
colnames(newdat)[which(colnames(newdat)=="precision")] <- "Coordinate.precision"
colnames(newdat)[which(colnames(newdat)=="day")] <- "Day"
colnames(newdat)[which(colnames(newdat)=="End.Date")] <- "End.date"
colnames(newdat)[which(colnames(newdat)=="Reference..doi.")] <- "Reference.doi"
colnames(newdat)[which(colnames(newdat)=="Collection.Location_ID")] <- "Local_ID"
colnames(newdat)[which(colnames(newdat)=="Any.other.additional.data..Habitat.type.")] <- "Any.other.additional.data"

#Drop variables and reorder
newdat <- drop_variables(check, newdat)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Replace hyphen by forward slash
newdat$Start.date <- gsub("-", "/", newdat$Start.date)
newdat$End.date <- gsub("-", "/", newdat$End.date)
#Convert to standard format of the database
library(anytime)  
#This library is awesome and can stand 
#leading zeros and without zeros
#Start.date
newdat$Start.date <- anydate(newdat$Start.date)
newdat$Start.date <- as.Date(newdat$Start.date,format = "%Y/%d/%m")
newdat$Start.date <- format(newdat$Start.date, "%d/%m/%Y")
#End.date
newdat$End.date <- anydate(newdat$End.date)
newdat$End.date <- as.Date(newdat$End.date,format = "%Y/%d/%m")
newdat$End.date <- format(newdat$End.date, "%d/%m/%Y")

#Change separator in determined.by
newdat$Determined.by <- gsub("Ana Picanço/Paulo A. V. Borges", "Ana Picanço, Paulo A.V. Borges", newdat$Determined.by)

#Select a unique doi (Criteria:the oldest one) 
#Also one of them has excel error of scrolling down
levels(factor(newdat$Reference.doi))
#Both are from 2017, just keep one
newdat$Reference.doi <- "https://doi.org/10.1111/icad.12216"

#Authors to give credit, change separator
levels(factor(newdat$Authors.to.give.credit))
newdat$Authors.to.give.credit <- gsub("Ana Picanço; Paulo A. V.Borges", "Ana Picanço, Paulo A. V.Borges", newdat$Authors.to.give.credit)

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/52_Picanco.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

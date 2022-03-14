source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template


# 53_Ferrero  ----

#Read data
newdat <- read.csv(file = "Data/Rawdata/csvs/53_Ferrero.csv")

#Check cols
colnames(newdat)
colnames(newdat)[9] <- "precision"
#subgenus missing.
newdat$Subgenus <- NA
newdat$uid <- paste("53_Ferrero_", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,27,2:26,28)]
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
newdat$Latitude <- as.character(newdat$Latitude)
newdat$Latitude[61] <- 37.39836111111111
newdat$Latitude <- as.numeric(newdat$Latitude)

#Compare vars
compare_variables(check, newdat)
#Rename vars
colnames(newdat)[which(colnames(newdat)=="precision")] <- "Coordinate.precision"
colnames(newdat)[which(colnames(newdat)=="day")] <- "Day"
colnames(newdat)[which(colnames(newdat)=="End.Date")] <- "End.date"
colnames(newdat)[which(colnames(newdat)=="Reference..doi.")] <- "Reference.doi"
colnames(newdat)[which(colnames(newdat)=="Collection.Location_ID")] <- "Local_ID"
#Drop vars and reorder
newdat <- drop_variables(check, newdat)

#Clean genus with NA
newdat <- newdat[!is.na(newdat$Genus),]

#Reoganize month names
newdat$Start.date[newdat$Month=="April/May"] <- "01-04-2007"
newdat$End.date[newdat$Month=="April/May"] <- "31-05-2007"
newdat$Month[newdat$Month=="April/May"] <- NA
newdat$Start.date[newdat$Month=="Feb/March" & newdat$Year=="2006"] <- "01-02-2006"
newdat$End.date[newdat$Month=="Feb/March" & newdat$Year=="2006"] <- "31-03-2006"
newdat$Month[newdat$Month=="Feb/March" & newdat$Year=="2012"] <- NA
newdat$Start.date[newdat$Month=="Feb/March" & newdat$Year=="2012"] <- "01-02-2012"
newdat$End.date[newdat$Month=="Feb/March" & newdat$Year=="2012"] <- "31-03-2012"
newdat$Month[newdat$Month=="Feb/March" & newdat$Year=="2012"] <- NA
newdat$Start.date[newdat$Month=="May/June"] <- "01-05-2008"
newdat$End.date[newdat$Month=="May/June"] <- "30-05-2008"
newdat$Month[newdat$Month=="May/June"] <- NA
#Now convert month names to numbers
newdat$Month <- match(newdat$Month, month.name)
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
#Replace hyphen by forward slash
newdat$Start.date <- gsub("-", "/", newdat$Start.date)
newdat$End.date <- gsub("-", "/", newdat$End.date)

#Fix one level in Flowers.visited
newdat$Flowers.visited <- gsub("Brassica oleracea Brassicaceae III", "Brassica oleracea", newdat$Flowers.visited)

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/53_Ferrero.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

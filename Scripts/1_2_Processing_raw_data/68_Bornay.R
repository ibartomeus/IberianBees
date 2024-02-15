source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 68_Bornay ---- (Unni)

#Read data
#Note that there are two tabs w information in the file, hence two different csv-files.
newdat <- read.csv(file = 'Data/Rawdata/csvs/68_Bornay_1.csv', sep = ";")
newdat_2 <- read.csv(file = 'Data/Rawdata/csvs/68_Bornay_2.csv', sep = ";")
#Adding variables so that I can combine them w rbind.
newdat$medio <- "Dehesa"
newdat_2$medio <- "Olivar"
newdat$HABITAT.FIELD.PLOTc_ODE <- NA
newdat_2$HABITAT.FIELD.PLOT.CODE <- NA
newdat$coord.X <- NA
newdat$coord.Y <- NA
newdat_2$coord.x <- NA
newdat_2$coord.y <- NA
newdat <- subset(newdat, select = c(-X, -X.1, -X.2, -X.3, -X.4, -X.5))
newdat_2 <- subset(newdat_2, select = c(-X, -X.1, -X.2, -X.3, -X.4, -X.5, -X.6, -X.7, -X.8, -X.9, -X.10, -X.11, -X.12))
newdat <- rbind(newdat, newdat_2)
rm(newdat_2)

#Compare vars
compare_variables(check, newdat) #All vars missing. Original dataset has its own vars.

#Add missing variables
newdat <- add_missing_variables(check, newdat) #All vars added.

#Add provincies
# newdat$Province <- paste("XX", newdat$Province, sep = "")

#Fix dates
#install.packages("lubridate")
library(lubridate)
newdat$DATE <- as.Date(newdat$DATE)
newdat$Year <- year(newdat$DATE)
newdat$Month <- month(newdat$DATE)
newdat$Day <- day(newdat$DATE)

#Fix vars
newdat$Not.specified <- newdat$ABUNDANCE
newdat$Determined.by <- newdat$IDENTIFIER.NAME
newdat$Locality <- newdat$medio

#Add "1" in Not.specified where all Female, Male, Worker, Not.specified are NAs.
newdat$Not.specified <- replace(newdat$Not.specified, newdat$Not.specified == 0, NA)
na_rows <- is.na(newdat$Female) & is.na(newdat$Male) & is.na(newdat$Worker) & is.na(newdat$Not.specified)
newdat$Not.specified[na_rows] <- 1

#Put info from 'HABITAT...'-vars under 'Any.other.additional.info'
newdat$Any.other.additional.data <- paste(newdat$HABITAT.FIELD.PLOT.CODE, newdat$HABITAT.FIELD.PLOTc_ODE, sep = "_")
newdat$Any.other.additional.data <- gsub("_NA|NA_", "", newdat$Any.other.additional.data) #| works as the OR operator.

#Remove empty rows
newdat <- newdat[gsub("^\\s*$", "", newdat$Any.other.additional.data) != "", ]

#Variable 'SPECIES.NAME' needs to be extracted into two cells for Genus and Species.
#This code may seem long, but it is necessary since the pollinators are written in various ways.
#Note that there are some species names that have additional blank spaces. Assume that this is erased in final cleaning.
newdat$Genus <- sub("^([A-Z][a-z]+(?:\\s\\([A-Z][a-z]+\\))?).*", "\\1", newdat$SPECIES.NAME)
newdat$Species <- sub("^[A-Z][a-z]+(?:\\s\\([A-Z][a-z]+\\))?\\s(.+)$", "\\1", newdat$SPECIES.NAME)

#Removing everything in 'Species' that are in parenthesis, eg "(Hal.) crenicornis" --> "crenicornis" and "(Lasiog.) leucozonium" --> "leucozonium".
#Around 40 obs are changed due to this.
newdat$Species <- newdat$Species <- gsub("\\(.*?\\)\\s", "", newdat$Species)

#Fix coordinates
newdat$coord.x[newdat$coord.x == ""] <- NA
newdat$coord.y[newdat$coord.y == ""] <- NA
newdat$coord.X[newdat$coord.X == ""] <- NA
newdat$coord.Y[newdat$coord.Y == ""] <- NA

#Latitude
newdat$Latitude <- paste(newdat$coord.x, newdat$coord.X, sep = "")
newdat$Latitude <- newdat$Latitude <- gsub("NA", "", newdat$Latitude)
newdat$Latitude[newdat$Latitude == ""] <- NA

#Longitude
newdat$Longitude <- paste(newdat$coord.y, newdat$coord.Y, sep = "")
newdat$Longitude <- newdat$Longitude <- gsub("NA", "", newdat$Longitude)
newdat$Longitude[newdat$Longitude == ""] <- NA

#Fill in subsequent rows with relevant Latitude or Longitude
for (i in 2:nrow(newdat)) {
  #Check if Latitude or Longitude is NA
  if (is.na(newdat$Latitude[i])) {
    #Fill with the value from the previous row
    newdat$Latitude[i] <- newdat$Latitude[i - 1]
  }
  if (is.na(newdat$Longitude[i])) {
    #Fill with the value from the previous row
    newdat$Longitude[i] <- newdat$Longitude[i - 1]
  }
}

#Change from , to . in coordinates.
newdat$Latitude <- as.numeric(gsub(",", ".", newdat$Latitude))
newdat$Longitude <- as.numeric(gsub(",", ".", newdat$Longitude))

#Change coordinate system from RT90 to WGS 84
##START WORKING HERE. NOT SURE WHAT COORD SYSTEM THEY HAVE.

#Reorder and drop variables
newdat <- drop_variables(check, newdat) #No info is lost. Old vars are stored in new ones.

#Add unique identifier
newdat$uid <- paste("68_Bornay", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/68_Bornay.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

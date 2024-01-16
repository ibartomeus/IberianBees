source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 68_Curro ---- (Unni)

#Read data
#Note that there are two tabs w information in the file, hence two different csv-files.
newdat <- read.csv(file = 'Data/Rawdata/csvs/68_Curro_1.csv', sep = ";")
newdat_2 <- read.csv(file = 'Data/Rawdata/csvs/68_Curro_2.csv', sep = ";")
#Adding variables so that I can combine them w rbind.
newdat$medio <- "Dehesa"
newdat$HABITAT.FIELD.PLOTc_ODE <- NA
newdat_2$HABITAT.FIELD.PLOT.CODE <- NA
newdat_2 <- subset(newdat_2, select = -X)
newdat <- rbind(newdat, newdat_2)

#Compare vars
compare_variables(check, newdat) #All vars missing. Original dataset has its own vars.

#Add missing variables
newdat <- add_missing_variables(check, newdat) #All vars added.

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

#Reorder and drop variables
newdat <- drop_variables(check, newdat) #No info is lost. Old vars are stored in new ones.

#Add unique identifier
newdat$uid <- paste("68_Curro", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/68_Curro.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 67_life_polinizadores ---- (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/67_life_polinizadores.csv', sep = ";")

#Compare vars
compare_variables(check, newdat) #All vars missing. Original dataset only has one with all info.

#Split the existing column based on commas and create new columns
newdat <- as.data.frame(do.call(rbind, strsplit(as.character(newdat$site_id.transect.day.month.year.time.weather.temperature.wind.plants.pollinators), ',')))
colnames(newdat) <- c('site_id', 'transect', 'day', 'month', 'year', 'time', 'weather', 'temperature', 'wind', 'plants', 'pollinators')

#Add missing variables
newdat <- add_missing_variables(check, newdat) #All vars added.

#Creating new variables based on already existing ones.
newdat$Year <- newdat$year
newdat$Month <- newdat$month
newdat$Day <- newdat$day
newdat$Flowers.visited <- newdat$plants

#Variable 'pollinator' (eg Certallum ebullinum) needs to be extracted into two cells for Genus and Species.
#This code may seem long, but it is necessary since the pollinators are written in various ways.
newdat$Genus <- sub("^([A-Z][a-z]+(?:\\s\\([A-Z][a-z]+\\))?).*", "\\1", newdat$pollinators)
newdat$Species <- sub("^[A-Z][a-z]+(?:\\s\\([A-Z][a-z]+\\))?\\s(.+)$", "\\1", newdat$pollinators)

#Variable 'site_ID' has information 'ejea caballeros' and 'cantavieja'. I assume province Zaragoza and Teruel.
newdat$Country <- "Spain"
newdat$Province <- ifelse(newdat$site_id == "ejea caballeros", "Zaragoza", ifelse(newdat$site_id == "cantavieja", "Teruel", NA))

#Put info on temperature under 'Any.other.additional.info.'
newdat$Any.other.additional.data <- newdat$temperature
newdat$Notes.and.queries <- "additional data is temp"

#Assume one species observed per observation event.
newdat$Not.specified <- "1"

#Reorder and drop variables
newdat <- drop_variables(check, newdat) #Vars 'transect', 'time', 'weather', 'wind' is erased.

#Add unique identifier
newdat$uid <- paste("67_life_polinizadores", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/67_life_polinizadores.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 55_Martinez-lopez  ----

#Read data
newdat <- read.csv(file = "Data/Rawdata/csvs/55_Martinez-lopez.csv", sep=",")

#Check vars
compare_variables(check, newdat)

#Rename cols
colnames(newdat)[which(colnames(newdat) == 'Coordinate.precision..e.g..GPS...10km.')] <- 'Coordinate.precision'
colnames(newdat)[which(colnames(newdat) == 'month')] <- 'Month'
colnames(newdat)[which(colnames(newdat) == 'day')] <- 'Day'
colnames(newdat)[which(colnames(newdat) == 'End.Date')] <- 'End.date'
colnames(newdat)[which(colnames(newdat) == 'Determiner')] <- 'Determined.by'
colnames(newdat)[which(colnames(newdat) == 'Reference..doi.')] <- 'Reference.doi'
colnames(newdat)[which(colnames(newdat) == 'Collection.Location_ID')] <- 'Local_ID'

#Add missing vars
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables

#Fix wrong province "Castilla-La Mancha", rename if possible
newdat$Province[newdat$Locality=="Fuente de la Carrasca (Albacete)"] <- "Albacete"
# Rename Murcia to Murcia following standar names 
#https://www.ine.es/daco/daco42/codmun/cod_provincia.htm
newdat$Province[newdat$Province=="Región de Murcia"] <- "Murcia"

#Delete degree symbol of coordinates
newdat$Latitude <- gsub("°", "", newdat$Latitude)
newdat$Longitude <- gsub("°", "", newdat$Longitude)

#Standardize unindetified plant species
newdat$Flowers.visited <- gsub("sp.", "sp", newdat$Flowers.visited, fixed = T)
newdat$Flowers.visited <- gsub("sp2", "sp", newdat$Flowers.visited, fixed = T)

#Add unique identifier
newdat$uid <- paste("55_Martinez-lopez.csv_", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/55_Martinez-lopez.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)


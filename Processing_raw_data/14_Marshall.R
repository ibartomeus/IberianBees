source("Processing_raw_data/Source_file.R") #Generate template

#14_Marshall ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Rawdata/csvs/14_Marshall.csv', sep = ";")

#Check variables
compare_variables(check, newdat)

#Fix cols
head(newdat)
newdat$Visitor <- as.factor(newdat$Visitor)
levels(newdat$Visitor)[11] <- "Bombus terrestris"
temp <- extract_pieces(newdat$Visitor, species = TRUE) 
newdat$Genus <- temp$piece2
newdat$Species <- temp$piece1
#Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Plant')] <- 'Flowers.visited' 

#reorder and drop variables
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) 
summary(newdat)

#Add country name by coordinates 
#I have checked by coordinates that all points belong to France
#Here is the code, not added for simplicity
#https://stackoverflow.com/questions/14334970/convert-latitude-and-longitude-coordinates-to-country-name-in-r
newdat$Country <- "France"

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '14_Marshall_')

#Save data
write.table(x = newdat, file = 'Data/Processing_raw_data/14_Marshall.csv', 
            quote = TRUE, sep = ',', col.names = FALSE, 
            row.names = FALSE)

source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template


# 20_Gayubo ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/20_Gayubo.csv', sep = ";")

#Check vars
compare_variables(check, newdat)
head(newdat)

#Fix coordinates
help_geo()
temp <- mgrs::mgrs_to_latlng(as.character(newdat$UTM))
newdat$Latitude <- temp$lat
newdat$Longitude <- temp$lng
(temp <- extract_pieces(newdat$Species, species = TRUE))
newdat$Species <- temp$piece1

#Rename variables if needed
unique(newdat$Sex)
newdat$Male <- ifelse(newdat$Sex %in% c("male", "m"), newdat$Individuals, 0)
newdat$Female <- ifelse(newdat$Sex == "female", newdat$Individuals, 0)
colnames(newdat)[which(colnames(newdat) == 'dataFrom')] <- 'Reference.doi' 
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Add country
newdat$Country <- "Spain"

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Add ui
newdat <- add_uid(newdat = newdat, '20_Gayubo_')

#Write data
write.table(x = newdat, file = 'Data/Processed_raw_data/20_Gayubo.csv', 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

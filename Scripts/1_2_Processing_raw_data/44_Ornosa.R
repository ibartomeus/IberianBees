source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 44_Ornosa  ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/44_Ornosa.csv', sep = ";")

#Add vars
compare_variables(check, newdat)

#fix dates
(temp <- extract_date(newdat$Date, "%d-%m-%Y"))
newdat$Day <- temp$day
newdat$Month <- temp$month
newdat$Year <- temp$year

#Fix coordinates
help_geo()
newdat$Latitude <- parzer::parse_lat(as.character(newdat$GPS..N.))
newdat$Longitude <- parzer::parse_lon(as.character(newdat$GPS..E.))
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Rename country
newdat$Country <- gsub("España", "Spain", newdat$Country)

#Change separator in collector column
newdat$Collector <- gsub("\\/", ", ", newdat$Collector)

#Add author to give credit
newdat$Authors.to.give.credit <- "C. Ornosa"

#Add unique identifier
newdat <- add_uid(newdat = newdat, '44_Ornosa_')


#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/44_Ornosa.csv', quote = TRUE, 
sep = ',', col.names = TRUE, row.names = FALSE)

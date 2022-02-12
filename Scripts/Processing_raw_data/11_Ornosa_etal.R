source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 11_Ornosa_etal ----

#Check help of the function CleanR
help_structure()
#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/11_Ornosa_etal.csv', sep = ";")

#Check vars
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)

#Fix one coordinates
help_geo()
newdat$GPS..E. <- gsub("4º3'58\" N", "4º3'58\" W", newdat$GPS..E.)
#Another one, seems that is an extra 3 here
newdat$GPS..E. <- gsub("83º 30' 00\" W", "8º 30' 00\" W", newdat$GPS..E.)
#Convert to lat/lon
newdat$Latitude <- parzer::parse_lat(as.character(newdat$GPS..N.)) 
newdat$Longitude <- parzer::parse_lon(as.character(newdat$GPS..E.))
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Rename country
newdat$Country <- gsub("España", "Spain", newdat$Country)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Just 3 days that can be added, so I do it one by one
newdat$Year[newdat$Start.date=="02-08-2013"] <- "2013"
newdat$Month[newdat$Start.date=="02-08-2013"] <- "08"

#Change separator of forward slash to comma
levels(factor(newdat$Collector))
newdat$Collector <- gsub("\\/", ", ", newdat$Collector)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '11_Ornosa_etal_')

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/11_Ornosa_etal.csv', 
            quote = TRUE, sep = ',', col.names = FALSE, 
            row.names = FALSE)

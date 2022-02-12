source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 7_Ornosa ----

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/7_Ornosa.csv', sep = ";")

#Check variables
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)

#Fix coordinates
help_geo()
newdat$Latitude <- parzer::parse_lat(as.character(newdat$GPS..N.))
newdat$Longitude <- parzer::parse_lon(as.character(newdat$GPS..E.))

#Fix dates
(temp <- extract_date(newdat$Date, "%Y-%m-%d"))
newdat$Day <- temp$day
newdat$Year <- temp$year
newdat$Month <- temp$month

#reorder and drop variables
newdat <- drop_variables(check, newdat) 
summary(newdat)

#Rename country
newdat$Country <- gsub("España", "Spain",newdat$Country, fixed=T)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '7_Ornosa_')

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/7_Ornosa.csv', 
            quote = TRUE, sep = ',', col.names = FALSE, 
            row.names = FALSE)

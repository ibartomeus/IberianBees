source("Processing_raw_data/Source_file.R") #Generate template


# 41_Torres  ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Rawdata/csvs/41_Torres.csv', sep =";")

#check vars
compare_variables(check, newdat)

#Fix date
(temp <- extract_date(newdat$Date, "%d-%m-%Y"))
newdat$Day <- temp$day
newdat$Month <- temp$month
newdat$Year <- temp$year
#newdat$UTM #empty

#Add vars
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat$Authors.to.give.credit <- "Felix Torres"
newdat$Year <- ifelse(newdat$Year < 1000, newdat$Year +1900, newdat$Year)

#Drop cells with NA in genus
newdat <- newdat[!is.na(newdat$Genus),]
#Rename country
newdat$Country <- "Spain"
newdat$Country[newdat$Province=="Portugal"] <- "Portugal"
#Fill missing province
newdat$Province[newdat$Locality=="Piquera de San Esteban"] <- "Soria"

#Fix space in collector
newdat$Collector <- gsub("F.Torres", "F. Torres", newdat$Collector)
#Fix space in determined by
newdat$Determined.by <- gsub("F.Torres", "F. Torres", newdat$Determined.by)
newdat$Determined.by <- gsub("Torres/Ornosa", "F. Torres, C. Ornosa", newdat$Determined.by)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '41_Torres_')

#Save data
write.table(x = newdat, file = 'Data/Processing_raw_data/41_Torres.csv', 
            quote = TRUE, sep = ',', col.names = FALSE, 
            row.names = FALSE,)

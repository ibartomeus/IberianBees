source("Processing_raw_data/Source_file.R") #Generate template


# 39_Ortiz_etal  ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Rawdata/csvs/39_Ortiz_etal.csv', sep = ";")

#Check vars
compare_variables(check, newdat)

#Fix dates
(temp <- extract_date(newdat$Date, "%d-%m-%Y"))
newdat$Day <- temp$day
newdat$Month <- temp$month
newdat$Year <- temp$year

#Add vars
newdat <- add_missing_variables(check, newdat)

#Fix coordinates
help_geo()
temp <- mgrs::mgrs_to_latlng(as.character(newdat$UTM)[!is.na(newdat$UTM)])
newdat$Latitude[!is.na(newdat$UTM)] <- temp$lat
newdat$Longitude[!is.na(newdat$UTM)] <- temp$lng
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat$Authors.to.give.credit <- "J. Ortiz, F. Torres, C. Ornosa"

#Rename countries
newdat$Country <- gsub("España", "Spain", newdat$Country)
newdat$Country <- gsub("Francia", "France", newdat$Country)
#Trailing space province
newdat$Province <- trimws(newdat$Province, "r")
newdat$Locality <- trimws(newdat$Locality, "r")

#Standardize collectors
newdat$Collector <- gsub("A. Glez.-Posada", "A. Glez-Posada", newdat$Collector)
newdat$Collector <- gsub("A. López /C. Ornosa", "A. López, C. Ornosa", newdat$Collector)
#Standardize determined.by
newdat$Determined.by <- gsub("J  Ortiz", "J. Ortiz", newdat$Determined.by)
newdat$Determined.by <- gsub("J. Ortiz/C. Ornosa", "J. Ortiz, C. Ornosa", newdat$Determined.by)
newdat$Determined.by <- gsub("F Torres", "F. Torres", newdat$Determined.by)
newdat$Determined.by[newdat$Determined.by==" "] <- NA
levels(factor(newdat$Determined.by))

#Add uid
newdat <- add_uid(newdat = newdat, '39_Ortiz_etal_')

#Save data
write.table(x = newdat, file = 'Data/Processing_raw_data/39_Ortiz_etal.csv',
            quote = TRUE, sep = ',', col.names = FALSE, 
            row.names = FALSE)

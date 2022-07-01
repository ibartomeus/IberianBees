source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template


# 12_Ornosa_etal ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/12_Ornosa_etal.csv', sep = ";")

#Check vars
compare_variables(check, newdat)

#Fix dates
(temp <- extract_date(newdat$Date, "%Y-%m-%d"))
newdat$Day <- temp$day
newdat$Month <- temp$month
newdat$Year <- temp$year

#Fix dates
help_geo()
newdat$Latitude <- parzer::parse_lat(as.character(newdat$GPS..N.))
newdat$GPS..O. <- as.character(newdat$GPS..O.)
newdat$GPS..O. <- gsub("O", "", newdat$GPS..O.)
newdat$Longitude <- parzer::parse_lon(as.character(newdat$GPS..O.)) #decimales...
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat$Authors.to.give.credit <- "C. Ornosa"

#Rename country
newdat$Country <- gsub("España", "Spain", newdat$Country)

#Change separator of forward slash to comma
levels(factor(newdat$Determined.by))
newdat$Determined.by <- gsub("\\/", ", ", newdat$Determined.by)
#Upper case all intial letters
newdat$Determined.by <- stringr::str_to_title(newdat$Determined.by)
newdat$Locality <- stringr::str_to_title(newdat$Locality)

#Delete leading space
newdat$Determined.by <- trimws(newdat$Determined.by, "l")

#Fix subspecies name
newdat$Subspecies[newdat$Subspecies=="dusmeti con algo de maculatus"] <- NA
newdat$Subspecies[newdat$Subspecies=="lusitanicus mezcla"] <- NA
newdat$Subspecies[newdat$Subspecies=="lusitanicus?"] <- NA
newdat$Subspecies[newdat$Subspecies=="maculatus con mezcla"] <- NA
newdat$Subspecies[newdat$Subspecies=="maculatus x dusmeti"] <- NA
newdat$Subspecies[newdat$Subspecies=="no se distingue"] <- NA
newdat$Subspecies[newdat$Subspecies=="soroeensis mezcla"] <- NA
newdat$Subspecies[newdat$Subspecies=="terrestisxlusitanicus"] <- NA
newdat$Subspecies[newdat$Subspecies=="terrestris mezcla"] <- NA

#Fix male col
newdat$Male[newdat$Male=="m"] <- 1

#Fix one coordinate
newdat$Latitude[newdat$Species == "violacea"] <- 37.150267
newdat$Longitude[newdat$Species == "violacea"] <- -3.633878

#Add unique identifier
newdat <- add_uid(newdat = newdat, '12_Ornosa_etal_')

#Save date
write.table(x = newdat, file = 'Data/Processed_raw_data/12_Ornosa_etal.csv', 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

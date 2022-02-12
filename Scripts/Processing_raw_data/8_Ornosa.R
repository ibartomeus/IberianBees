source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 8_Ornosa ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/8_Ornosa.csv', sep = ";")
compare_variables(check, newdat)

#Fix coordinate before converting, it's giving an error
help_geo()
newdat$GPS..E. <- gsub('4º27310"', '4º27´310"', newdat$GPS..E.)
newdat$Latitude <- parzer::parse_lat(as.character(newdat$GPS..N.))
newdat$Longitude <- parzer::parse_lon(as.character(newdat$GPS..E.))

#reorder and drop variables
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) 
summary(newdat)
newdat$Authors.to.give.credit <- "C. Ornosa"

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)

# Rename country
newdat$Country <- gsub("España", "Spain", newdat$Country)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '8_Ornosa_')

#Erase empty genus and cell with Ácaros del 17_103 on genus
newdat <- newdat[!is.na(newdat$Genus),]
newdat <- newdat[newdat$Genus!="Ácaros del 17_103",]

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/8_Ornosa.csv', 
            quote = TRUE, sep = ',', col.names = FALSE, 
            row.names = FALSE)

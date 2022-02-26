source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 9_Ornosa ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/9_Ornosa.csv', sep = ";")

#Check vars
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
#extract_pieces()
#help_geo()
#help_species()

#Fix dates
(temp <- extract_date(newdat$Date, "%Y-%m-%d"))
newdat$Day <- temp$day
newdat$Month <- temp$month
newdat$Year <- temp$year

#reorder and drop variables
newdat <- drop_variables(check, newdat) 
summary(newdat)

newdat$Province[newdat$Locality=="Picos de Europa"] <- "Asturias"

#Add unique identifier
newdat <- add_uid(newdat = newdat, '9_Ornosa_')
newdat$Authors.to.give.credit <- "C. Ornosa"

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/9_Ornosa.csv', 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

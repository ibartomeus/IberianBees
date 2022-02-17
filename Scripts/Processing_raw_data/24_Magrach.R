source("Scripts/Processing_raw_data/Source_file.R") #Generate template


#24_Magrach ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/24_Magrach.csv', sep = ";")

#Check vars
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '24_Magrach_')

#Fix species name
newdat$Species[newdat$Species=="pascurorum"] <- "pascuorum"

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/24_Magrach.csv', 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

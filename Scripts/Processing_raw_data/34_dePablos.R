source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 34_dePablos  ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv('Data/Rawdata/csvs/34_dePablos.csv', sep = ";")

#Check vars
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
#extract_pieces()
#help_geo()
#help_species()
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Convert months to numbers
newdat$Month <- match(newdat$Month, month.name)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Add unique identificator
newdat <- add_uid(newdat = newdat, '34_dePablos_')

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/34_dePablos.csv', 
            quote = TRUE, sep = ',', col.names = FALSE, 
            row.names = FALSE)

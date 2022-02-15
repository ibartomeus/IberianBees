source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 31_Diaz-Calafat  ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/31_Diaz-Calafat.csv', sep = ";")

#check vars
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)


#Fix wrong species name
newdat$Genus <- gsub("Andrea", "Andrena", newdat$Genus, fixed=T)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '31_Diaz-Calafat_')

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/31_Diaz-Calafat.csv', 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

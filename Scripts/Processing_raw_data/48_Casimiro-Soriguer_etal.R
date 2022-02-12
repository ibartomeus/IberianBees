source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 48_Casimiro-Soriguer_etal  ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/48_Casimiro-Soriguer_etal.csv', sep = ";")

#Check vars
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Add flower visited is on additional info
newdat$Flowers.visited <- "Erophaca baetica"
#Set notes now to NA
newdat$Any.other.additional.data <- NA

#Add unique identifier
newdat <- add_uid(newdat = newdat, '48_Casimiro-Soriguer_etal_')

write.table(x = newdat, file = 'Data/Processed_raw_data/48_Casimiro-Soriguer_etal.csv', 
            quote = TRUE, sep = ',', col.names = FALSE, 
            row.names = FALSE)

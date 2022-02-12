source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 27_Azpiazu_etal ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/27_Azpiazu_etal.csv', sep = ";")

#Check vars
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Standardize separation in names
newdat$Determined.by <- gsub("J.Ortiz", 
                             "J. Ortiz", newdat$Determined.by)

#Convert to link format
newdat$Reference.doi <- paste0("https://doi.org/",
                               newdat$Reference.doi)
#Ugly but works, convert now "https://doi.org/NA" back to NA
newdat$Reference.doi <- gsub("https://doi.org/NA" , NA, newdat$Reference.doi)
#DOI works fine

#Add unique identifier
newdat <- add_uid(newdat = newdat, '27_Azpiazu_etal_')

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/27_Azpiazu_etal.csv', 
            quote = TRUE, sep = ',', col.names = FALSE, 
            row.names = FALSE)

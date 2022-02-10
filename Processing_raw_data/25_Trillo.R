source("Processing_raw_data/Source_file.R") #Generate template


# 25_Trillo ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Rawdata/csvs/25_Trillo.csv', sep = ";")

#Check vars
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)
#Standardize separator
levels(factor(newdat$Determined.by))
newdat$Determined.by <- gsub("FJ Ortiz-Sánchez", 
                             "F.J. Ortiz-Sánchez",newdat$Determined.by)
newdat$Authors.to.give.credit <- gsub("A. Trillo, FJ Ortiz-Sánchez", 
                                      "A. Trillo, F.J. Ortiz-Sánchez",newdat$Authors.to.give.credit)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '25_Trillo_')

#Save data
write.table(x = newdat, file = 'Data/Processing_raw_data/25_Trillo.csv', 
            quote = TRUE, sep = ',', col.names = FALSE, 
            row.names = FALSE)

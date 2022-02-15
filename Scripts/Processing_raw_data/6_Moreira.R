source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 6_Moreira ----

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/6_Moreira.csv', sep = ";")

#Reorder and drop variables
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) 
summary(newdat)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)

#Small edit on determined.by col
levels(factor(newdat$Determined.by))
newdat$Reference.doi <- gsub("T.J.Wood", "T.J. Wood", newdat$Reference.doi)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '6_Moreira_')

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/6_Moreira.csv',
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template


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

#Convert to standard format of the database
library(anytime)  
#This library is awesome and can stand 
#leading zeros and without zeros
#Start.date
newdat$Start.date <- anydate(newdat$Start.date)
newdat$Start.date <- as.Date(newdat$Start.date,format = "%Y/%d/%m")
newdat$Start.date <- format(newdat$Start.date, "%d/%m/%Y")
#End.date
newdat$End.date <- anydate(newdat$End.date)
newdat$End.date <- as.Date(newdat$End.date,format = "%Y/%d/%m")
newdat$End.date <- format(newdat$End.date, "%d/%m/%Y")

#Fix Start.date
newdat$Start.date[newdat$Start.date=="2015-08-06"] <- "06/08/2015"
newdat$End.date[newdat$End.date=="2015-08-20"] <- "20/08/2015"

#Small edit on determined.by col
levels(factor(newdat$Determined.by))
newdat$Reference.doi <- gsub("T.J.Wood", "T.J. Wood", newdat$Reference.doi)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '6_Moreira_')

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/6_Moreira.csv',
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

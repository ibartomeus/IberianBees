source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 62_Pareja-Bonilla ---- (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/62_Pareja-Bonilla.csv', sep = ";")

#Compare vars
compare_variables(check, newdat) #No obvious errors found here. Some classes wrong.

#Add missing variables
newdat <- add_missing_variables(check, newdat)  #uid added.

#Change months from alphabetic to numeric
month_names <- c("january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december")
newdat$Month <- match(trimws(newdat$Month), month_names) #Using trimws if the months are followed by a blank space.

#Reorder and drop variables
newdat <- drop_variables(check, newdat) #No valuable info is lost

#Add unique identifier
newdat$uid <- paste("62_Pareja-Bonilla", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/62_Pareja-Bonilla.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

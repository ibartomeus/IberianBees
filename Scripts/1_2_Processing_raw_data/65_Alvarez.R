source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 65_Alvarez ---- From Data_Saray (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/65_Alvarez.csv', sep = ";")

#Compare vars
compare_variables(check, newdat) #No vars missing, no extra vars. Some classes wrong.

#Note that some dates are NAs, but not removing them since we have coordinates.

#Reorder and drop variables
newdat <- drop_variables(check, newdat) #No valuable info is lost

#Add unique identifier
newdat$uid <- paste("65_Alvarez", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/65_Alvarez.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

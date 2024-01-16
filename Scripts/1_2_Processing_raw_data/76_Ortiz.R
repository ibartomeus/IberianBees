source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 76_Ortiz ---- From Data_Saray (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/76_Ortiz.csv', sep = ";")

#Compare vars
compare_variables(check, newdat) #No vars missing, no extra vars.

#Dataset lacks coordinates, but have coordinate precision.

#Reorder and drop variables
newdat <- drop_variables(check, newdat) #No valuable info is lost

#Add unique identifier
newdat$uid <- paste("76_Ortiz", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/76_Ortiz.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)
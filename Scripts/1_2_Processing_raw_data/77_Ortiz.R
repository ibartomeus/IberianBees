source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 77_Ortiz ---- From Data_Saray (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/77_Ortiz.csv', sep = ";")
#Dataset only contains two observations.

#Compare vars
compare_variables(check, newdat) #No vars missing, no extra vars.

#Coordinates are faulty. Should be Sierra Nevada but show just north of Alger. Convert? ASK.

#Reorder and drop variables
newdat <- drop_variables(check, newdat) #No valuable info is lost

#Add unique identifier
newdat$uid <- paste("77_Ortiz", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/77_Ortiz.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)
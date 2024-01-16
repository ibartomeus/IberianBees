source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 74_Ornosa ---- From Data_Saray (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/74_Ornosa.csv', sep = ";")

#Compare vars
compare_variables(check, newdat) #No vars missing, no extra vars. Two coordinates out of range, seems to be in the UK.

#Removing the observations where coordinates are out of range. Or can I convert?? Put new coord. Coord.prec. can be my note, move data here to notes.
newdat <- newdat <- subset(newdat, Latitude != 57.42289)
newdat <- newdat <- subset(newdat, Latitude != 56.49357)
#Dont remove, put NA if not fixing coord.

#Compare vars again
compare_variables(check, newdat) #Coordinates now look good.

#Reorder and drop variables
newdat <- drop_variables(check, newdat) #No valuable info is lost

#Add unique identifier
newdat$uid <- paste("74_Ornosa", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/74_Ornosa.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

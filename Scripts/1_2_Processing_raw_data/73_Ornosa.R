source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 73_Ornosa ---- From Data_Saray (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/73_Ornosa.csv', sep = ";")

#Compare vars
compare_variables(check, newdat) #No vars missing, no extra vars. Year out of range, min year is 197.

#Remove the row w year 197 because I cant tell if it's 1977 och 1978 based on adjacent rows.
newdat <- subset(newdat, Year != 197)

#Compare vars again
compare_variables(check, newdat) #Years now look good.

#Fixing Collecter data that is in a parenthesis.
newdat$Collector <- gsub("\\s*\\(A\\. Rueda\\)\\s*", "A. Rueda", newdat$Collector)

#Replacing zeros to NAs in sexes.
newdat$Female <- replace(newdat$Female, newdat$Female == 0, NA)
newdat$Male <- replace(newdat$Male, newdat$Male == 0, NA)
newdat$Worker <- replace(newdat$Worker, newdat$Worker == 0, NA)
newdat$Not.specified <- replace(newdat$Not.specified, newdat$Not.specified == 0, NA)

#Add "1" in Not.specified where all Female, Male, Worker, Not.specified are NAs.
na_rows <- is.na(newdat$Female) & is.na(newdat$Male) & is.na(newdat$Worker) & is.na(newdat$Not.specified)
newdat$Not.specified[na_rows] <- 1

#Copy Coordinate.precision to Notes.and.queries so that the info doesn't get lost.
newdat$Notes.and.queries <- paste(newdat$Coordinate.precision, "coordinate precision")

#Reorder and drop variables
newdat <- drop_variables(check, newdat) #No valuable info is lost

#Add unique identifier
newdat$uid <- paste("73_Ornosa", 1:nrow(newdat), sep = "")

newdat$Coordinate.precision <- NA

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/73_Ornosa.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

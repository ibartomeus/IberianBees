source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 78_Ortiz ---- From Data_Saray (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/78_Ortiz.csv', sep = ";")

#Compare vars
compare_variables(check, newdat) #No vars missing, no extra vars.

#Renaming province names
newdat$Province <- gsub("Lérida", "Lleida", newdat$Province)
newdat$Province <- gsub("Gerona", "Girona", newdat$Province)

#Add "1" in Not.specified where all Female, Male, Worker, Not.specified are NAs.
na_rows <- is.na(newdat$Female) & is.na(newdat$Male) & is.na(newdat$Worker) & is.na(newdat$Not.specified)
newdat$Not.specified[na_rows] <- 1

#Copy Coordinate.precision to Notes.and.queries so that the info doesn't get lost.
newdat$Notes.and.queries <- paste(newdat$Coordinate.precision, "coordinate precision") #A couple of rows in Notes get overwritten. Assume not smth important.
newdat$Notes.and.queries <- gsub("NA coordinate precision", NA, newdat$Notes.and.queries) #Not all rows had coord.precision.

#Reorder and drop variables
newdat <- drop_variables(check, newdat) #No valuable info is lost

#Add unique identifier
newdat$uid <- paste("78_Ortiz", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/78_Ortiz.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)
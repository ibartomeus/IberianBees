source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 76_Ortiz ---- From Data_Saray (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/76_Ortiz.csv', sep = ";")

#Compare vars
compare_variables(check, newdat) #No vars missing, no extra vars.

#Dataset lacks coordinates, but have coordinate precision.

#Replacing zeros to NAs in sexes.
newdat$Female <- replace(newdat$Female, newdat$Female == 0, NA)
newdat$Male <- replace(newdat$Male, newdat$Male == 0, NA)
newdat$Worker <- replace(newdat$Worker, newdat$Worker == 0, NA)

#Add "1" in Not.specified where all Female, Male, Worker, Not.specified are NAs.
na_rows <- is.na(newdat$Female) & is.na(newdat$Male) & is.na(newdat$Worker) & is.na(newdat$Not.specified)
newdat$Not.specified[na_rows] <- 1

#Putting coordinate.precision in another variable so that it doesn't get lost.
newdat$Notes.and.queries <- paste(newdat$Coordinate.precision, "coordinate precision")

#Reorder and drop variables
newdat <- drop_variables(check, newdat) #No valuable info is lost

#Add unique identifier
newdat$uid <- paste("76_Ortiz", 1:nrow(newdat), sep = "")

newdat$Coordinate.precision <- NA

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/76_Ortiz.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

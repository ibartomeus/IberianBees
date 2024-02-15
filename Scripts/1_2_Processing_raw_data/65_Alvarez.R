source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 65_Alvarez ---- From Data_Saray (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/65_Alvarez.csv', sep = ";")

#Compare vars
compare_variables(check, newdat) #No vars missing, no extra vars. Some classes wrong.

#Note that some dates are NAs, but not removing them since we have coordinates.

#Replacing zeros to NAs in sexes.
newdat$Female <- replace(newdat$Female, newdat$Female == 0, NA)
newdat$Male <- replace(newdat$Male, newdat$Male == 0, NA)
newdat$Worker <- replace(newdat$Worker, newdat$Worker == 0, NA)
newdat$Not.specified <- replace(newdat$Not.specified, newdat$Not.specified == 0, NA)

#Add "1" in Not.specified where all Female, Male, Worker, Not.specified are NAs.
na_rows <- is.na(newdat$Female) & is.na(newdat$Male) & is.na(newdat$Worker) & is.na(newdat$Not.specified)
newdat$Not.specified[na_rows] <- 1

#Combine info under Any.other.additional.data and Notes.and.queries so that I can put coord prec into Notes.and.queries.
newdat$Any.other.additional.data <- paste(newdat$Any.other.additional.data, "meters in altitude")

#Copy Coordinate.precision to Notes.and.queries so that the info doesn't get lost.
newdat$Notes.and.queries <- paste(newdat$Coordinate.precision, "coordinate precision")

#Reorder and drop variables
newdat <- drop_variables(check, newdat) #No valuable info is lost

#Add unique identifier
newdat$uid <- paste("65_Alvarez", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/65_Alvarez.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

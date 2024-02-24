source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 77_Ortiz ---- From Data_Saray (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/77_Ortiz.csv', sep = ";")
#Dataset only contains two observations.

#Compare vars
compare_variables(check, newdat) #No vars missing, no extra vars.

#Coordinates are faulty. Should be Sierra Nevada but show just north of Alger. 
#Locality is "Monachil, Pradollano, Sierra Nevada" - Google maps give coordinates 37.09453839756701, -3.4001287983387463.
#Assumption: take these Google maps-coordinates and replace the faulty ones.
newdat$Latitude <- gsub("37.09133", "37.09453839756701", newdat$Latitude)
newdat$Longitude <- gsub("3.399972", "-3.4001287983387463", newdat$Longitude)

#Replacing zeros to NAs in sexes.
newdat$Female <- replace(newdat$Female, newdat$Female == 0, NA)
newdat$Male <- replace(newdat$Male, newdat$Male == 0, NA)
newdat$Worker <- replace(newdat$Worker, newdat$Worker == 0, NA)

#Add "1" in Not.specified where all Female, Male, Worker, Not.specified are NAs.
na_rows <- is.na(newdat$Female) & is.na(newdat$Male) & is.na(newdat$Worker) & is.na(newdat$Not.specified)
newdat$Not.specified[na_rows] <- 1

#Copy Coordinate.precision to Notes.and.queries so that the info doesn't get lost.
newdat$Notes.and.queries <- paste(newdat$Coordinate.precision, "coordinate precision") #A decimal coordinate is being overwritten, assume not smth important.

#Reorder and drop variables
newdat <- drop_variables(check, newdat) #No valuable info is lost

#Add unique identifier
newdat$uid <- paste("77_Ortiz", 1:nrow(newdat), sep = "")

newdat$Coordinate.precision <- "10m"

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/77_Ortiz.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

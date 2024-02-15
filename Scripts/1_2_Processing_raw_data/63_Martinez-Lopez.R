source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 63_Martinez-Lopez ---- (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/63_Martinez-Lopez.csv', sep = ";")

#Note: this is a big file, but contains mostly blank rows.

#Compare vars
compare_variables(check, newdat) #Some variables have faulty names. Some classes wrong.

#Renamning columns
newdat <- newdat |> mutate(Coordinate.precision = Coordinate.precision..e.g..GPS...10km..)
newdat <- newdat |>  mutate(Month = month)
newdat <- newdat |>  mutate(Day = day)
newdat <- newdat |>  mutate(Reference.doi = Reference..doi.)
newdat <- newdat |>  mutate(End.date = End.Date)
newdat <- newdat |>  mutate(Determined.by = Determiner)
newdat <- newdat |>  mutate(Local_ID = Collection.Location_ID)

#Change from 'Region de Murcia' to only 'Murcia'
newdat$Province <- "Murcia"

#Removing degree sign ° after coordinates
newdat$Longitude <- as.numeric(gsub("°", "", newdat$Longitude))
newdat$Latitude <- as.numeric(gsub("°", "", newdat$Latitude))

#Add missing variables
newdat <- add_missing_variables(check, newdat)  #Subgenus and uid added.

#Comparing vars again
compare_variables(check, newdat) #Looks good.

#Delete rows with only NA's, doing it by coding where Year=NA since these correspond are equivalent to the rows with NA's. s
newdat <- subset(newdat, !is.na(Year))

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
newdat$uid <- paste("63_Martinez-Lopez", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/63_Martinez-Lopez.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

#After taking care of the collector etc - I think this dataset is done.
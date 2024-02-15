source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 80_Torres ---- (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/80_Torres_1.csv', sep = ";")
newdat_2 <- read.csv(file = 'Data/Rawdata/csvs/80_Torres_2.csv', sep = ";")

#Fix data frames so that they have equally no of columns, before merging them.
newdat <- select(newdat, -starts_with("X"))
newdat_2 <- select(newdat_2, -starts_with("X"))

#Combining the two data frames.
newdat <- rbind(newdat, newdat_2)
rm(newdat_2)

#Compare vars
compare_variables(check, newdat) #All variables missing. 

#Add missing variables
newdat <- add_missing_variables(check, newdat)

#Remove Apis mellifera
newdat <- filter(newdat, newdat$Species != "mellifera")

#Fix typo in Year.
newdat <- newdat |>
  mutate(Year = recode(Year, "´1986" = "1986"))

#Add coordinate precision. Note that only ~10% of the obs have coordinates.
#However, the coordinates have many decimals (min 5) -> I assume Coordinate.precision <100 m.
newdat$Coordinate.precision <- ifelse(!is.na(newdat$Longitude) & !is.na(newdat$Latitude),
                                      "<100m", NA)

#Replacing zeros to NAs in sexes.
newdat$Female <- replace(newdat$Female, newdat$Female == 0, NA)
newdat$Male <- replace(newdat$Male, newdat$Male == 0, NA)
newdat$Worker <- replace(newdat$Worker, newdat$Worker == 0, NA)
newdat$Not.specified <- replace(newdat$Not.specified, newdat$Not.specified == 0, NA)

#Add "1" in Not.specified where all Female, Male, Worker, Not.specified are NAs.
na_rows <- is.na(newdat$Female) & is.na(newdat$Male) & is.na(newdat$Worker) & is.na(newdat$Not.specified)
newdat$Not.specified[na_rows] <- 1

#Drop variables
newdat <- drop_variables(check, newdat)

#Add unique identifier
newdat$uid <- paste("80_Torres", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/80_Torres.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

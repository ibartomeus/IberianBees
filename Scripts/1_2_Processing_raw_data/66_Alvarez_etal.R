source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 66_Alvarez_etal ---- From Data_Saray (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/66_Alvarez_etal.csv', sep = ";")

#Compare vars
compare_variables(check, newdat) #No vars missing, no extra vars. Some classes wrong.

#Note that some dates are NAs, but not removing them since we have coordinates.

#Some cells in 'Flowers.visited' have additional text after species like "(Fig 11.)". Remove this additional text
newdat$Flowers.visited <- gsub("\\s*\\(Fig\\.\\s*\\d+\\)$", "", newdat$Flowers.visited)

#Note that we have 3 observations from yr 1984 that lack coordinates. But we have Coordinate.precision being 20TUN59C.
#Perhaps can extract rough coordinates from this?

#Reorder and drop variables
newdat <- drop_variables(check, newdat) #No valuable info is lost

#Add unique identifier
newdat$uid <- paste("66_Alvarez_etal", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/66_Alvarez_etal.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

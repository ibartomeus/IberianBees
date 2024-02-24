source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 60_Lopez-Angulo_etal ---- (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/60_Lopez-Angulo_etal.csv', sep = ";")

#Compare vars
compare_variables(check, newdat) #No obvious errors found here. Some classes wrong.

#Add missing variables
newdat <- add_missing_variables(check, newdat) #uid column added.

#Delete two rows with only NA's that don't contain any info at all.
newdat <- subset(newdat, !is.na(Year))

#Assume one species observed per observation event.
newdat$Not.specified <- "1"

#Copy Coordinate.precision to Any.other.additional.data so that the info doesn't get lost.
newdat$Any.other.additional.data <- paste(newdat$Coordinate.precision, "coordinate precision")

#Compare vars again
compare_variables(check, newdat) #Looks good

#Drop variables
newdat <- drop_variables(check, newdat) #This not really necessary since we don't have any extra vars.

#Add unique identifier
newdat$uid <- paste("60_Lopez-Angulo_etal", 1:nrow(newdat), sep = "")

#lat long is character because dec is ,
newdat$Latitude <- as.numeric(gsub(pattern = ",", replacement = ".", x = newdat$Latitude))
newdat$Longitude <- as.numeric(gsub(pattern = ",", replacement = ".", x = newdat$Longitude))


#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/60_Lopez-Angulo_etal.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

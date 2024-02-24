source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 59_Antonini_etal ---- (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/59_Antonini_etal.csv', sep = ";")
str(newdat)
#Compare vars
compare_variables(check, newdat) #No obvious errors found here. Some classes are wrong.

help_structure() #Delete later

#Add missing variables
newdat <- add_missing_variables(check, newdat) #uid column added

#Change months from alphabetic to numeric
month_names <- c("january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december")
newdat$Month <- match(trimws(newdat$Month), month_names) #Using trimws if the months are followed by a blank space.

#Last row on 'Authors to give credit' is missing an input. Adding here.
newdat$Authors.to.give.credit <- gsub("^$", "Yasmine Antonini/Montserrat Arista/Juan Arroyo", newdat$Authors.to.give.credit)

#Assume one species observed per observation event.
newdat$Not.specified <- "1"

#Copy Coordinate.precision to Any.other.additional.data so that the info doesn't get lost.
newdat$Any.other.additional.data <- paste(newdat$Coordinate.precision, "coordinate precision")

#Compare vars again
compare_variables(check, newdat)

#Drop variables
newdat <- drop_variables(check, newdat) #This not really necessary since we don't have any extra vars.

#Add unique identifier
newdat$uid <- paste("59_Antonini_etal", 1:nrow(newdat), sep = "")

#lat long is character because dec is ,
newdat$Latitude <- as.numeric(gsub(pattern = ",", replacement = ".", x = newdat$Latitude))
newdat$Longitude <- as.numeric(gsub(pattern = ",", replacement = ".", x = newdat$Longitude))

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/59_Antonini_etal.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

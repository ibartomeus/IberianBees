source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 61_Wood ---- (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/61_Wood.csv', sep = ";")

#Compare vars
compare_variables(check, newdat) #Some extra variables, and some w faulty names. Some classes wrong.

#Renamning columns
newdat <- newdat |> mutate(Determined.by = Determiner)

#Add missing variables
newdat <- add_missing_variables(check, newdat) #Columns added

#Fixing dates
#install.packages("lubridate")
library(lubridate)
newdat$Year <- year(newdat$Start.date)
newdat$Month <- month(newdat$Start.date)
newdat$Day <- day(newdat$Start.date)

#Add authors
newdat$Authors.to.give.credit <- "T.Wood"

#Add "1" in Not.specified where all three Female, Male, Worker are NAs.
na_rows <- is.na(newdat$Female) & is.na(newdat$Male) & is.na(newdat$Worker)
newdat$Not.specified[na_rows] <- 1

#Compare vars again
compare_variables(check, newdat)

#Reorder and drop variables
newdat <- drop_variables(check, newdat) #No valuable info is lost. A column called 'Source' w info 'TJW Colln.' is removed.

#Add unique identifier
newdat$uid <- paste("61_Wood", 1:nrow(newdat), sep = "")

#lat long is character because dec is ,
newdat$Latitude <- as.numeric(gsub(pattern = ",", replacement = ".", x = newdat$Latitude))
newdat$Longitude <- as.numeric(gsub(pattern = ",", replacement = ".", x = newdat$Longitude))


#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/61_Wood.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

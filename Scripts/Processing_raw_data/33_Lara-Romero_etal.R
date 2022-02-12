source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 33_Lara-Romero_etal  ----

#Read data
newdat <- read.csv(file = "Data/Rawdata/csvs/33_Lara-Romero_etal.csv")

#Check cols
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("33_Lara-Romero_etal_", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24,28)]#reorder
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
newdat$Reference..doi. <- "https://doi.org/10.1111/1365-2435.12719" #I assume a single paper

#Check variables
compare_variables(check, newdat)
colnames(newdat)[which(colnames(newdat) == 'Coordinate.precision..e.g..GPS...10km.')] <- 'Coordinate.precision' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'month')] <- 'Month' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'day')] <- 'Day' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Reference..doi.')] <- 'Reference.doi' #Rename variables if needed

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/33_Lara-Romero_etal.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE)

source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 16_Carvalho ----

#Read data
newdat <- read.csv(file = "Data/Rawdata/csvs/16_Carvalho.csv")

#Check vars
compare_variables(check, newdat)

#Rename variables 
colnames(newdat)
colnames(newdat)[10] <- "precision"
colnames(newdat)[which(colnames(newdat) == 'day')] <- 'Day' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Reference..doi.')] <- 'Reference.doi' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'precision')] <- 'Coordinate.precision' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'End.Date')] <- 'End.date' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'COLLECTION')] <- 'Local_ID' #Rename variables if needed

#reorder and drop variables
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) 

#species includes genus
newdat$Species <- unlist(strsplit(x = as.character(newdat$Species),split = " "))[seq(2,108,2)]
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$Authors.to.give.credit <- "R. Carvalho, S. Castro, J. Loureiro"

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '16_Carvalho_')

#write
write.table(x = newdat, file = "Data/Processed_raw_data/16_Carvalho.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE)

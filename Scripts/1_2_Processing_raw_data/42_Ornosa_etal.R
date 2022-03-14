source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template


# 42_Ornosa_etal  ----

#Read data
newdat <- read.csv(file = "Data/Rawdata/csvs/42_Ornosa_etal.csv")

#Check cols
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("42_Ornosa_etal_", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24,28)]#reorder
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)

compare_variables(check, newdat)
#Rename colnames
colnames(newdat)[which(colnames(newdat)=="Coordinate.precision..e.g..GPS...10km.")] <- "Coordinate.precision"
colnames(newdat)[which(colnames(newdat)=="month")] <- "Month"
colnames(newdat)[which(colnames(newdat)=="day")] <- "Day"
colnames(newdat)[which(colnames(newdat)=="Determiner")] <- "Determined.by"
colnames(newdat)[which(colnames(newdat)=="Reference..doi.")] <- "Reference.doi"
newdat <- drop_variables(check, newdat) #reorder and drop variables

#Convert month to numeric
newdat$Month <- match(newdat$Month, month.name)
#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Change separator in collector
newdat$Collector <- gsub("\\ &", ",", newdat$Collector)

#Fix DOI with extra dot
newdat$Reference.doi <- gsub("https://doi.org/10/f3pm57.",
                             "https://doi.org/10/f3pm57", newdat$Reference.doi)
#All DOI'S work fine now

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/42_Ornosa_etal.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

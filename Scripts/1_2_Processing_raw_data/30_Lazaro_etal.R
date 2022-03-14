source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template


# 30_Lazaro_etal  ----

#Raed data
newdat <- read.csv(file = "Data/Rawdata/csvs/30_Lazaro_etal.csv")
colnames(newdat)[9] <- "precision" #just to see them both in two lines
colnames(newdat)

#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$uid <- paste("30_Lazaro_etal_", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,30,2:29,31)]
#unify Authors.
newdat$Authors.to.give.credit0 <- paste(newdat$Authors.to.give.credit,
                                        newdat$Authors.to.give.credit.1,
                                        newdat$Authors.to.give.credit.2,
                                        newdat$Authors.to.give.credit.3, sep = ", ")
newdat <- newdat[,c(1:24,32,29:31)]
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)

#Compare variables and rename if necessary
compare_variables(check, newdat)
colnames(newdat)[which(colnames(newdat) == 'day')] <- 'Day' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'End.Date')] <- 'End.date' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Reference..doi.')] <- 'Reference.doi' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'precision')] <- 'Coordinate.precision' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Collection.Location_ID')] <- 'Local_ID' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Authors.to.give.credit0')] <- 'Authors.to.give.credit' #Rename variables if needed

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Convert to link format
newdat$Reference.doi <- paste0("https://doi.org/",
                               newdat$Reference.doi)
#Ugly but works, convert now "https://doi.org/NA" back to NA
newdat$Reference.doi <- gsub("https://doi.org/NA" , NA, newdat$Reference.doi)
#DOI works fine
newdat$Reference.doi[grepl("10.1016", newdat$Reference.doi)] <- "https://doi.org/10.1016/j.agee.2018.05.004"
newdat$Reference.doi[grepl("10.1111", newdat$Reference.doi)] <- "https://doi.org/10.1111/1365-2745.13334"

#Rename
levels(factor(newdat$Collector))
newdat$Collector <- gsub("M. A. González-Estévez (M. A. G. Estvz)",
                         "M. A. González-Estévez",newdat$Collector, fixed=T)


#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/30_Lazaro_etal.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

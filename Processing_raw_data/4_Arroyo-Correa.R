source("Processing_raw_data/Source_file.R") #Generate template

# 4_Arroyo-Correa ----

#The following items are done before the functions were up and running.
newdat <- read.csv(file = "Rawdata/csvs/4_Arroyo-Correa.csv")
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("4_Arroyo-Correa_", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24,28)]
#quick way to compare colnames
cbind(colnames(newdat) , colnames(data)) #can be merged
summary(newdat)

compare_variables(check, newdat)
#Rename cols to match template
names(newdat)[names(newdat) == 'month'] <- 'Month'
names(newdat)[names(newdat) == 'day'] <- 'Day'
names(newdat)[names(newdat) == 
                'Coordinate.precision..e.g..GPS...10km.'] <- 'Coordinate.precision'
#Add missing vars
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)

#Erase space of genus column
levels(factor(newdat$Genus))
newdat$Genus <- trimws(newdat$Genus, "r") #Erase trailing white space

#Save data
write.table(x = newdat, file = "Data/Processing_raw_data/4_Arroyo-Correa.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE)

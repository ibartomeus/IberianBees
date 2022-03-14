source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template


# 46_Obeso  ----

#help_structure()

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/46_Obeso.csv')

#check vars
compare_variables(check, newdat)

#Rename variables
colnames(newdat)[which(colnames(newdat) == 'species')] <- 'Species' 
colnames(newdat)[which(colnames(newdat) == 'subspecies')] <- 'Subspecies' 
colnames(newdat)[which(colnames(newdat) == 'year')] <- 'Year' 
colnames(newdat)[which(colnames(newdat) == 'latitude')] <- 'Latitude' 
colnames(newdat)[which(colnames(newdat) == 'longitude')] <- 'Longitude' 

#Add vars
newdat <- add_missing_variables(check, newdat)
newdat$Country <- "Spain"
newdat$Not.specified <- 1
newdat$Reference.doi <- "https://doi.org/10.1007/s00442-013-2731-7"
newdat$Authors.to.give.credit <- "E.F. Ploquin, J.M. Herrera, J.R. Obeso"
#extract_pieces()
#help_geo()
#help_species()
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)  

#Check levels
levels(factor(newdat$Subspecies))
newdat$Subspecies[newdat$Subspecies==""] <- NA

#add unique identifier
newdat <- add_uid(newdat = newdat, '46_Obeso_')


#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/46_Obeso.csv', 
            quote = TRUE, sep = ',', col.names = TRUE,
            row.names = FALSE)

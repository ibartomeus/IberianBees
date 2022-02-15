source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 15_Bartomeus_etal ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/15_Bartomeus_etal.csv', sep = ";")

#Check vars
compare_variables(check, newdat)

#Rename variables if needed
head(newdat)
colnames(newdat)[which(colnames(newdat) == 'Site')] <- 'Locality' 
colnames(newdat)[which(colnames(newdat) == 'ID')] <- 'Local_ID' 
newdat$Flowers.visited <- paste(newdat$plant_genus, newdat$plant_species)
unique(newdat$Sex)
newdat$Male <- ifelse(newdat$Sex == "male", 1, 0)
newdat$Female <- ifelse(newdat$Sex %in% c("female", "queen"), 1, 0)
newdat$Worker <- ifelse(newdat$Sex == "worker", 1, 0)

#reorder and drop variables
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) 
summary(newdat)
newdat$Authors.to.give.credit <- "I. Bartomeus"

#Clean NA's in genus
newdat <- newdat[!is.na(newdat$Genus),]

#Add country
newdat$Country <- "Spain"

#Add DOI
newdat$Reference.doi <- "https://doi.org/10.1007/s00442-007-0946-1"
#LAT LONG CAN BE ADDED!

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Fixed levels Determined.by
levels(factor(newdat$Determined.by))

newdat$Determined.by <- gsub("l.O. Aguado", 
"L.O. Aguado", newdat$Determined.by)
newdat$Determined.by <- gsub("C.Molina", 
"C. Molina", newdat$Determined.by)
newdat$Determined.by <- gsub("F.J.Ortiz", 
"F.J. Ortiz", newdat$Determined.by)
newdat$Determined.by <- gsub("L.Castro", 
"L. Castro", newdat$Determined.by)

newdat$Determined.by[newdat$Determined.by==""] <- "I. Bartomeus"

#Clean undetermined genus
newdat <- newdat %>% filter(!Genus=="Andrena??")

#Add unique identifier
newdat <- add_uid(newdat = newdat, '15_Bartomeus_etal_')

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/15_Bartomeus_etal.csv', 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

source("Scripts/Processing_raw_data/Source_file.R") #Generate template


#Add online data ----

#Read data
newdat <- read.csv(file = "Data/idata.csv")[,-1]
head(newdat)

#split genus species
newdat$Genus <- substr(newdat$species, 
                       start = 1,
                       stop = unlist(gregexpr(pattern = " ", newdat$species))-1)
newdat$Species <- substr(newdat$species, 
                         start = unlist(gregexpr(pattern = " ", newdat$species))+1,
                         stop = nchar(as.character(newdat$species)))  

#Rename cols
newdat$Collector <- newdat$recordedBy
newdat$Determined.by <- newdat$identifiedBy
levels(newdat$sex)
newdat$Subspecies <- newdat$subspecies
newdat$Female <- ifelse(newdat$sex %in% c("FEMALE", "female", "queen"), 1, 0)
newdat$Male <- ifelse(newdat$sex %in% c("MALE", "male"), 1, 0)
newdat$Worker <- ifelse(newdat$sex %in% c("worker"), 1, 0)
newdat$Not.specified <- ifelse(is.na(newdat$sex) | newdat$sex == "males_and_females", 1, 0)
colnames(data)
newdat$Subgenus <- NA
newdat$Province <- newdat$stateProvince
newdat$Locality <- newdat$locality
newdat$Coordinate.precision <- newdat$coordinatePrecision
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$Flowers.visited <- NA
newdat$Notes.and.queries <- NA
newdat$Latitude <- newdat$decimalLatitude
newdat$Longitude <- newdat$decimalLongitude
newdat$Year <- newdat$year
newdat$Month <- newdat$month
newdat$Day <- newdat$day
newdat$uid <- paste("55_Internet_", 1:nrow(newdat), sep = "")
#reorder
colnames(data)
colnames(newdat)
tail(newdat)

#Selectcols
newdat <- newdat[,c("Genus","Subgenus","Species","Subspecies",
                    "Country","Province","Locality",
                    "Latitude","Longitude","Coordinate.precision",
                    "Year","Month","Day","Start.date","End.date",
                    "Collector","Determined.by","Female","Male","Worker","Not.specified",
                    "Reference.doi","Flowers.visited","Local_ID","Authors.to.give.credit",
                    "Any.other.additional.data","Notes.and.queries", "uid")]
summary(newdat)
cbind(colnames(newdat), colnames(data)) #can be merged

#Check vars
compare_variables(check, newdat)

#Check species level
#Fix empty spaces
newdat$Locality[newdat$Locality==""] <- NA
#Set coord here to NA
newdat$Locality[newdat$Locality==" 40.586979, -3.702713 "] <- NA
newdat$Locality <- gsub("- ", "", newdat$Locality, fixed = TRUE)
#Delete leading and trailing spaces
newdat$Locality <- trimws(newdat$Locality)
newdat$Locality <- gsub('"', "", newdat$Locality, fixed = TRUE)
newdat$Locality <- gsub('-', "", newdat$Locality, fixed = TRUE)
newdat$Locality <- gsub('\\', "", newdat$Locality, fixed = TRUE)
newdat$Locality <- gsub('^,|.$', '', newdat$Locality)
#Run it again
newdat$Locality <- trimws(newdat$Locality)

#Add leading 0 to month column before merging
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)

#Add leading 0 to month column before merging
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)
#This black magic changes strings with numbers by NA
newdat$Collector[!grepl("[A-Za-z]+", newdat$Collector)] <- NA
#Convert first element of the string to cap
newdat$Collector <- str_to_title(newdat$Collector)
#Convert first element of the string to cap
newdat$Determined.by <- str_to_title(newdat$Determined.by)




s <- data.frame(levels(factor(newdat$Locality)))




unique(newdat$Locality)
newdat$Locality <- gsub('"', "", newdat$Locality, fixed = TRUE)
newdat$Locality <- gsub('-', "", newdat$Locality, fixed = TRUE)
newdat$Locality <- gsub('\\', "", newdat$Locality, fixed = TRUE)
#newdat$Locality <- gsub('', "", newdat$Locality, fixed = TRUE)
#Some of the above was causing a loooot of trubles.

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/55_Online_data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE)

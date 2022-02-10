source("Processing_raw_data/Source_file.R") #Generate template


#Add online data ----

#Read data
newdat <- read.csv(file = "data/idata.csv")[,-1]
head(newdat)

#split genus species
newdat$Genus <- substr(newdat$species, 
                       start = 1,
                       stop = unlist(gregexpr(pattern = " ", newdat$species))-1)
newdat$Species <- substr(newdat$species, 
                         start = unlist(gregexpr(pattern = " ", newdat$species))+1,
                         stop = nchar(as.character(newdat$species)))  
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
newdat <- newdat[,c("Genus","Subgenus","Species","Subspecies",
                    "Country","Province","Locality",
                    "Latitude","Longitude","Coordinate.precision",
                    "Year","Month","Day","Start.date","End.date",
                    "Collector","Determined.by","Female","Male","Worker","Not.specified",
                    "Reference.doi","Flowers.visited","Local_ID","Authors.to.give.credit",
                    "Any.other.additional.data","Notes.and.queries", "uid")]
summary(newdat)
cbind(colnames(newdat), colnames(data)) #can be merged
unique(newdat$Locality)
newdat$Locality <- gsub('"', "", newdat$Locality, fixed = TRUE)
newdat$Locality <- gsub('-', "", newdat$Locality, fixed = TRUE)
newdat$Locality <- gsub('\\', "", newdat$Locality, fixed = TRUE)
#newdat$Locality <- gsub('', "", newdat$Locality, fixed = TRUE)
#Some of the above was causing a loooot of trubles.

#Save data
write.table(x = newdat, file = "Data/Processing_raw_data/55_Online_data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE)

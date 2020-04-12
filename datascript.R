#This script takes data.csv and make a sanity check and updates metadata

data <- read.csv("data/data.csv")
head(data)

#1) cleaning----
#Check Genus, Subgenus, Species, Subspecies and maybe add family.----
#strip start and end spaces
data$Genus <- trimws(data$Genus)
data$Species <- trimws(data$Species)
#Remove species = sp or NA
unique(data$Species)
data <- subset(data, !Species %in% c("sp.", "sp.1", "sp.2", "sp.3", "sp.4", "sp.5", "sp.6",
                                    "sp.7", ""))
data <- data[-which(is.na(data$Species) == TRUE),] 
#Move ?? and "_or_" " o  to $flag.
#TO DO
#Ideally we can have a list of Iberian bees and check against it. Asl Thomas?
data$Genus_species <- paste(data$Genus, data$Species)
sort(unique(data$Genus_species)) #679! #move to summary

#Check Country Province Locality----
#bad solution as is sensitive to data updates with extra levels
levels(data$Country) <- c("Spain", "Portugal", "Spain") 
levels(data$Province) #Need to fix several
levels(data$Locality) #some " " at the end of the string can be striped, 
#Not done for now. use trimws

#Check Latitude Longitude Coordinate.precision----
max(data$Latitude, na.rm = TRUE) < 44.15
min(data$Latitude, na.rm = TRUE) > 35.67 
#unique(data[which(data$Latitude < 35.67),"Authors.to.give.credit"]) #Martínez-Núñez C., Rey P.J.
max(data$Longitude, na.rm = TRUE) < 4.76 
#unique(data[which(data$Longitude > 4.76), "Authors.to.give.credit"]) #idem.
min(data$Longitude, na.rm = TRUE) > -10.13
#CHECK BELOW AND MAKE IT SAFER
levels(data$Coordinate.precision) <- c("<100m","<10km","<10m","<1km","<2km",      
                                       "<2km","<3km","<4km","<5km","<5km",      
                                       "<100m","100m", "100m", "<3km",
                                       "false", "GPS", "GPS", "GPS", "true") #bad solution as is sensitive to data updates with extra levels
#Check false and true, probably coming from Gbif/iNat

#Check Year Month Day Start.date End.date -----
summary(data$Year) #Fuck! NOt fixing it now.
data$Year <- as.numeric(as.character(data$Year)) #NOT CORRECT; BUT TO ALLOW PLOTTING
summary(data$Month) #fix months! + #Idem as year :(
summary(data$Day) #Idem as year :(

unique(data$Start.date) 
unique(data$End.date) 
#Se puede calculat mean day's y months cuando estos son NA?

#Check Collector, Determined.by-----
unique(data$Collector) 
#Maybe iNaturalist userd can have a prefix, 
#some encoding bugs, 
#a couple of "-264761682" and similars... provide as is.
unique(data$Determined.by) #similar here, as iNat... 
#Here we can have a list of Trusted Taxonomists?

#Check Female Male Worker Not.specified-----
#Fuck, male and female factors!! Why!!
Total <- data$Male + data$Female + data$Worker + data$Not.specified
summary(Total) #Total = 0 imply Not.specified shouls = 1.
#convert NA's to zero.
#Add total column?

#Check Reference.doi, Flowers.visited, Local_ID, Authors.to.give.credit----
unique(data$Reference.doi) 
#In the future we can test format AND retrieve paper info in another table
#This one is fuck up: 10.1111/1365-2745.13334 in excel.
#Also: DOI 10.1007/s11258-013-0247-1
#For anna montero, maybe selet just one doi?
unique(data$Flowers.visited)
#Gsub "_" " ".
#"nido", "Al vuelo", "No ensayo", "HIBERNATING" Remove? Move to comments?
#Quite good. Provide as.is.
#strip final " ".
unique(data$Local_ID) #as.is
unique(data$Authors.to.give.credit) #list of coautors
#Can be pasted, then split by , and create new dataset where total records is added?

#Check Any.other.additional.data, Notes.and.queries -----
unique(data$Any.other.additional) 
unique(data$Notes.and.queries)
#NEEDS FURTHER CHECKING to FLAG column?

#2) Flags and consolidating bbdd----
#species in the see (ignore for now?)
#Remove duplicates.
#Trusted column?

#Write new file-----
write.table(x = data, file = "data/data_clean.csv", 
            quote = TRUE, sep = ",",
            row.names = FALSE)

#Old Notes:----
#Make automatic tests for this things.
#flowers species with Genus_spcies -> change in bulk.
#questions: Bombus has two forms "Bombus" and "Bombus " #run a white space eraser in bulk.
#questions: flowers species visited list more than one flower, comma separated. Fix Later
#question: España and Spain both used. Fix in bulk.
#newdat$Reference..doi. several doi's listed "," and "and" separated. Fix later? What to do with dois?
#remove all NA rows
#remove duplicates?
#create column of trusted / untrusted.
#summaries -> how to separate authors? 
  
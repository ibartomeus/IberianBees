# Template to Add new data.

#Create an empty data file. 
data <- matrix(ncol = 28, nrow = 1)
data <- as.data.frame(data)
colnames(data) <- c("Genus","Subgenus","Species","Subspecies",
                    "Country","Province","Locality",
                    "Latitude","Longitude","Coordinate.precision",
                    "Year","Month","Day","Start.date","End.date",
                    "Collector","Determined.by","Female","Male","Worker","Not.specified",
                    "Reference.doi","Flowers.visited","Local_ID","Authors.to.give.credit",
                    "Any.other.additional.data","Notes.and.queries", "uid")
head(data)
write.csv(data, "data/data.csv", row.names = FALSE)

#read data.csv for comparisons
#data <- read.csv("data/data.csv")
#colnames(data)
#head(data)

#set up----
#Load functions NOW is manually done from cleaner repo
library(cleanR)
check <- define_template(data, NA)

#Add data Montero----
newdat <- read.csv(file = "rawdata/csvs/3_Montero_etal.csv")
#old template, subgenus, start and end date missing.

compare_variables(check, newdat)
#Rename variables
colnames(newdat)[which(colnames(newdat) ==
                         "Coordinate.precision..e.g..GPS...10km.")] <- "Coordinate.precision"
newdat <- add_missing_variables(check, newdat)
#reorder and drop variables
newdat <- drop_variables(check, newdat)
#quick way to compare colnames
cbind(colnames(newdat) , colnames(data)) #can be merged
summary(newdat)
newdat$Authors.to.give.credit <- "Ana Montero-Castaño, Montserrat Vilà"
temp <- extract_pieces(newdat$Genus, subgenus = TRUE) 
newdat$Subgenus <- temp$piece1
newdat <- add_uid(newdat = newdat, "AM")
#newdat$Reference..doi. several doi's listed "," and "and" separated. Fix later?
#questions flowers species with Genus_species -> accepted, easy to change in bulk. 
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
#keep track of expected length
size <- nrow(newdat) #because is the first one!

#The following items are done before the functions were up and running.
#Add data BAC ----
newdat <- read.csv(file = "rawdata/csvs/4_Arroyo-Correa.csv")
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("BAC", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24,28)]
#quick way to compare colnames
cbind(colnames(newdat) , colnames(data)) #can be merged
summary(newdat)
#questions: flowers species visited list more than one flower, comma separated. Fix Later 
#questions: Bombus has two forms "Bombus" and "Bombus " #run a white space eraser in bulk.
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#Add data Castro ----
newdat <- read.csv(file = "rawdata/csvs/18_Castro_etal.csv")
colnames(newdat)[10] <- "precision" #just to see them both in two lines
#quick way to compare colnames
head(newdat)
newdat$uid <- paste("FLOWerLab", 1:nrow(newdat), sep = "")
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
#species contains genus.
newdat$Species <- as.character(newdat$Species)
newdat$Species <- trimws(newdat$Species) 
temp <- unlist(gregexpr(pattern = " ", fixed = TRUE, text = newdat$Species))
length(temp) == length(newdat$Species)
for(i in which(temp > 0)){
  newdat$Species[i] <- substr(newdat$Species[i], start = temp[i]+1, 
                               stop = nchar(newdat$Species[i]))
}
#question: España and Spain both used. Fix in bulk.
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#Add data IMEDEA ----
newdat <- read.csv(file = "rawdata/csvs/30_Lazaro_etal.csv")
colnames(newdat)[9] <- "precision" #just to see them both in two lines
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$uid <- paste("IMEDEA", 1:nrow(newdat), sep = "")
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
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#Add data JV ----
newdat <- read.csv(file = "rawdata/csvs/32_Valverde.csv")
colnames(newdat)[9] <- "precision" #just to see them both in two lines
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$uid <- paste("JV", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,27,2:26,28)]
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
newdat$Start.date <- NA
newdat$End.Date <- NA
newdat$day #uses multiple days...
#manual, too specific to functionalize for now
newdat$day <- as.character(newdat$day)
for (i in 1:length(newdat$day)){
  temp <- as.numeric(unlist(strsplit(newdat$day[i], split = ";")))
  newdat$Start.date[i] <- paste(min(temp),newdat$Month[i],newdat$Year[i], sep = "-")
  newdat$End.Date[i] <- paste(max(temp),newdat$Month[i],newdat$Year[i], sep = "-")
  newdat$day[i] <- round(mean(temp),0)  
}
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#Add data LaraRomero ----
newdat <- read.csv(file = "rawdata/csvs/33_Lara-Romero_etal.csv")
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("LR", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24,28)]#reorder
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
newdat$Reference..doi. <- "10.1111/1365-2435.12719" #I assume a single paper
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#Add data MartinezNunez ----
newdat <- read.csv(file = "rawdata/csvs/36_Nunez.csv")
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("CMN", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24,28)]#reorder
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
newdat[131,4] <- NA
newdat$Authors.to.give.credit <- "Martínez-Núñez C., Rey P.J."
#Lat and Long mixed I think
temp <- newdat$Latitude
newdat$Latitude <- newdat$Longitude
newdat$Longitude <- temp
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#Add data MFM ----
newdat <- read.csv(file = "rawdata/csvs/42_Ornosa_etal.csv")
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("MFM", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24,28)]#reorder
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#Add data Nunez ----
newdat <- read.csv(file = "rawdata/csvs/45_Nunez.csv")
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("AN", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24,28)]#reorder
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#Add data Heleno ----
newdat <- read.csv(file = "rawdata/csvs/50_Heleno_etal.csv")
colnames(newdat)
colnames(newdat)[9] <- "precision" #just to see them both in two lines
#subgenus missing.
newdat$Subgenus <- NA
newdat$uid <- paste("RH", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,27,2:26,28)]
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
#longitude and latitude in degrees minutes seconds...40.205835, -8.421204
newdat$Latitude <- 40.205835
newdat$Longitude <- -8.421204
newdat$Start.date <- NA
newdat$End.Date <- NA
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)


#Add data SERIDA ----
newdat <- read.csv(file = "rawdata/csvs/51_Minarro.csv")
nrow(newdat)
colnames(newdat)
#Move queri2 to determiner.
newdat$Determined.by <- ifelse(is.na(newdat$Determined.by), 
                               newdat$Notes.and.queries..2.,
                               newdat$Determined.by)
unique(newdat$Notes.and.queries)
newdat <- newdat[,-25]
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("SERIDA", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24,28)]
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
newdat$Authors.to.give.credit <- "M. Miñarro, A. Núñez"
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#Add data Ferrero----
newdat <- read.csv(file = "rawdata/csvs/53_Ferrero.csv")
colnames(newdat)
colnames(newdat)[9] <- "precision"
#subgenus missing.
newdat$Subgenus <- NA
newdat$uid <- paste("VF", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,27,2:26,28)]
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
newdat$Latitude <- as.character(newdat$Latitude)
newdat$Latitude[61] <- 37.39836111111111
newdat$Latitude <- as.numeric(newdat$Latitude)
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#Add data Cavalho----
newdat <- read.csv(file = "rawdata/csvs/16_Carvalho.csv")
colnames(newdat)
colnames(newdat)[10] <- "precision"
#quick way to compare colnames
newdat$uid <- paste("RC", 1:nrow(newdat), sep = "")
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
#species includes genus
newdat$Species <- unlist(strsplit(x = as.character(newdat$Species),split = " "))[seq(2,108,2)]
newdat$Start.date <- NA
newdat$End.Date <- NA
newdat$Authors.to.give.credit <- "R. Carvalho, S. Castro, J. Loureiro"
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#Add data vanapicanco-----
newdat <- read.csv(file = "rawdata/csvs/52_Picanco.csv")
colnames(newdat)
colnames(newdat)[9] <- "precision"
#subgenus missing.
newdat$Subgenus <- NA
newdat$Species <- as.character(newdat$Species)
newdat$Species <- trimws(newdat$Species) 
temp <- unlist(gregexpr(pattern = " ", fixed = TRUE, text = newdat$Species))
length(temp) == length(newdat$Species)
for(i in which(temp > 0)){
  newdat$Species[i] <- substr(newdat$Species[i], start = temp[i]+1, 
                              stop = nchar(newdat$Species[i]))
}
newdat$uid <- paste("AP", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,27,2:26,28)]
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)


#Add data Magrach-----
newdat <- read.csv(file = "rawdata/csvs/35_Magrach.csv")
#not formated, so let's start here
summary(newdat)
newdat$Subspecies <- NA
newdat <- subset(newdat, pollinator_group %in% c("Bumblebee", "other wild bee"))
#pollinator_species needs cleaning pollinator_species.1
unique(newdat$pollinator_species.1) #?
unique(newdat$pollinator_species)
newdat <- newdat[-which(newdat$pollinator_species == "sp"),]
newdat <- newdat[-grep(pattern = "sp_", 
                       x = newdat$pollinator_species, fixed = TRUE),]
newdat$pollinator_species <- gsub("-type", "", newdat$pollinator_species)
newdat$pollinator_species <- as.character(newdat$pollinator_species)
temp <- unlist(gregexpr(pattern = "_", fixed = TRUE, text = newdat$pollinator_species))
for(i in which(temp > 0)){
  newdat$Subspecies[i] <- substr(newdat$pollinator_species[i], start = temp[i]+1, 
                               stop = nchar(newdat$pollinator_species[i]))
  newdat$pollinator_species[i] <- substr(newdat$pollinator_species[i], start = 1, 
                            stop = temp[i]-1)
}                                             
#reshape structure
colnames(newdat)
#reorder
newdat$Subgenus <- NA
newdat$Province <- "Huelva"
newdat$Coordinate.precision <- "<1km"
newdat$Startday <- NA
newdat$Endday <- NA
newdat$Collector <- "Juan. P. Gonzalez-Varo"
newdat$Det <- "J. Ortiz"
newdat$Female <- NA
newdat$Male <- NA
newdat$Worker <- NA
newdat$Not.specified <- 1
newdat$Local_ID <- NA                 
newdat$Authors.to.give.credit <-  "J. Gonzalez-varo, M.Vilà" 
newdat$Any.other.additional.data <- NA
newdat$Notes.and.queries <- NA        
newdat$Reference.doi <- "10.1038/s41559-017-0249-9"
temp <- as.POSIXlt(newdat$date, format = "%m/%d/%Y") #extract month and day
newdat$month <- format(temp,"%m")
newdat$day <- format(temp,"%d")
newdat$uid <- paste("AM", 1:nrow(newdat), sep = "")
newdat <- newdat[,c("pollinator_genus",
                    "Subgenus",
                    "pollinator_species",
                    "Subspecies",
                    "country",
                    "Province",
                    "site_id",
                    "latitude",
                    "longitude",
                    "Coordinate.precision",
                    "year",
                    "month",
                    "day",
                    "Startday",
                    "Endday",
                    "Collector",
                    "Det",
                    "Female",
                    "Male",
                    "Worker",
                    "Not.specified",
                    "Reference.doi",
                    "Plant_sp",
                    "Local_ID",                 
                    "Authors.to.give.credit",
                    "Any.other.additional.data",
                    "Notes.and.queries",
                    "uid")]
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)


#Add data Obeso----
#I start using cleanR package
#help_template()
newdat <- read.csv(file = 'rawdata/csvs/46_Obeso.csv')
compare_variables(check, newdat)
colnames(newdat)[which(colnames(newdat) == 'species')] <- 'Species' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'subspecies')] <- 'Subspecies' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'year')] <- 'Year' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'latitude')] <- 'Latitude' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'longitude')] <- 'Longitude' #Rename variables if needed
newdat <- add_missing_variables(check, newdat)
newdat$Country <- "Spain"
newdat$Not.specified <- 1
newdat$Reference.doi <- "10.1007/s00442-013-2731-7"
newdat$Authors.to.give.credit <- "EF Ploquin, JM Herrera, JR Obeso"
#extract_pieces()
#help_geo()
#help_species()
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)  
newdat <- add_uid(newdat = newdat, 'JRO')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#Add Costa ----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/23_Costa.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
#extract_pieces()
#help_geo()
#help_species()
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'JC')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, 
            sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#Add Luis Miguel de Pablos.csv------
help_template()
newdat <- read.csv('rawdata/csvs/34_dePablos.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
#extract_pieces()
#help_geo()
#help_species()
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'LMdP')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length


# Add Bombus 2019 y 2020 C Ornosa -----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/9_Ornosa.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
#extract_pieces()
#help_geo()
#help_species()
(temp <- extract_date(newdat$Date, "%Y-%m-%d"))
newdat$Day <- temp$day
newdat$Month <- temp$month
newdat$Year <- temp$year
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'COb')
newdat$Authors.to.give.credit <- "Concepción Ornosa"
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

# Add A.Nunez ----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/22_Nunez.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'AN')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length


# Add Moreira-gonçalves-----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/6_Moreira.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'MG')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

# Add Bombus 2016 C Ornosa -----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/7_Ornosa.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
help_geo()
newdat$Latitude <- parzer::parse_lat(as.character(newdat$GPS..N.))
newdat$Longitude <- parzer::parse_lon(as.character(newdat$GPS..E.))
(temp <- extract_date(newdat$Date, "%Y-%m-%d"))
newdat$Day <- temp$day
newdat$Year <- temp$year
newdat$Month <- temp$month
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'CObb')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length


# Bombus terrestris varios años Ornosa----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/10_Ornosa_etal.csv', sep=";")
compare_variables(check, newdat)
(temp <- extract_date(newdat$Date, "%d-%m-%Y"))
newdat$Day <- temp$day
newdat$Year <- temp$year
newdat$Month <- temp$monthDate
newdat$Authors.to.give.credit <- "C. Ornosa"
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'CObt')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

# Add Hormaza -----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/29_Hormaza_etal.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'JIH')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

# Add Donana Stuart Roberts----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/28_Roberts.csv', sep = ";")
compare_variables(check, newdat)
colnames(newdat)[which(colnames(newdat) == 'Determiner')] <- 'Determined.by' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Males')] <- 'Male' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Females')] <- 'Female' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Notes')] <- 'Notes.and.queries' #Rename variables if needed
temp <- extract_pieces(newdat$Gen.Species, species = TRUE)
newdat$Genus <- temp$piece2
newdat$Species <- temp$piece1
(temp <- extract_date(newdat$Date, format_ = "%d/%m/%Y"))
newdat$Day <- temp$day
newdat$Month <- temp$month
newdat$Year <- temp$year
help_geo()
(temp <- mgrs::mgrs_to_latlng(as.character(newdat$Grid.Reference)))
newdat$Latitude <- temp$lat
newdat$Longitude <- temp$lng
newdat$Authors.to.give.credit <- "Stuart Roberts"
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'SR')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

# Add Abejas Sur 2011 y 2012 C Ornosa -------
help_template()
newdat <- read.csv(file = 'rawdata/csvs/1_Ornosa_etal.csv', sep = ";")
compare_variables(check, newdat)
(temp <- extract_date(newdat$Date, format_ = "%d-%m-%Y"))
newdat$Day <- temp$day
newdat$Month <- temp$month
newdat$Year <- temp$year
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'COs')
newdat$Authors.to.give.credit <- "C. Ornosa"
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

# Add Trillo -----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/25_Trillo.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'AT')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

# Add Rhodanthidium  C Ornosa   -----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/49_Ornosa_etal.csv', sep = ";")
compare_variables(check, newdat)
(temp <- extract_date(newdat$Date, "%d-%m-%Y"))
newdat$Day <- temp$day
newdat$Month <- temp$month
newdat$Year <- temp$year
help_geo()
temp <- mgrs::mgrs_to_latlng(as.character(newdat$UTM)[which(!is.na(newdat$UTM))][-c(8,12,13)])
newdat$Latitude[which(!is.na(newdat$UTM))][-c(8,12,13)] <- temp$lat
newdat$Longitude[which(!is.na(newdat$UTM))][-c(8,12,13)] <- temp$lng
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'CHr')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

# Add Muestreos abejas 2018 C Ornosa -----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/44_Ornosa.csv', sep = ";")
compare_variables(check, newdat)
(temp <- extract_date(newdat$Date, "%d-%m-%Y"))
newdat$Day <- temp$day
newdat$Month <- temp$month
newdat$Year <- temp$year
help_geo()
newdat$Latitude <- parzer::parse_lat(as.character(newdat$GPS..N.))
newdat$Longitude <- parzer::parse_lon(as.character(newdat$GPS..E.))
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'COa')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length


# Add Megachilidae 2004-2008 Ortiz-Torres-Ornosa---- 
help_template()
newdat <- read.csv(file = 'rawdata/csvs/37_Ortiz_etal.csv', sep = ";")
compare_variables(check, newdat)
help_species()
temp <- strsplit(x = as.character(newdat$UTM), split = ' ') 
lat <- c()
long <- c()
for (i in 1:length(newdat$UTM)){
  lat[i] <- temp[[i]][1] #for first split
  long[i] <- temp[[i]][2] #for second split
  } 
help_geo()
newdat$Latitude <- parzer::parse_lat(lat)
newdat$Longitude <- parzer::parse_lon(long)
newdat$Authors.to.give.credit <- "Ortiz, Ornosa, Torres"
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'OTO')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length


#Add Abejas varios anos hasta 2012 C Ornosa-----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/2_Ornosa_etal.csv', sep = ";")
compare_variables(check, newdat)
help_geo()
newdat$Latitude <- parzer::parse_lat(as.character(newdat$GPS))
newdat$Longitude <- parzer::parse_lon(as.character(newdat$GPS.1))
newdat$Authors.to.give.credit <- "C.Ornosa"
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'COv')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length


#Add Joan Díaz-Calafat----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/31_Diaz-Calafat.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'JDC')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length


#Add Bombus_UCM_Biobombus ----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/11_Ornosa_etal.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
help_geo()
newdat$Latitude <- parzer::parse_lat(as.character(newdat$GPS..N.)) 
newdat$Longitude <- parzer::parse_lon(as.character(newdat$GPS..E.))
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'test')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length


# Add Megachilidae Salamanca Félix Torres (C. Ornosa)----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/41_Torres.csv', sep =";")
compare_variables(check, newdat)
(temp <- extract_date(newdat$Date, "%d-%m-%Y"))
newdat$Day <- temp$day
newdat$Month <- temp$month
newdat$Year <- temp$year
#newdat$UTM #empty
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat$Authors.to.give.credit <- "Felix Torres"
newdat$Year <- ifelse(newdat$Year < 1000, newdat$Year +1900, newdat$Year)
newdat <- add_uid(newdat = newdat, 'FTm')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length


# Add C.Azpiazu----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/27_Azpiazu_etal.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'CA')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length


#Add Bombus 2017 C Ornosa----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/8_Ornosa.csv', sep = ";")
compare_variables(check, newdat)
help_geo()
newdat$Latitude <- parzer::parse_lat(as.character(newdat$GPS..N.))
newdat$Longitude <- parzer::parse_lon(as.character(newdat$GPS..E.))
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat$Authors.to.give.credit <- "C. Ornosa"
newdat <- add_uid(newdat = newdat, 'COb.')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

# Add RamonCasimiroSoriguer----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/48_Casimiro-Soriguer_etal.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'RCS')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length


#Add Megachilidae 2010-2012 Ortiz-Torres-Ornosa----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/39_Ortiz_etal.csv', sep = ";")
compare_variables(check, newdat)
(temp <- extract_date(newdat$Date, "%d-%m-%Y"))
newdat$Day <- temp$day
newdat$Month <- temp$month
newdat$Year <- temp$year
newdat <- add_missing_variables(check, newdat)
help_geo()
temp <- mgrs::mgrs_to_latlng(as.character(newdat$UTM)[!is.na(newdat$UTM)])
newdat$Latitude[!is.na(newdat$UTM)] <- temp$lat
newdat$Longitude[!is.na(newdat$UTM)] <- temp$lng
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat$Authors.to.give.credit <- "Ortiz, Torres, Ornosa"
newdat <- add_uid(newdat = newdat, 'OTOm')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#Add Megachilidae Rubus C Ornosa----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/40_Gonzalez.csv', sep = ";")
compare_variables(check, newdat)
(temp <- extract_date(newdat$Date, "%d-%m-%Y"))
newdat$Day <- temp$day
newdat$Month <- temp$month
newdat$Year <- temp$year
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat$Authors.to.give.credit <- "C. Ornosa"
newdat <- add_uid(newdat = newdat, 'COmr')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#Add Brassicaceae x Hymenoptera----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/13_Gomez.csv', sep = ";")
head(newdat)
compare_variables(check, newdat)
colnames(newdat)[which(colnames(newdat) == 'Plant_species')] <- 'Flowers.visited' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Frequency.of.visits')] <- 'Not.specified' #Rename variables if needed
(temp <- extract_date(newdat$Date, "%d/%m/%Y"))
newdat$Day <- ifelse(is.na(newdat$Day), temp$day, newdat$Day)
newdat$Month <- as.character(newdat$Month)
newdat$Month <- ifelse(as.character(newdat$Month) == "", as.character(temp$month), newdat$Month)
newdat$Year <- as.character(newdat$Year)
newdat$Year <- ifelse(newdat$Year == "", temp$year, newdat$Year)
#HERE WE CAN ENHANCE YEARS!! (to do someday)
temp <- extract_pieces(newdat$GenSp, species = TRUE)
head(temp)
newdat$Genus <- temp$piece2  
temp <- extract_pieces(temp$piece1, species = TRUE)  
newdat$Species <-ifelse(!is.na(temp$piece2), temp$piece2, temp$to_split)
newdat$Subspecies <-ifelse(!is.na(temp$piece2), temp$piece1, temp$to_split)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat$Authors.to.give.credit <- "compiled by JM Gomez"
newdat <- add_uid(newdat = newdat, 'JMG')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length


#Add Vicente Martínez-López----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/26_Ornosa_etal.csv')
compare_variables(check, newdat)
colnames(newdat)[which(colnames(newdat) == "Coordinate.precision..e.g..GPS...10km.")] <- "Coordinate.precision"
colnames(newdat)[which(colnames(newdat) == "month")] <- "Month"
colnames(newdat)[which(colnames(newdat) == "day")] <- "Day"
colnames(newdat)[which(colnames(newdat) == "End.Date")] <- "End.date"
colnames(newdat)[which(colnames(newdat) == "Determiner")] <- "Determined.by"
colnames(newdat)[which(colnames(newdat) == "Reference..doi.")] <- "Reference.doi"
colnames(newdat)[which(colnames(newdat) == "Collection.Location_ID")] <- "Local_ID"
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat$Latitude <- as.character(newdat$Latitude)
newdat$Longitude <- as.character(newdat$Longitude)
newdat$Latitude <- gsub("°", "", newdat$Latitude)
newdat$Longitude <- gsub("°", "", newdat$Longitude)
newdat$Latitude <- as.numeric(newdat$Latitude)
newdat$Longitude <- as.numeric(newdat$Longitude)
newdat <- add_uid(newdat = newdat, 'VML')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length


#Add Andreia Penado, Mário Boieiro, Carla Rego e Renata Santos----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/21_Boieiro_etal.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat$Latitude <- as.character(newdat$Latitude)
newdat$Longitude <- as.character(newdat$Longitude)
newdat$Latitude <- gsub("°", "", newdat$Latitude)
newdat$Longitude <- gsub("°", "", newdat$Longitude)
newdat$Latitude <- as.numeric(newdat$Latitude)
newdat$Longitude <- as.numeric(newdat$Longitude)
newdat <- add_uid(newdat = newdat, 'APMBCRRS')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length


#Add Bombus_UMU_BIOBOMBUS----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/12_Ornosa_etal.csv', sep = ";")
compare_variables(check, newdat)
(temp <- extract_date(newdat$Date, "%Y-%m-%d"))
newdat$Day <- temp$day
newdat$Month <- temp$month
newdat$Year <- temp$year
help_geo()
newdat$Latitude <- parzer::parse_lat(as.character(newdat$GPS..N.))
newdat$GPS..O. <- as.character(newdat$GPS..O.)
newdat$GPS..O. <- gsub("O", "", newdat$GPS..O.)
newdat$Longitude <- parzer::parse_lon(as.character(newdat$GPS..O.)) #decimales...
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat$Authors.to.give.credit <- "C. Ornosa"
newdat <- add_uid(newdat = newdat, 'COUMU')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#Add Bumblebee_data_climate_Marshall_et_al_2020-----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/14_Marshall.csv', sep = ";")
compare_variables(check, newdat)
head(newdat)
levels(newdat$Visitor)[11] <- "Bombus terrestris"
temp <- extract_pieces(newdat$Visitor, species = TRUE) 
newdat$Genus <- temp$piece2
newdat$Species <- temp$piece1
colnames(newdat)[which(colnames(newdat) == 'Plant')] <- 'Flowers.visited' #Rename variables if needed
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'M')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#Add cuadernos_abulenses----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/20_Gayubo.csv', sep = ";")
compare_variables(check, newdat)
head(newdat)
help_geo()
temp <- mgrs::mgrs_to_latlng(as.character(newdat$UTM))
newdat$Latitude <- temp$lat
newdat$Longitude <- temp$lng
(temp <- extract_pieces(newdat$Species, species = TRUE))
newdat$Species <- temp$piece1
unique(newdat$Sex)
newdat$Male <- ifelse(newdat$Sex %in% c("male", "m"), newdat$Individuals, 0)
newdat$Female <- ifelse(newdat$Sex == "female", newdat$Individuals, 0)
colnames(newdat)[which(colnames(newdat) == 'dataFrom')] <- 'Reference.doi' #Rename variables if needed
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'G')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#Add BanosPicon ---- 
help_template()
newdat <- read.csv(file = 'rawdata/csvs/5_Banos-Picon_etal.csv')
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
#NO CONSIGO ENTENDER COMO ESTAN LAS COORDENADAS!! 
newdat$Latitude <- NA
newdat$Longitude <- NA
newdat <- add_uid(newdat = newdat, 'BP')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#Add CapCreus.csv----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/15_Bartomeus_etal.csv', sep = ";")
compare_variables(check, newdat)
head(newdat)
colnames(newdat)[which(colnames(newdat) == 'Site')] <- 'Locality' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'ID')] <- 'Local_ID' #Rename variables if needed
newdat$Flowers.visited <- paste(newdat$plant_genus, newdat$plant_species)
unique(newdat$Sex)
newdat$Male <- ifelse(newdat$Sex == "male", 1, 0)
newdat$Female <- ifelse(newdat$Sex %in% c("female", "queen"), 1, 0)
newdat$Worker <- ifelse(newdat$Sex == "worker", 1, 0)
#DOI and LAT LONG CAN BE ADDED
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat$Authors.to.give.credit <- "I. Bartomeus"
newdat <- add_uid(newdat = newdat, 'IB')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#Add AinhoaM----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/24_Magrach.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'AM2.')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#Add Megachilidae 2009 Ortiz-Torres-Ornosa ---- 
help_template()
newdat <- read.csv(file = 'rawdata/csvs/38_Ortiz_etal.csv', sep = ";")
compare_variables(check, newdat)
help_geo()
temp <- mgrs::mgrs_to_latlng(as.character(newdat$UTM)[!is.na(newdat$UTM)][-c(40,51,52)]) #40, 51, 52 fail
newdat$Latitude <- NA
newdat$Latitude[!is.na(newdat$UTM)][-c(40,51,52)] <- temp$lat
newdat$Longitude <- NA
newdat$Longitude[!is.na(newdat$UTM)][-c(40,51,52)] <- temp$lng
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat$Female <- as.character(newdat$Female)
newdat$Worker[which(newdat$Female == " obrera")] <- 1
newdat$Female[which(newdat$Female == " obrera")] <- 0
newdat$Authors.to.give.credit <- "Ortiz, Torres, Ornosa"
newdat <- add_uid(newdat = newdat, 'OTO2.')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#Add historical data (Collado)----
help_template()
newdat <- read.csv(file = "rawdata/csvs/47_Collado_etal.csv", sep = ";")
compare_variables(check, newdat)
colnames(newdat)[which(colnames(newdat) == 'Local_id')] <- 'Local_ID' #Rename variables if needed"
colnames(newdat)[which(colnames(newdat) == 'collector')] <- 'Collector' #Rename variables if needed"
colnames(newdat)[which(colnames(newdat) == 'taxonomist')] <- 'Determined.by' #Rename variables if needed"
colnames(newdat)[which(colnames(newdat) == 'm_plant_species')] <- 'Flowers.visited' 
colnames(newdat)[which(colnames(newdat) == 'Location')] <- 'Locality' 
#UTM We can recover some UTM's from here!
#Long / lat not in numeric :( 
unique(newdat$Latitude)
newdat$Latitude <- as.character(newdat$Latitude)
newdat$Latitude[which(newdat$Latitude %in% c("40.807867,"))] <- 40.807867
newdat$Latitude[which(newdat$Latitude %in% c(""))] <- NA
newdat$Latitude[which(newdat$Latitude %in% c("42.566667, 0.45"))] <- 42.566667
newdat$Latitude[which(newdat$Latitude %in% c("42.55, -0.55"))] <- 42.55
newdat$Longitude <- as.character(newdat$Longitude)
unique(newdat$Longitude)
newdat$Longitude[which(newdat$Longitude %in% c("42.566667, 0.45"))] <- 0.45
newdat$Longitude[which(newdat$Longitude %in% c(""))] <- NA
newdat$Longitude[which(newdat$Longitude %in% c("42.55, -0.55"))] <- -0.55
newdat$Latitude <- as.numeric(as.character(newdat$Latitude))
newdat$Longitude <- as.numeric(as.character(newdat$Longitude))
#Probably can be re-checked.
unique(newdat$Sex)
unique(newdat$Individuals) 
newdat$Male <- ifelse(newdat$Sex %in% c("M"), newdat$Individuals, 0)
newdat$Female <- ifelse(newdat$Sex %in% c("F", "Q"), newdat$Individuals, 0)
newdat$Worker <- ifelse(newdat$Sex %in% c("W"), newdat$Individuals, 0)
newdat$Not.specified <- ifelse(!newdat$Sex %in% c("W", "F", "Q", "M"), newdat$Individuals, 0)
compare_variables(check, newdat)
colnames(newdat)[which(colnames(newdat) == 'Published.by')] <- 'Authors.to.give.credit' 
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
#NOTE: some impossible lat longs may be recoverable. Also in Year. 
(temp <- extract_pieces(newdat$Species, species = TRUE))
newdat$Species <- temp$piece1
#Subspecies also needs cleaning!
#subsepecies
temp <- strsplit(x = as.character(newdat$Subspecies), split = " ")
length(temp) == length(newdat$Subspecies)
newdat$Subspecies <- as.character(newdat$Subspecies)
newdat$Subspecies[which(newdat$Subspecies == "")] <- NA
for (i in which(!is.na(newdat$Subspecies))){
  newdat$Subspecies[i] <- temp[[i]][3]
}
head(newdat)
newdat$Authors.to.give.credit <- "Compiled by MA Collado"
newdat <- add_uid(newdat = newdat, 'Lit')
summary(newdat)
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#Add MNCN-Apoidea-PAlvarez-MParis-----
help_template()
newdat <- read.csv(file = 'rawdata/csvs/43_Alvarez_etal.csv', sep = ";")
compare_variables(check, newdat)
newdat$Local_ID <- paste(newdat$Id, newdat$CodigoColeccion, newdat$nNoCatalogo, sep = "_")
#unique(newdat$UTM) #poca cosa
unique(newdat$Sex) #miedito el descontrol que hay
newdat$Female <- ifelse(newdat$Sex %in% c("hembra", "Hembra"), 1, 0)
newdat$Male <- ifelse(newdat$Sex %in% c("macho", "Macho"), 1, 0)
newdat$Worker <- ifelse(newdat$Sex %in% c("obrera"), 1, 0)
newdat$Not.specified <- ifelse(!newdat$Sex %in% c("obrera", "macho", "Macho", "hembra", "Hembra"), 1, 0)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat) 
unique(newdat$Month) #THIS CAN BE DEPURATED e.g. month 18
newdat$Authors.to.give.credit <- "compiled by P. Alvarez and M. Paris"
newdat <- add_uid(newdat = newdat, 'MNCN')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length


#Colletes Iberia MK 2020-10-11ADD_ONLY_ES_IM.csv----
#help_template()
newdat <- read.csv(file = 'rawdata/csvs/19_Kuhlmann_etal.csv', sep = ";")
compare_variables(check, newdat)
colnames(newdat)[which(colnames(newdat) == 'Coll....source')] <- 'Authors.to.give.credit' #Rename variables if needed
newdat$Genus <- "Colletes"
newdat <- add_missing_variables(check, newdat)
unique(newdat$Country)
newdat <- subset(newdat, Country == "SPAIN") #PT already in T. Wood compilation according to Luisa. Check?
help_geo()
newdat$Latitude <- parzer::parse_lat(as.character(newdat$Latitude))
newdat$Longitude <- parzer::parse_lon(as.character(newdat$Longitude))
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, 'MK')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#Add data Wood----
#DONE OLD STYLE without cleanR
newdat <- read.csv(file = "rawdata/csvs/54_Wood_etal.csv", sep = ";")
colnames(newdat)
summary(newdat)
unique(newdat$Species)
newdat$Genus <- NA
newdat$Subgenus <- NA
newdat$Subspecies <- NA
newdat$Species <- as.character(newdat$Species)
temp <- unlist(gregexpr(pattern = " (", fixed = TRUE, text = newdat$Species))
temp2 <- unlist(gregexpr(pattern = ")", fixed = TRUE, text = newdat$Species))
for(i in which(temp > 0)){
  newdat$Subgenus[i] <- substr(newdat$Species[i], start = temp[i]+2, 
                               stop = temp2[i]-1)
  newdat$Species[i] <- paste(substr(newdat$Species[i], start = 1, 
                            stop = temp[i]-1), 
                            substr(newdat$Species[i], start = temp2[i]+2, 
                                   stop = nchar(newdat$Species[i])))
}
temp <- strsplit(x = as.character(newdat$Species), split = " ")
#this is slow... 
for (i in 1:length(newdat$Species)){
  if(length(temp[[i]]) == 2){
    newdat$Genus[i] <- temp[[i]][1]
    newdat$Species[i] <- temp[[i]][2]
  }
  if(length(temp[[i]]) == 3){
    newdat$Genus[i] <- temp[[i]][1]
    newdat$Species[i] <- temp[[i]][2]
    newdat$Subspecies[i] <- temp[[i]][3]
  }
}
#clean subspecies withh #agg #s.l.
unique(newdat$Subspecies)
newdat$Species[which(newdat$Subspecies == "agg")] <- paste(newdat$Species[which(newdat$Subspecies == "agg")], 
                                                           "_agg", sep = "")
newdat$Subspecies[which(newdat$Subspecies == "agg")] <- NA
newdat$Species[which(newdat$Subspecies == "s.l.")] <- paste(newdat$Species[which(newdat$Subspecies == "s.l.")], 
                                                           "_s.l.", sep = "")
newdat$Species[which(newdat$Subspecies == "s.l.")] <- NA
#Now dates...
colnames(newdat)
levels(newdat$Start.date)[1:1000] #4/5/1983, 
levels(newdat$Start.date)[1001:2000] #4/5/1983, 
levels(newdat$Start.date)[2001:2800] #4/5/1983, + some errors
levels(newdat$Year.uncertainty) #move to notes?
newdat$Notes.and.queries <-newdat$Year.uncertainty 
levels(newdat$End.date.original)[1:1000] 
levels(newdat$End.date.original)[1001:2000] 
levels(newdat$End.date.original)[2001:3000] #Unitil here the End.date column is fixed manually...
levels(newdat$End.date.original)[3001:4000] 
levels(newdat$End.date.original)[4001:5000] 
levels(newdat$End.date.original)[5001:6000] 
levels(newdat$End.date.original)[6001:7000] 
levels(newdat$End.date.original)[7001:7500] 
#Festival: 12/31/1935, 12 - VI - 1970, 12 VIII 1968, 12 Febr. 1965
# 1-vii-1960, 18800614, 
#estrategia, separar los que tengan /, los que tengan letras, 
#los que sean solo numeros, etc...
newdat$End.date.original <- as.character(newdat$End.date.original)
numeric <- grep(pattern = "^[0-9]*$", x = newdat$End.date.original)
for(i in numeric){
  temp_year <- substr(newdat$End.date.original[i], start = 1,stop = 4)
  temp_month <- substr(newdat$End.date.original[i], start = 5,stop = 6)
  temp_day <- substr(newdat$End.date.original[i], start = 7,stop = 8)
  newdat$End.date.original[i] <- paste(temp_month, temp_day, temp_year, sep = "/")
}
newdat$End.date.original[numeric] #good, I recovered some...
temp <- as.POSIXlt(as.character(newdat$Start.date), format = "%m/%d/%Y") #extract month and day
newdat$month <- format(temp,"%m")
newdat$day <- format(temp,"%d")
colnames(newdat)
newdat$Authors.to.give.credit <- "Compiled by T. Wood"
#missing
#unique(newdat$Year.uncertainty) #few, maybe add to notes DONE
#unique(newdat$Source)  #Notes?
newdat$Notes.and.queries <- ifelse(is.na(newdat$Notes.and.queries), 
                                   newdat$Source, 
                                   paste(newdat$Notes.and.queries, newdat$Source, sep = "; "))
#unique(newdat$TRUSTED) #empty                                        
#unique(newdat$Link) #few, notes? 
newdat$Notes.and.queries <- ifelse(is.na(newdat$Notes.and.queries), 
                                   newdat$Link, 
                                   paste(newdat$Notes.and.queries, newdat$Link, sep = "; "))
unique(newdat$Identification.notes.and.queries)
newdat$Notes.and.queries <- ifelse(is.na(newdat$Notes.and.queries), 
                                   newdat$Identification.notes.and.queries, 
                                   paste(newdat$Notes.and.queries, newdat$Identification.notes.and.queries, sep = "; "))
newdat$uid <- paste("Wood_etal", 1:nrow(newdat), sep = "")
#unique(newdat$MONS) #ignore                                          
#unique(newdat$Authors) #empty
#unique(newdat$Pollen.collected) #cool, ignore for us.                               
#unique(newdat$Prey.host) #few
str(newdat)
newdat <- newdat[,c("Genus",
                    "Subgenus",
                    "Species",
                    "Subspecies",
                    "Country",
                    "Province",
                    "Locality",
                    "Latitude",
                    "Longitude",
                    "Coordinate.precision",
                    "Year",
                    "month",
                    "day",
                    "Start.date",
                    "End.date.original",
                    "Collector",
                    "Determiner",
                    "Female",
                    "Male",
                    "Worker",
                    "Not.specified",
                    "refbib", #?data_source
                    "Flowers.visited",
                    "Code",                 
                    "Authors.to.give.credit",
                    "Any.other.additional.data",
                    "Notes.and.queries",
                    "uid")]

#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
#trouble
unique(newdat$Locality)
newdat$Locality[12]
gsub("[^[:alnum:]]", "_", newdat$Locality[12])
newdat$Locality <- as.character(newdat$Locality)
newdat$Locality <- gsub("[^[:alnum:]]", "", newdat$Locality)
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#Add data internet----
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
newdat$uid <- paste("Internet", 1:nrow(newdat), sep = "")
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
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#test size matches----
data <- read.csv("data/data.csv") #Open in OpenOffice and substitute " by nothing. FIX!
#to fix:
#OTO2.194
#Collado, todo movido #fixed now? Creo que sí.
#Wood_etal27211
#Wood_etal27532
#MNCN3223
#MNCN3221
#G525
#G503
#G405
#G310
#JMG1109
#COv243 - COv254
head(data)
nrow(data) == size+1 
str(data)

temp <- table(data$Genus, data$Authors.to.give.credit)
table(data$Genus)
rownames(temp)
temp[49:50,]
#Vicente Martínez-López and Pilar De la Rúa 100
#Ainhoa Magrach 130
#Carlos Lara-Romero 350
#A. Núñez 500
#C. Ornosa 500 (Varios?)
#compiled by P. Alvarez and M. Paris 500
#JR Obeso 1500
#wood: 13560

#25468 total


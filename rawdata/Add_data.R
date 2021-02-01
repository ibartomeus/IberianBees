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

#read data.csv for comaprisions
#data <- read.csv("data/data.csv")
#colnames(data)
#head(data)

#Add data Montero----
newdat <- read.csv(file = "rawdata/csvs/AnaMontero.csv")
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("Montero", 1:nrow(newdat), sep = "")
colnames(newdat)
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24,28)]
#quick way to compare colnames
cbind(colnames(newdat) , colnames(data)) #can be merged
summary(newdat)
newdat$Authors.to.give.credit <- "Ana Montero-Castaño, Montserrat Vilà"
newdat$Genus <- as.character(newdat$Genus)
temp <- unlist(gregexpr(pattern = "_(", fixed = TRUE, text = newdat$Genus))
for(i in which(temp > 0)){
  newdat$Subgenus[i] <- substr(newdat$Genus[i], start = temp[i]+2, 
                                   stop = nchar(newdat$Genus[i])-1)
  newdat$Genus[i] <- substr(newdat$Genus[i], start = 1, 
                            stop = temp[i]-1)
}
#newdat$Reference..doi. several doi's listed "," and "and" separated. Fix later?
#questions flowers species with Genus_spcies -> accepted, easy to change in bulk. 
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
#keep track of expected length
size <- nrow(data) + nrow(newdat)

#Add data BAC ----
newdat <- read.csv(file = "rawdata/csvs/BAC.csv")
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("Arroyo", 1:nrow(newdat), sep = "")
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
newdat <- read.csv(file = "rawdata/csvs/Castro_FLOWERLAB.csv")
colnames(newdat)[10] <- "precision" #just to see them both in two lines
#quick way to compare colnames
newdat$uid <- paste("Castro", 1:nrow(newdat), sep = "")
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
newdat <- read.csv(file = "rawdata/csvs/IMEDEA_MALLORCA.csv")
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
newdat <- read.csv(file = "rawdata/csvs/JV.csv")
colnames(newdat)[9] <- "precision" #just to see them both in two lines
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$uid <- paste("Valverde", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,27,2:26,28)]
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
newdat$Start.date <- NA
newdat$End.Date <- NA
newdat$day #uses multiple days...
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
newdat <- read.csv(file = "rawdata/csvs/LaraRomero.csv")
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("Lara", 1:nrow(newdat), sep = "")
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
newdat <- read.csv(file = "rawdata/csvs/MartinezNunez.csv")
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("MartinezNunez", 1:nrow(newdat), sep = "")
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
newdat <- read.csv(file = "rawdata/csvs/MFM_JL.csv")
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("FernandezMazuecos", 1:nrow(newdat), sep = "")
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
newdat <- read.csv(file = "rawdata/csvs/Nunez.csv")
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("Nunez", 1:nrow(newdat), sep = "")
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
newdat <- read.csv(file = "rawdata/csvs/Ruben_heleno.csv")
colnames(newdat)
colnames(newdat)[9] <- "precision" #just to see them both in two lines
#subgenus missing.
newdat$Subgenus <- NA
newdat$uid <- paste("Heleno", 1:nrow(newdat), sep = "")
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
newdat <- read.csv(file = "rawdata/csvs/SERIDA.csv")
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
newdat <- read.csv(file = "rawdata/csvs/VFerrero.csv")
colnames(newdat)
colnames(newdat)[9] <- "precision"
#subgenus missing.
newdat$Subgenus <- NA
newdat$uid <- paste("Ferrero", 1:nrow(newdat), sep = "")
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
newdat <- read.csv(file = "rawdata/csvs/Carvalho_pool.csv")
colnames(newdat)
colnames(newdat)[10] <- "precision"
#quick way to compare colnames
newdat$uid <- paste("Carvalho", 1:nrow(newdat), sep = "")
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
newdat <- read.csv(file = "rawdata/csvs/vanapicanco.csv")
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
newdat$uid <- paste("Vanapicanco", 1:nrow(newdat), sep = "")
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
newdat <- read.csv(file = "rawdata/csvs/Magrach.csv")
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
newdat$uid <- paste("Magrach", 1:nrow(newdat), sep = "")
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

#Add historical data (Collado)----
newdat <- read.csv(file = "rawdata/csvs/Collado1.csv")
#not formated, so let's start here
summary(newdat)
colnames(newdat)
#day & month need checks
newdat$Subgenus <- NA
newdat$Startday <- NA
newdat$Endday <- NA
summary(newdat$sex)
summary(newdat$individuals)
newdat$individuals[which(newdat$individuals %in% c("", "M"))] <- 1
newdat$Female <- ifelse(newdat$sex %in% c("F", "Q"), newdat$individuals, 0)
newdat$Male <- ifelse(newdat$sex %in% c("M"), newdat$individuals, 0)
newdat$Worker <- ifelse(newdat$sex %in% c("W"), newdat$individuals, 0)
newdat$Not.specified <- ifelse(newdat$sex %in% c(""), newdat$individuals, 0)
#check UTM 
summary(newdat$UTM)
#library(rgdal)
#longlats <- spTransform(newdat$UTM, CRS("+proj=longlat")) #transform
###### WITH TIME; UTM's can be recovered. IGNORED FOR NOW!
unique(newdat$lat)
newdat$lat <- as.character(newdat$lat)
newdat$lat[which(newdat$lat %in% c("40.807867,"))] <- 40.807867
newdat$lat[which(newdat$lat %in% c(""))] <- NA
newdat$lat[which(newdat$lat %in% c("42.566667, 0.45"))] <- 42.566667
newdat$lat[which(newdat$lat %in% c("42.55, -0.55"))] <- 42.55
newdat$long <- as.character(newdat$long)
unique(newdat$long)
newdat$long[which(newdat$long %in% c("42.566667, 0.45"))] <- 0.45
newdat$long[which(newdat$long %in% c(""))] <- NA
newdat$long[which(newdat$long %in% c("42.55, -0.55"))] <- -0.55
unique(newdat$m_plant_species)
newdat$Plant_sp <- newdat$m_plant_species 
newdat$Authors.to.give.credit <- newdat$Author
newdat$Any.other.additional.data <- newdat$Published.by
#Species
newdat$species <- as.character(newdat$species)
temp <- strsplit(x = as.character(newdat$species), split = " ")
length(temp) == length(newdat$species)
for (i in 1:length(newdat$species)){
    newdat$species[i] <- temp[[i]][2]
}
head(newdat)
#subsepecies
temp <- strsplit(x = as.character(newdat$subspecies), split = " ")
length(temp) == length(newdat$subspecies)
newdat$subspecies <- as.character(newdat$subspecies)
newdat$subspecies[which(newdat$subspecies == "")] <- NA
for (i in which(!is.na(newdat$subspecies))){
  newdat$subspecies[i] <- temp[[i]][3]
}
head(newdat)
newdat$uid <- paste("Historical", 1:nrow(newdat), sep = "")
#remove sp.
newdat <- newdat[,c("genus",
                    "Subgenus",
                    "species",
                    "subspecies",
                    "country",
                    "Province",
                    "location",
                    "lat",
                    "long",
                    "Precision..GPS..1km.2km.....",
                    "year",
                    "month",
                    "day",
                    "Startday",
                    "Endday",
                    "collector",
                    "taxonomist",
                    "Female",
                    "Male",
                    "Worker",
                    "Not.specified",
                    "doi", 
                    "Plant_sp",
                    "local_id",                 
                    "Authors.to.give.credit",
                    "Any.other.additional.data",
                    "Notes",
                    "uid")]
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)  

#Add data Wood----
newdat <- read.csv(file = "rawdata/csvs/Wood_combined.csv")
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
levels(newdat$End.date.publication.date)[1:1000] 
levels(newdat$End.date.publication.date)[1001:2000] 
levels(newdat$End.date.publication.date)[2001:3000] 
levels(newdat$End.date.publication.date)[3001:4000] 
levels(newdat$End.date.publication.date)[4001:5000] 
levels(newdat$End.date.publication.date)[5001:6000] 
levels(newdat$End.date.publication.date)[6001:7000] 
levels(newdat$End.date.publication.date)[7001:7500] 
#Festival: 12/31/1935, 12 - VI - 1970, 12 VIII 1968, 12 Febr. 1965
# 1-vii-1960, 18800614, 
#estrategia, separar los que tengan /, los que tengan letras, 
#los que sean solo numeros, etc...
newdat$End.date.publication.date <- as.character(newdat$End.date.publication.date)
numeric <- grep(pattern = "^[0-9]*$", x = newdat$End.date.publication.date)
for(i in numeric){
  temp_year <- substr(newdat$End.date.publication.date[i], start = 1,stop = 4)
  temp_month <- substr(newdat$End.date.publication.date[i], start = 5,stop = 6)
  temp_day <- substr(newdat$End.date.publication.date[i], start = 7,stop = 8)
  newdat$End.date.publication.date[i] <- paste(temp_month, temp_day, temp_year, sep = "/")
}
newdat$End.date.publication.date[numeric] #good, I recovered some...
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
                    "Province..1936.",
                    "Locality",
                    "Latitude",
                    "Longitude",
                    "Coordinate.precision..e.g..GPS..uncert....10km.",
                    "Year",
                    "month",
                    "day",
                    "Start.date",
                    "End.date.publication.date",
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

#To ADD Obeso.----
#José R. Obeso, Paola Laiolo, Emilie Ploquin y José M. Herrera
#xls_to_add Roberts and de pablos

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
data <- read.csv("data/data.csv")
nrow(data) == size 
str(data)



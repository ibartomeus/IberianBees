# Template to Add new data.

#Create an empty data file. 
data <- matrix(ncol = 27, nrow = 1)
data <- as.data.frame(data)
colnames(data) <- c("Genus","Subgenus","Species","Subspecies",
                    "Country","Province","Locality",
                    "Latitude","Longitude","Coordinate.precision",
                    "Year","Month","Day","Start.date","End.date",
                    "Collector","Determined.by","Female","Male","Worker","Not.specified",
                    "Reference.doi","Flowers.visited","Local_ID","Authors.to.give.credit",
                    "Any.other.additional.data","Notes.and.queries")
head(data)
write.csv(data, "data/data.csv", row.names = FALSE)

#read data.csv for comaprisions
#data <- read.csv("data/data.csv")
#colnames(data)
#head(data)

#Add data Montero----
newdat <- read.csv(file = "rawdata/AnaMontero.csv")
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24)]
#quick way to compare colnames
cbind(colnames(newdat) , colnames(data)) #can be merged
summary(newdat)
newdat$Authors.to.give.credit <- "Ana Montero-Castaño, Montserrat Vilà"
#newdat$Reference..doi. several doi's listed "," and "and" separated. Fix later?
#questions flowers species with Genus_spcies -> accepted, easy to change in bulk. 
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
#keep track of expected length
size <- nrow(data) + nrow(newdat)

#Add data BAC ----
newdat <- read.csv(file = "rawdata/BAC.csv")
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24)]
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
newdat <- read.csv(file = "rawdata/Castro_FLOWERLAB.csv")
colnames(newdat)[10] <- "precision" #just to see them both in two lines
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
#question: España and Spain both used. Fix in bulk.
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#Add data IMEDEA ----
newdat <- read.csv(file = "rawdata/IMEDEA_MALLORCA.csv")
colnames(newdat)[9] <- "precision" #just to see them both in two lines
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
#reorder
newdat <- newdat[,c(1,30,2:29)]
#unify Authors.
newdat$Authors.to.give.credit0 <- paste(newdat$Authors.to.give.credit,
                                        newdat$Authors.to.give.credit.1,
                                        newdat$Authors.to.give.credit.2,
                                        newdat$Authors.to.give.credit.3, sep = ", ")
newdat <- newdat[,c(1:24,31,29,30)]
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#Add data JV ----
newdat <- read.csv(file = "rawdata/JV.csv")
colnames(newdat)[9] <- "precision" #just to see them both in two lines
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
#reorder
newdat <- newdat[,c(1,27,2:26)]
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
newdat <- read.csv(file = "rawdata/LaraRomero.csv")
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24)]#reorder
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
newdat <- read.csv(file = "rawdata/MartinezNunez.csv")
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24)]#reorder
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
newdat[131,4] <- NA
newdat$Authors.to.give.credit <- "Martínez-Núñez C., Rey P.J."
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#Add data MFM ----
newdat <- read.csv(file = "rawdata/MFM_JL.csv")
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24)]#reorder
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#Add data Nunez ----
newdat <- read.csv(file = "rawdata/Nunez.csv")
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24)]#reorder
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#Add data Heleno ----
newdat <- read.csv(file = "rawdata/Ruben_heleno.csv")
colnames(newdat)
colnames(newdat)[9] <- "precision" #just to see them both in two lines
#subgenus missing.
newdat$Subgenus <- NA
#reorder
newdat <- newdat[,c(1,27,2:26)]
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
newdat <- read.csv(file = "rawdata/SERIDA.csv")
colnames(newdat)
newdat$Notes.and.queries <- paste(newdat$Notes.and.queries, 
                                  newdat$Notes.and.queries..2., sep = ";")
unique(newdat$Notes.and.queries)
newdat <- newdat[,-25]
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24)]
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
newdat <- read.csv(file = "rawdata/VFerrero.csv")
colnames(newdat)
colnames(newdat)[9] <- "precision"
#subgenus missing.
newdat$Subgenus <- NA
#reorder
newdat <- newdat[,c(1,27,2:26)]
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
newdat$Latitude[61] <- 37.39836111111111
newdat$Latitude <- as.numeric(as.character(newdat$Latitude))
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#Add data Cavalho----
newdat <- read.csv(file = "rawdata/Carvalho_pool.csv")
colnames(newdat)
colnames(newdat)[10] <- "precision"
#quick way to compare colnames
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

#Add data Wood----
#newdat <- read.csv(file = "rawdata/Wood_Asher_Naturalis_20200313.csv")
#colnames(newdat)
#colnames(data)
#strat with a simpier one


#Add data internet----
newdat <- read.csv(file = "data/idata.csv")[,-1]
head(newdat)
#split genus species
newdat$Genus <- substr(newdat$species, 
                       start = 1,
                       stop = unlist(gregexpr(pattern = " ", newdat$species))-1)
newdat$species <- substr(newdat$species, 
                         start = unlist(gregexpr(pattern = " ", newdat$species))+1,
                         stop = nchar(as.character(newdat$species)))  
newdat$Collector <- newdat$recordedBy
levels(newdat$sex)
newdat$Female <- ifelse(newdat$sex %in% c("FEMALE", "female", "queen"), 1, 0)
newdat$Male <- ifelse(newdat$sex %in% c("MALE", "male"), 1, 0)
newdat$Worker <- ifelse(newdat$sex %in% c("worker"), 1, 0)
newdat$Not.specified <- ifelse(is.na(newdat$sex) | newdat$sex == "males_and_females", 1, 0)
colnames(data)
newdat$Subgenus <- NA
newdat$Country <- NA
newdat$Province <- NA
newdat$Locality <- NA
newdat$Coordinate.precision <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$Reference.doi <- NA
newdat$Flowers.visited <- NA
newdat$Local_ID <- NA
newdat$Authors.to.give.credit <- NA
newdat$Any.other.additional.data <- "Gbif or iNaturalist data"
newdat$Notes.and.queries <- NA
#reorder
colnames(data)
colnames(newdat)
newdat <- newdat[,c(12,18,1,11,19:21,2,3,22,5:7,23,24,8,9,14:17,25:30)]
cbind(colnames(newdat), colnames(data)) #can be merged
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#test size matches----
data <- read.csv("data/data.csv")
nrow(data) == size 

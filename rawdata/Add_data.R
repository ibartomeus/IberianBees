#####################################################################################--

#In this script the different unprocessed csvs from rawdata/csvs/
#are edited to match a default template and joined together

#####################################################################################--
#Set up----
#First create TEMPLATE to Add new data.
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
data <- read.csv("data/data.csv",stringsAsFactors=TRUE)
#colnames(data)
#head(data)

#Load functions NOW is manually done from cleaner repo
#devtools::install_github("RadicalCommEcol/CleanR")
library(cleanR)
check <- define_template(data, NA)

#Load library mgrs
#install.packages("remotes") #Install remotes if not installed
#remotes::install_gitlab("hrbrmstr/mgrs") #there are other alternatives in the repo for installation
library(dplyr)
library(tidyr) 

#####################################################################################--
#ADD DATA NOW
#####################################################################################--
# 1_Ornosa_etal ----

help_structure()
newdat <- read.csv(file = 'rawdata/csvs/1_Ornosa_etal.csv', sep = ";")
compare_variables(check, newdat)
(temp <- extract_date(newdat$Date, format_ = "%d-%m-%Y"))
newdat$Day <- temp$day
newdat$Month <- temp$month
newdat$Year <- temp$year
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Remove row with all NA's (just one) Has a 0 in the female column
#so cannot delete it easily by row
newdat <- newdat[-59,] #not elegant but is the easiest
#add identifier
newdat <- add_uid(newdat = newdat, '1_Ornosa_')
newdat$Authors.to.give.credit <- "C. Ornosa"
#Add two missing provinces
newdat$Province[newdat$Locality==
"Jaén. Sierra de Cazorla. Nacimiento del Guadalquivir"] <-"Jaén"
newdat$Province[newdat$Locality==
"Imlil"] <-"Al Haouz"

#Rename this cell to just the locality
newdat$Locality <- gsub("Jaén. Sierra de Cazorla. Nacimiento del Guadalquivir", 
"Sierra de Cazorla. Nacimiento del Guadalquivir", newdat$Locality)

#Rewrite countries in English
levels(factor(newdat$Country))
newdat$Country <- gsub("España", 
"Spain", newdat$Country, fixed=T)
newdat$Country <- gsub("Marruecos", 
"Morocco", newdat$Country, fixed=T)

#Fix collect. names. 
levels(factor(newdat$Collector)) 
# IML to IM Liberal
newdat$Collector <- gsub("IML", 
"I.M. Liberal", newdat$Collector)
#JL Blanco to J.L. Blanco
newdat$Collector <- gsub("JL Blanco", 
"J.L. Blanco", newdat$Collector)
#P Vargas to P. Vargas
newdat$Collector <- gsub("P Vargas", 
"P. Vargas", newdat$Collector)

#Fix identificator names. 
levels(factor(newdat$Determined.by))
#Replace front slash by a comma and a space
newdat$Determined.by <- gsub("JL Blanco/C. Ornosa", 
"JL Blanco, C. Ornosa", newdat$Determined.by)

write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', 
col.names = FALSE, row.names = FALSE, append = TRUE)
size <- nrow(newdat) #because is the first one!

#####################################################################################---
# 2_Ornosa_etal ----

help_structure()
newdat <- read.csv(file = 'rawdata/csvs/2_Ornosa_etal.csv', sep = ";")
compare_variables(check, newdat)
help_geo()
newdat$Latitude <- parzer::parse_lat(as.character(newdat$GPS))
newdat$Longitude <- parzer::parse_lon(as.character(newdat$GPS.1))
newdat$Authors.to.give.credit <- "C.Ornosa"
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Exclude rows that are NA in genus (full rows NA'S except some values)
newdat <- newdat[!is.na(newdat$Genus),]

#Fix countries (I do it in this way so we do not require any packages)
newdat$Country[newdat$Province=="Granada"] <- "España"
newdat$Country[newdat$Province=="Huesca"] <- "España"
newdat$Country[newdat$Province=="Gerona"] <- "España"
newdat$Country[newdat$Province=="Lérida"] <- "España"
newdat$Country[newdat$Province=="Pontevedra"] <- "España"
newdat$Country[newdat$Province=="Madrid"] <- "España"
newdat$Country[newdat$Province=="Segovia"] <- "España"
newdat$Country[newdat$Province=="Jaén"] <- "España"
newdat$Country[newdat$Province=="Zaragoza"] <- "España"
#seems ok now
#Rename countries in English
levels(factor(newdat$Country))
newdat$Country <- gsub("España", 
"Spain", newdat$Country, fixed = TRUE) 
newdat$Country <- gsub("Marruecos", 
"Morocco", newdat$Country, fixed = TRUE) 
newdat$Country <- gsub("Francia", 
"France", newdat$Country)

#Fix provinces (just the Spanish ones for now)
newdat$Province[newdat$Locality=="Moratalla"] <- "Murcia"

#Fix now dates, some years missing that can be filled from start and end date
#Extract year from strat.date column, store it another dataframe
year_d <- as.data.frame(format(as.Date(newdat$Start.date, format="%d-%m-%Y"),"%Y"))
colnames(year_d) <- "y" #New colname for simplicity
year_d$Year <- newdat$Year #Add new column (the year one from newdat)
#Workaround to fill missing years (needs Tydiverse)
year_d_1 <- data.frame(t(year_d)) %>% 
  fill(., names(.)) %>%
  t() %>% as.data.frame()
#Works well, add now the column back to the dataframe
newdat$Year <- year_d_1$Year
#Check levels, fix "   6", its year 2008
levels(factor(newdat$Year))
newdat$Year <- gsub("   6", 
"2008", newdat$Year)

#Now this process can be repeated by month
#Extract month from start.date column, store it another dataframe
month_d <- as.data.frame(format(as.Date(newdat$Start.date, format="%d-%m-%Y"),"%m"))
colnames(month_d) <- "m" #New colname for simplicity
#Add leading 0 to month column before merging
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
month_d$Month <- newdat$month #Add new column (the month one from newdat)

#Workaround to fill missing years (needs Tydiverse)
month_d_1 <- data.frame(t(month_d)) %>% 
  fill(., names(.)) %>%
  t() %>% as.data.frame()
#Works well, add now the column back to the dataframe
newdat$Month <- month_d_1$Month

#Check collector levels
levels(factor(newdat$Collector)) #they are a bit chaotic
#Lets unify a bit
newdat$Collector <- gsub("C. Onosa", 
"C. Ornosa", newdat$Collector)
newdat$Collector <- gsub("A. Glez.-Posada", 
"A. Glez-Posada", newdat$Collector)
newdat$Collector <- gsub("Pablo Vargas", 
"P. Vargas", newdat$Collector)
newdat$Collector <- gsub("P. Vargas (de M. Luceño)", 
"P. Vargas", newdat$Collector, fixed = TRUE) #because of the ñ, fixed=T
#Now looks a bit better

#Check detetermined.by levels
levels(factor(newdat$Determined.by)) 
newdat$Determined.by <- gsub("C. Onosa", 
                         "C. Ornosa", newdat$Determined.by)

#Add space to  credit author
levels(factor(newdat$Authors.to.give.credit))
newdat$Authors.to.give.credit <- gsub("C.Ornosa", 
"C. Ornosa", newdat$Authors.to.give.credit)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '2_Ornosa_')

write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', 
col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 3_Montero_etal ----

newdat <- read.csv(file = "rawdata/csvs/3_Montero_etal.csv")
#old template, subgenus, start and end date missing.

compare_variables(check, newdat)

#Rename variables
colnames(newdat)[which(colnames(newdat) ==
"Coordinate.precision..e.g..GPS...10km.")] <- "Coordinate.precision"
colnames(newdat)[which(colnames(newdat) ==
"Reference..doi.")] <- "Reference.doi"

#Check levels from Reference.doi
levels(factor(newdat$Reference.doi))
#One level has multiple DOI's in a single cell separated with ',' and with 'and'
#Let's make the separator a ',' for all cases
newdat$Reference.doi <- gsub(" and", ",", newdat$Reference.doi)
#Just show the oldest DOI for now for simplicity
#In this case is https://doi.org/10.1016/j.actao.2014.01.001
#As note, DOI 3 in level 2 levels(factor(newdat$Reference.doi)) 
#seems to link with an incorrect paper
#Extract just the first doi (the oldest)
newdat$Reference.doi <- sub(',.*$','', newdat$Reference.doi) 
#Check levels now
levels(factor(newdat$Reference.doi)) 
#It's correct, next!

newdat <- add_missing_variables(check, newdat)
#reorder and drop variables
newdat <- drop_variables(check, newdat)
#quick way to compare colnames
cbind(colnames(newdat) , colnames(data)) #can be merged
summary(newdat)
newdat$Authors.to.give.credit <- "Ana Montero-Castaño, Montserrat Vilà"
temp <- extract_pieces(newdat$Genus, subgenus = TRUE) 
newdat$Subgenus <- temp$piece1
newdat <- add_uid(newdat = newdat, "3_Montero_")

#Fix Genus
levels(factor(newdat$Genus)) #Erase everything after underscore
newdat$Genus <- gsub("\\_.*","",newdat$Genus) #Correct now

#Flowers visited, delete underscore, Genus_species to Genus species
newdat$Flowers.visited <- gsub("_", " ", newdat$Flowers.visited)

#Convert DOI to link
levels(factor(newdat$Reference.doi))
newdat$Reference.doi <- paste0("https://doi.org/",newdat$Reference.doi)
#Both links work

write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
#keep track of expected length
size <- size + nrow(newdat)

#####################################################################################---
# 4_Arroyo-Correa ----

#The following items are done before the functions were up and running.
newdat <- read.csv(file = "rawdata/csvs/4_Arroyo-Correa.csv")
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

write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#####################################################################################---
# 5_Banos-Picon_etal ----

help_structure()
newdat <- read.csv(file = 'rawdata/csvs/5_Banos-Picon_etal.csv')
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Fix coordinates, they are UTM
#Spain has zone 30, rgdal does the job but think in another package
#this was is being deleted from cran in 2023
library(rgdal) 
#provide coordinate format
utm <- SpatialPoints(cbind(newdat$Longitude, newdat$Latitude), 
        proj4string=CRS("+proj=utm +zone=30 +datume=WGS84 "))
#Convert to lon/lat
coord <- as.data.frame(spTransform(utm, 
CRS("+proj=longlat +datum=WGS84"))) #lon/lat
#Store back as lon/lat in the data
newdat$Longitude <- coord$coords.x1
newdat$Latitude <- coord$coords.x2

#Convert DOI to link
levels(factor(newdat$Reference.doi)) #annoying error in doi (classical excel one)
#Substitute all partial matches with the correct doi
newdat$Reference.doi[grepl("10.1016/j.baae", 
newdat$Reference.doi, ignore.case=FALSE)] <- "10.1016/j.baae.2012.12.008"
#Substitute all partial matches with the correct doi
newdat$Reference.doi[grepl("10.1111/ele.13", 
newdat$Reference.doi, ignore.case=FALSE)] <- "10.1111/ele.13265"
#Now seems right
#Convert to link format
newdat$Reference.doi <- paste0("https://doi.org/",
newdat$Reference.doi)
#Ugly but works, convert now "https://doi.org/NA" back to NA
newdat$Reference.doi <- gsub("https://doi.org/NA" , NA, newdat$Reference.doi)
#The four links work

#Add unique identifier
newdat <- add_uid(newdat = newdat, '5_Banos-Picon_')
write.table(x = newdat, file = 'data/data.csv', 
  quote = TRUE, sep = ',', col.names = FALSE, 
  row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 6_Moreira ----

help_structure()
newdat <- read.csv(file = 'rawdata/csvs/6_Moreira.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)

#Small edit on determined.by col
levels(factor(newdat$Determined.by))
newdat$Reference.doi <- gsub("T.J.Wood", "T.J. Wood", newdat$Reference.doi)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '6_Moreira_')

write.table(x = newdat, file = 'data/data.csv',
  quote = TRUE, sep = ',', col.names = FALSE, 
  row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 7_Ornosa ----

help_structure()
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

#Rename country
newdat$Country <- gsub("España", "Spain",newdat$Country, fixed=T)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '7_Ornosa_')
write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 8_Ornosa ----

help_structure()
newdat <- read.csv(file = 'rawdata/csvs/8_Ornosa.csv', sep = ";")
compare_variables(check, newdat)
help_geo()

#Fix coordinate before converting, it's giving an error
newdat$GPS..E. <- gsub('4º27310"', '4º27´310"', newdat$GPS..E.)
newdat$Latitude <- parzer::parse_lat(as.character(newdat$GPS..N.))
newdat$Longitude <- parzer::parse_lon(as.character(newdat$GPS..E.))

newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat$Authors.to.give.credit <- "C. Ornosa"

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)

# Rename country
newdat$Country <- gsub("España", "Spain", newdat$Country)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '8_Ornosa_')

#Erase empty genus and cell with Ácaros del 17_103 on genus
newdat <- newdat[!is.na(newdat$Genus),]
newdat <- newdat[newdat$Genus!="Ácaros del 17_103",]

write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 9_Ornosa ----

help_structure()
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

newdat$Province[newdat$Locality=="Picos de Europa"] <- "Asturias"

#Add unique identifier
newdat <- add_uid(newdat = newdat, '9_Ornosa_')
newdat$Authors.to.give.credit <- "C. Ornosa"

write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 10_Ornosa_etal ----

help_structure()
newdat <- read.csv(file = 'rawdata/csvs/10_Ornosa_etal.csv', sep=";")
compare_variables(check, newdat)
(temp <- extract_date(newdat$Date, "%d-%m-%Y"))
newdat$Day <- temp$day
newdat$Year <- temp$year
newdat$Month <- temp$month
newdat$Authors.to.give.credit <- "C. Ornosa"
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Rename country
newdat$Country <- gsub("España", "Spain", newdat$Country)

#This dataset has - in some cells instead of NA
newdat[newdat=="-"] <- NA

#add unique identifier
newdat <- add_uid(newdat = newdat, '10_Ornosa_etal_')

write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 11_Ornosa_etal ----

help_structure()
newdat <- read.csv(file = 'rawdata/csvs/11_Ornosa_etal.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
help_geo()

#Fix one coordinate
newdat$GPS..E. <- gsub("4º3'58\" N", "4º3'58\" W", newdat$GPS..E.)
#Another one, seems that is an extra 3 here
newdat$GPS..E. <- gsub("83º 30' 00\" W", "8º 30' 00\" W", newdat$GPS..E.)
#Convert to lat/lon
newdat$Latitude <- parzer::parse_lat(as.character(newdat$GPS..N.)) 
newdat$Longitude <- parzer::parse_lon(as.character(newdat$GPS..E.))
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Rename country
newdat$Country <- gsub("España", "Spain", newdat$Country)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Just 3 days that can be added, so I do it one by one
newdat$Year[newdat$Start.date=="02-08-2013"] <- "2013"
newdat$Month[newdat$Start.date=="02-08-2013"] <- "08"

#Change separator of forward slash to comma
levels(factor(newdat$Collector))
newdat$Collector <- gsub("\\/", ", ", newdat$Collector)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '11_Ornosa_etal_')

write.table(x = newdat, file = 'data/data.csv', 
      quote = TRUE, sep = ',', col.names = FALSE, 
      row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 12_Ornosa_etal ----

help_structure()
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

#Rename country
newdat$Country <- gsub("España", "Spain", newdat$Country)

#Change separator of forward slash to comma
levels(factor(newdat$Determined.by))
newdat$Determined.by <- gsub("\\/", ", ", newdat$Determined.by)
#Upper case all intial letters
newdat$Determined.by <- stringr::str_to_title(newdat$Determined.by)
newdat$Locality <- stringr::str_to_title(newdat$Locality)

#Delete leading space
newdat$Determined.by <- trimws(newdat$Determined.by, "l")

#Add unique identifier
newdat <- add_uid(newdat = newdat, '12_Ornosa_etal_')

write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 13_Gomez ----

help_structure()
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

#Fix some years
levels(factor(newdat$Year))
newdat$Year[newdat$Year=="Iberideae"] <- NA
#Some have two dates on them...
#Maybe just show one of them? 
#Just showing the fisrt one for now
newdat$Year <- sub("-.*", "", newdat$Year)

temp <- extract_pieces(newdat$GenSp, species = TRUE)
head(temp)
newdat$Genus <- temp$piece2  
temp <- extract_pieces(temp$piece1, species = TRUE)  
newdat$Species <-ifelse(!is.na(temp$piece2), temp$piece2, temp$to_split)
newdat$Subspecies <-ifelse(!is.na(temp$piece2), temp$piece1, temp$to_split)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Add country, all records seem that are from Spain
newdat$Country <- "Spain"

#Substitute underscore by space
newdat$Flowers.visited <- gsub("\\_", " ", newdat$Flowers.visited)

#Credit
newdat$Authors.to.give.credit <- "Compiled by J.M. Gomez"

#Add unique identifier
newdat <- add_uid(newdat = newdat, '13_Gomez_')

write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE,
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
#14_Marshall ----

help_structure()
newdat <- read.csv(file = 'rawdata/csvs/14_Marshall.csv', sep = ";")
compare_variables(check, newdat)
head(newdat)
newdat$Visitor <- as.factor(newdat$Visitor)
levels(newdat$Visitor)[11] <- "Bombus terrestris"
temp <- extract_pieces(newdat$Visitor, species = TRUE) 
newdat$Genus <- temp$piece2
newdat$Species <- temp$piece1
colnames(newdat)[which(colnames(newdat) == 'Plant')] <- 'Flowers.visited' #Rename variables if needed
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Add country name by coordinates 
#I have checked by coordinates that all points belong to France
#Here is the code, not added for simplicity
#https://stackoverflow.com/questions/14334970/convert-latitude-and-longitude-coordinates-to-country-name-in-r
newdat$Country <- "France"

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '14_Marshall_')

write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 15_Bartomeus_etal ----

help_structure()
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
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat$Authors.to.give.credit <- "I. Bartomeus"

#Clean NA's in genus
newdat <- newdat[!is.na(newdat$Genus),]

#Add DOI
newdat$Reference.doi <- "https://doi.org/10.1007/s00442-007-0946-1"
#LAT LONG CAN BE ADDED!

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '15_Bartomeus_etal_')

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

write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 16_Carvalho ----

newdat <- read.csv(file = "rawdata/csvs/16_Carvalho.csv")

colnames(newdat)
colnames(newdat)[10] <- "precision"

compare_variables(check, newdat)
#Rename variables 
colnames(newdat)[which(colnames(newdat) == 'day')] <- 'Day' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Reference..doi.')] <- 'Reference.doi' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'precision')] <- 'Coordinate.precision' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'End.Date')] <- 'End.date' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'COLLECTION')] <- 'Local_ID' #Rename variables if needed

newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop varia

#species includes genus
newdat$Species <- unlist(strsplit(x = as.character(newdat$Species),split = " "))[seq(2,108,2)]
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$Authors.to.give.credit <- "R. Carvalho, S. Castro, J. Loureiro"

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '16_Carvalho_')

#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#####################################################################################---
# 17_Carvalho ----
#newdat <- read.csv(file = "rawdata/csvs/17_Carvalho.csv")
#Is the same as 16_Carvalho, no need to add it
#####################################################################################---
# 18_Castro_etal ----

newdat <- read.csv(file = "rawdata/csvs/18_Castro_etal.csv")
colnames(newdat)[10] <- "precision" #just to see them both in two lines
#quick way to compare colnames
head(newdat)
newdat$uid <- paste("18_Castro_etal_", 1:nrow(newdat), sep = "")
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

#Rename country
newdat$Country <- gsub("España", "Spain", newdat$Country)

#Rename Collector
levels(factor(newdat$Collector))
newdat$Collector <- gsub("H.Gaspar", "H. Gaspar", newdat$Collector)
newdat$Collector <- gsub("H. Gaspar & P.Ferreira", 
"H. Gaspar, P.Ferreira", newdat$Collector)

write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#####################################################################################---
# 19_Kuhlmann_etal ----

#help_structure()
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
newdat <- add_uid(newdat = newdat, '19_Kuhlmann_etal_')

#Rename Country
newdat$Country <- gsub("SPAIN", "Spain", newdat$Country)

#Extract year and month and fill
#Fix now dates, some years missing that can be filled from start and end date
#Extract year from strat.date column, store it another dataframe
year_d <- as.data.frame(format(as.Date(newdat$Start.date, format="%d-%m-%Y"),"%Y"))
colnames(year_d) <- "y" #New colname for simplicity
year_d$Year <- newdat$Year #Add new column (the year one from newdat)
#Workaround to fill missing years (needs Tydiverse)
year_d_1 <- data.frame(t(year_d)) %>% 
  fill(., names(.)) %>%
  t() %>% as.data.frame()
#Works well, add now the column back to the dataframe
newdat$Year <- year_d_1$Year
#Check levels, fix "   6", its year 2008
levels(factor(newdat$Year))

#Now this process can be repeated by month
#Extract month from start.date column, store it another dataframe
month_d <- as.data.frame(format(as.Date(newdat$Start.date, format="%d-%m-%Y"),"%m"))
colnames(month_d) <- "m" #New colname for simplicity
#Add leading 0 to month column before merging
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
month_d$Month <- newdat$Month #Add new column (the month one from newdat)
#Workaround to fill missing years (needs Tydiverse)
month_d_1 <- data.frame(t(month_d)) %>% 
  fill(., names(.)) %>%
  t() %>% as.data.frame()
#Works well, add now the column back to the dataframe
newdat$Month <- month_d_1$Month

#The number of levels here is a bit crazy
#and maybe a bit repetitive
levels(factor(newdat$Authors.to.give.credit))
#just convert to lower case these ones
newdat$Authors.to.give.credit <- gsub("(NOSKIEWICZ 1936)", 
"Noskiewicz 1936", newdat$Authors.to.give.credit, fixed=T)
newdat$Authors.to.give.credit <- gsub("(RATHJEN 1998)",
"Rathjen 1998", newdat$Authors.to.give.credit, fixed=T)
newdat$Authors.to.give.credit <- gsub("(WARNCKE 1978)",
"Warncke 1978", newdat$Authors.to.give.credit, fixed=T)
newdat$Authors.to.give.credit <- gsub("(WESTRICH 1997)",
"Westrich 1997", newdat$Authors.to.give.credit, fixed=T)


write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 20_Gayubo ----

help_structure()
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

#Add country
newdat$Country <- "Spain"

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

newdat <- add_uid(newdat = newdat, '20_Gayubo_')
write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 21_Boieiro_etal ----

help_structure()
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
newdat <- add_uid(newdat = newdat, '21_Boieiro_etal_')

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Change separator to keep consistency
newdat$Collector <- gsub("\\ e", ",", newdat$Collector)
newdat$Determined.by <- gsub("\\ e", ",", newdat$Determined.by)
newdat$Authors.to.give.credit <- gsub("\\ e", ",", newdat$Authors.to.give.credit)

write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 22_Nunez ----

help_structure()
newdat <- read.csv(file = 'rawdata/csvs/22_Nunez.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Gsub, add space between name and surname
levels(factor(newdat$Collector))
newdat$Collector <- gsub("A.Núñez", 
"A. Núñez", newdat$Collector)
newdat$Collector <- gsub("D.Luna" , 
"D. Luna", newdat$Collector)
newdat$Collector <- gsub("M.Miñarro" , 
"M. Miñarro", newdat$Collector)
newdat$Collector <- gsub("R.Martínez" , 
"R. Martínez", newdat$Collector)
levels(factor(newdat$Determined.by))
newdat$Determined.by <- gsub("A.Núñez", 
"A. Núñez", newdat$Determined.by)
newdat$Determined.by <- gsub("C.Molina", 
"C. Molina", newdat$Determined.by)
newdat$Determined.by <- gsub("O.Aguado", 
"O. Aguado", newdat$Determined.by)

#Authors to give credit
newdat$Authors.to.give.credit <- "A. Núñez"

#Add unique identifier
newdat <- add_uid(newdat = newdat, '22_Nunez_')

write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 23_Costa ----

help_structure()
newdat <- read.csv(file = 'rawdata/csvs/23_Costa.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
#extract_pieces()
#help_geo()
#help_species()
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Convert moth to number
newdat$Month <- gsub("Agosto", "08", newdat$Month)
newdat$Month <- gsub("Marzo", "03", newdat$Month)
#Add leading 0 to month
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Convert to link format
newdat$Reference.doi <- paste0("https://doi.org/",
newdat$Reference.doi)
#Ugly but works, convert now "https://doi.org/NA" back to NA
newdat$Reference.doi <- gsub("https://doi.org/NA" , NA, newdat$Reference.doi)
#Both links work fine

#Add unique identifier
newdat <- add_uid(newdat = newdat, '23_Costa_')

write.table(x = newdat, file = 'data/data.csv', quote = TRUE, 
            sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
#24_Magrach ----

help_structure()
newdat <- read.csv(file = 'rawdata/csvs/24_Magrach.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '24_Magrach_')

write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 25_Trillo ----

help_structure()
newdat <- read.csv(file = 'rawdata/csvs/25_Trillo.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)
#Standardize separator
levels(factor(newdat$Determined.by))
newdat$Determined.by <- gsub("FJ Ortiz-Sánchez", 
"F.J. Ortiz-Sánchez",newdat$Determined.by)
newdat$Authors.to.give.credit <- gsub("A. Trillo, FJ Ortiz-Sánchez", 
"A. Trillo, F.J. Ortiz-Sánchez",newdat$Authors.to.give.credit)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '25_Trillo_')

write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 26_Ornosa_etal ----
#(Old file name Vicente Martínez-López, maybe rename to Martinez?) 

help_structure()
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

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Change separator
newdat$Determined.by <- gsub("\\ y", ",", newdat$Determined.by)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '26_Ornosa_etal_')

write.table(x = newdat, file = 'data/data.csv', 
      quote = TRUE, sep = ',', col.names = FALSE,
      row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 27_Azpiazu_etal ----

help_structure()
newdat <- read.csv(file = 'rawdata/csvs/27_Azpiazu_etal.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Standardize separation in names
newdat$Determined.by <- gsub("J.Ortiz", 
"J. Ortiz", newdat$Determined.by)

#Convert to link format
newdat$Reference.doi <- paste0("https://doi.org/",
newdat$Reference.doi)
#Ugly but works, convert now "https://doi.org/NA" back to NA
newdat$Reference.doi <- gsub("https://doi.org/NA" , NA, newdat$Reference.doi)
#DOI works fine

#Add unique identifier
newdat <- add_uid(newdat = newdat, '27_Azpiazu_etal_')

write.table(x = newdat, file = 'data/data.csv', 
            quote = TRUE, sep = ',', col.names = FALSE, 
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 28_Roberts.csv ----

help_structure()
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

#Rename country
newdat$Country <- gsub("SPAIN", "Spain", newdat$Country)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '28_Roberts_')

write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 29_Hormaza_etal  ----

help_structure()
newdat <- read.csv(file = 'rawdata/csvs/29_Hormaza_etal.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Few values are missing and seem the same of the rest of the columns
newdat$Country <- "Spain"
newdat$Province <- "Malaga"
newdat$Locality <- "Algarrobo"
newdat$Latitude <- 36.759
newdat$Longitude <- -4.04
newdat$Year <- 2018
newdat$Month <- 04
newdat$Collector <- "O. Aguado"
newdat$Determined.by <- "O. Aguado"
newdat$Authors.to.give.credit <- "O. Aguado, J.I. Hormaza, M.L. Alcaraz, V. Ferrero"

#Delete row with NA in genus
newdat <- newdat[!is.na(newdat$Genus),]

#Add unique identifier
newdat <- add_uid(newdat = newdat, '29_Hormaza_etal_')

write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 30_Lazaro_etal  ----

newdat <- read.csv(file = "rawdata/csvs/30_Lazaro_etal.csv")
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

#Rename
levels(factor(newdat$Collector))
newdat$Collector <- gsub("M. A. González-Estévez (M. A. G. Estvz)",
"M. A. González-Estévez",newdat$Collector, fixed=T)

write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)
#####################################################################################---
# 31_Diaz-Calafat  ----

help_structure()
newdat <- read.csv(file = 'rawdata/csvs/31_Diaz-Calafat.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '31_Diaz-Calafat_')

write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 32_Valverde  ----

newdat <- read.csv(file = "rawdata/csvs/32_Valverde.csv")
colnames(newdat)[9] <- "precision" #just to see them both in two lines
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$uid <- paste("32_Valverde_", 1:nrow(newdat), sep = "")
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

#Check variables
compare_variables(check, newdat)
#Rename cols
colnames(newdat)[which(colnames(newdat) == 'precision')] <- 'Coordinate.precision' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'day')] <- 'Day' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'End.Date')] <- 'End.date' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Reference..doi.')] <- 'Reference.doi' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Collection.Location_ID')] <- 'Local_ID' #Rename variables if needed

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Standardize separator
newdat$Determined.by <- gsub("\\ /", ",", newdat$Determined.by)

#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#####################################################################################---
# 33_Lara-Romero_etal  ----

newdat <- read.csv(file = "rawdata/csvs/33_Lara-Romero_etal.csv")
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("33_Lara-Romero_etal_", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24,28)]#reorder
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
newdat$Reference..doi. <- "https://doi.org/10.1111/1365-2435.12719" #I assume a single paper

#Check variables
compare_variables(check, newdat)
colnames(newdat)[which(colnames(newdat) == 'Coordinate.precision..e.g..GPS...10km.')] <- 'Coordinate.precision' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'month')] <- 'Month' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'day')] <- 'Day' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Reference..doi.')] <- 'Reference.doi' #Rename variables if needed

#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#####################################################################################---
# 34_dePablos  ----

help_structure()
newdat <- read.csv('rawdata/csvs/34_dePablos.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
#extract_pieces()
#help_geo()
#help_species()
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Convert months to numbers
newdat$Month <- match(newdat$Month, month.name)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Add unique identificator
newdat <- add_uid(newdat = newdat, '34_dePablos_')

write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 35_Magrach  ----

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
newdat$uid <- paste("35_Magrach_", 1:nrow(newdat), sep = "")
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

#Check colnames and rename
compare_variables(check, newdat)
colnames(newdat)[which(colnames(newdat) == 'pollinator_genus')] <- 'Genus' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'pollinator_species')] <- 'Species' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'country')] <- 'Country' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'site_id')] <- 'Locality' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'latitude')] <- 'Latitude' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'longitude')] <- 'Longitude' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'year')] <- 'Year' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'month')] <- 'Month' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'day')] <- 'Day' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Startday')] <- 'Start.date' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Endday')] <- 'End.date' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Endday')] <- 'End.date' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Det')] <- 'Determined.by' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Plant_sp')] <- 'Flowers.visited' #Rename variables if needed
newdat <- drop_variables(check, newdat) #reorder and drop variables

#Fix dot
newdat$Collector <- gsub("Juan. P. Gonzalez-Varo", "Juan P. Gonzalez-Varo",
newdat$Collector)

#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#####################################################################################---
# 36_Nunez  ----

newdat <- read.csv(file = "rawdata/csvs/36_Nunez.csv")
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("36_Nunez_", 1:nrow(newdat), sep = "")
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

compare_variables(check, newdat)
#Rename variables
colnames(newdat)[which(colnames(newdat) == 'Coordinate.precision..e.g..GPS...10km.')] <- 'Coordinate.precision' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'month')] <- 'Month' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'day')] <- 'Day' #Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Reference..doi.')] <- 'Reference.doi' #Rename variables if needed

#Rename as others
newdat$Collector <- gsub("Martínez-Núñez C.",
"C. Martínez-Núñez", newdat$Collector)
newdat$Determined.by <- gsub("Martínez-Núñez C.",
"C. Martínez-Núñez", newdat$Determined.by)
newdat$Authors.to.give.credit <- gsub("Martínez-Núñez C., Rey P.J.",
"C. Martínez-Núñez, P.J. Rey", newdat$Authors.to.give.credit)

#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#####################################################################################---
# 37_Ortiz_etal  ----

help_structure()
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
newdat$Authors.to.give.credit <- "J. Ortiz, C. Ornosa, F. Torres"
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Rename country
newdat$Country <- gsub("España", "Spain", newdat$Country)
#Delete extra spaces
newdat$Locality <- gsub("El Raso.   Agoncillo" , 
"El Raso. Agoncillo" , newdat$Locality)
newdat$Locality <- gsub("Hayedo.       Ventosa" , 
"Hayedo. Ventosa" , newdat$Locality)
newdat$Locality <- gsub("La Tejera.    San Asensio" , 
"La Tejera. San Asensio" , newdat$Locality)
newdat$Locality <- gsub("Las Arenillas.    San Asensio" , 
"Las Arenillas. San Asensio" , newdat$Locality)
newdat$Locality <- gsub("Ribarrey.       Cenicero" , 
"Ribarrey. Cenicero" , newdat$Locality)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Delete extra spaces
newdat$Collector <- gsub("J.  Bosch"  , 
"J. Bosch"  , newdat$Collector)
#Fix this level
newdat$Collector <- gsub("673"  , 
NA  , newdat$Collector)
#Rename levels
newdat$Determined.by <- gsub("Bosch/ Ornosa"  , 
"J. Bosch, C. Ornosa"  , newdat$Determined.by)
newdat$Determined.by <- gsub("Torres/Ornosa"  , 
"Torres, Ornosa"  , newdat$Determined.by)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '37_Ortiz_etal_')
write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 38_Ortiz_etal  ----

help_structure()
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
newdat$Authors.to.give.credit <- "J. Ortiz, F. Torres, C. Ornosa"
newdat <- add_uid(newdat = newdat, '38_Ortiz_etal_')

#Rename country
newdat$Country <- gsub("España", "Spain", newdat$Country)
#Fix province
newdat$Province <- gsub("Á06la", "Ávila", newdat$Province)
newdat$Province <- gsub("Sego06a", "Segovia", newdat$Province)
newdat$Province <- gsub("Albacetel", "Albacete", newdat$Province)
newdat$Province <- gsub("Lérida", "Lleida", newdat$Province)
newdat$Province <- gsub("Sierra Gádor", "Almería", newdat$Province)
#Fix localities
levels(factor(newdat$Locality))
newdat$Locality <- gsub("Cortijo de la Cruz. Dalías", 
"Sierra Gádor. Cortijo de la Cruz. Dalías", newdat$Locality)
newdat$Locality <- gsub("\\006", 
"vi", newdat$Locality)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Standardize collectors
newdat$Collector <- gsub("A  Vázquez", "A. Vázquez", newdat$Collector)
newdat$Collector <- gsub("C. Ornosa/F Torres", "C. Ornosa, F. Torres", newdat$Collector  )
newdat$Collector <- gsub("E  Manzano", "E. Manzano", newdat$Collector)
newdat$Collector <- gsub("P. Vargas/JL Blanco", "P. Vargas, J.L. Blanco", newdat$Collector  )
newdat$Collector <- gsub("Pablo Vargas", "P. Vargas", newdat$Collector  )
newdat$Collector <- gsub("Jesús Gomez", "J. Gomez", newdat$Collector  )
#Standardize determined.by
newdat$Determined.by <- gsub("C Ornosa", "C. Ornosa", newdat$Determined.by)
newdat$Determined.by <- gsub("F. Torres/ C. Ornosa", "F. Torres, C. Ornosa", newdat$Determined.by)
newdat$Determined.by <- gsub("J.  Ortiz", "J. Ortiz", newdat$Determined.by)
newdat$Determined.by <- gsub("J. Ortiz/C. Ornosa", "J. Ortiz, C. Ornosa", newdat$Determined.by)
newdat$Determined.by <- gsub("Félix Torres", "F. Torres", newdat$Determined.by)
levels(factor(newdat$Authors.to.give.credit))

write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 39_Ortiz_etal  ----

help_structure()
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
newdat$Authors.to.give.credit <- "J. Ortiz, F. Torres, C. Ornosa"

#Rename countries
newdat$Country <- gsub("España", "Spain", newdat$Country)
newdat$Country <- gsub("Francia", "France", newdat$Country)
#Trailing space province
newdat$Province <- trimws(newdat$Province, "r")
newdat$Locality <- trimws(newdat$Locality, "r")

#Standardize collectors
newdat$Collector <- gsub("A. Glez.-Posada", "A. Glez-Posada", newdat$Collector)
newdat$Collector <- gsub("A. López /C. Ornosa", "A. López, C. Ornosa", newdat$Collector)
#Standardize determined.by
newdat$Determined.by <- gsub("J  Ortiz", "J. Ortiz", newdat$Determined.by)
newdat$Determined.by <- gsub("J. Ortiz/C. Ornosa", "J. Ortiz, C. Ornosa", newdat$Determined.by)
newdat$Determined.by <- gsub("F Torres", "F. Torres", newdat$Determined.by)
newdat$Determined.by[newdat$Determined.by==" "] <- NA
levels(factor(newdat$Determined.by))

newdat <- add_uid(newdat = newdat, '39_Ortiz_etal_')
write.table(x = newdat, file = 'data/data.csv',
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 40_Gonzalez  ----

help_structure()
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

#Rename country
newdat$Country <- gsub("España", "Spain", newdat$Country)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '40_Gonzalez_')

write.table(x = newdat, file = 'data/data.csv',
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 41_Torres  ----

help_structure()
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

#Drop cells with NA in genus
newdat <- newdat[!is.na(newdat$Genus),]
#Rename country
newdat$Country <- "Spain"
newdat$Country[newdat$Province=="Portugal"] <- "Portugal"
#Fill missing province
newdat$Province[newdat$Locality=="Piquera de San Esteban"] <- "Soria"

#Fix space in collector
newdat$Collector <- gsub("F.Torres", "F. Torres", newdat$Collector)
#Fix space in determined by
newdat$Determined.by <- gsub("F.Torres", "F. Torres", newdat$Determined.by)
newdat$Determined.by <- gsub("Torres/Ornosa", "F. Torres, C. Ornosa", newdat$Determined.by)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '41_Torres_')

write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 42_Ornosa_etal  ----

newdat <- read.csv(file = "rawdata/csvs/42_Ornosa_etal.csv")
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("42_Ornosa_etal_", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24,28)]#reorder
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)

compare_variables(check, newdat)
#Rename colnames
colnames(newdat)[which(colnames(newdat)=="Coordinate.precision..e.g..GPS...10km.")] <- "Coordinate.precision"
colnames(newdat)[which(colnames(newdat)=="month")] <- "Month"
colnames(newdat)[which(colnames(newdat)=="day")] <- "Day"
colnames(newdat)[which(colnames(newdat)=="Determiner")] <- "Determined.by"
colnames(newdat)[which(colnames(newdat)=="Reference..doi.")] <- "Reference.doi"
newdat <- drop_variables(check, newdat) #reorder and drop variables

#Convert month to numeric
newdat$Month <- match(newdat$Month, month.name)
#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Change separator in collector
newdat$Collector <- gsub("\\ &", ",", newdat$Collector)

#Fix DOI with extra dot
newdat$Reference.doi <- gsub("https://doi.org/10/f3pm57.",
     "https://doi.org/10/f3pm57", newdat$Reference.doi)
#All DOI'S work fine now

#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#####################################################################################---
# 43_Alvarez_etal  ----
 
help_structure()
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
unique(newdat$Month) 

#Rename country
newdat$Country <- gsub("España", "Spain", newdat$Country)
#Fill quickly provinces
#na_check <- newdat[is.na(newdat$Province),]
newdat$Province[newdat$Locality=="Sierra de Guadarrama"] <- "Madrid"
newdat$Province[newdat$Locality=="Sierra de Guadarram"] <- "Madrid"
newdat$Province[newdat$Locality=="Alberche"] <- "Ávila"
newdat$Province[newdat$Locality=="Sierra Nevada"] <- "Granada"

#Fix some dates
newdat$Year <- gsub("129i", "1921", newdat$Year)
newdat$Year <- gsub("192i[sic]", "1921", newdat$Year, fixed = T)
newdat$Year <- gsub("1279[sic]", "1927", newdat$Year, fixed = T)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Unify some collector names
levels(factor(newdat$Collector))
newdat$Collector <- gsub("\\[", "", newdat$Collector)
newdat$Collector <- gsub("\\]", "", newdat$Collector)
newdat$Collector <- gsub("A. H. Hamm.", "A.H. Hamm", newdat$Collector)
newdat$Collector <- gsub("A.H. Hamm.", "A.H. Hamm", newdat$Collector)
newdat$Collector <- gsub("A. H. Hamm", "A.H. Hamm", newdat$Collector)
newdat$Collector <- gsub("Á. Schmidt", "A. Schmidt", newdat$Collector)
newdat$Collector <- sub("C. Bol.", "C. Bolívar", newdat$Collector, ignore.case = TRUE)
newdat$Collector <- sub("C. Bolívarvar", "C. Bolívar", newdat$Collector, ignore.case = TRUE)
newdat$Collector <- sub("Bolivar", "C. Bolívar", newdat$Collector, ignore.case = TRUE)
newdat$Collector <- sub("Bolívar", "C. Bolívar", newdat$Collector, ignore.case = TRUE)
newdat$Collector <- sub("C. C. Bolívar", "C. Bolívar", newdat$Collector, ignore.case = TRUE)
newdat$Collector <- sub("AntiAntiga", "Antiga", newdat$Collector, ignore.case = TRUE)
newdat$Collector <- sub("Andreu", "Andréu", newdat$Collector, ignore.case = TRUE)
newdat$Collector <- sub("Nieves&Rey", "Nieves & Rey", newdat$Collector, ignore.case = TRUE)

#Messy but works
newdat$Collector <- gsub("Antiga d? J. Pérez", "Antiga d. J. Pérez", newdat$Collector, fixed=T)
newdat$Collector <- gsub("Antiga d. J. Perez", "Antiga d. J. Pérez", newdat$Collector, fixed=T)
newdat$Collector <- gsub("Antiga dº J. Perez", "Antiga d. J. Pérez", newdat$Collector, fixed=T)
newdat$Collector <- gsub("Antiga do J. Pérez", "Antiga d. J. Pérez", newdat$Collector, fixed=T)
newdat$Collector <- gsub("Antiga d. Pérez", "Antiga d. J. Pérez", newdat$Collector, fixed=T)
newdat$Collector <- gsub("Antiga Pérez d.", "Antiga d. J. Pérez", newdat$Collector, fixed=T)
newdat$Collector[grepl("Exp. De", newdat$Collector, ignore.case=FALSE)] <- "Exp. del Museo"
newdat$Collector <- gsub("Exp. Museo", "Exp. del Museo", newdat$Collector, fixed=T)
newdat$Collector[grepl("Exp. Ins", newdat$Collector, ignore.case=FALSE)] <- "Exp. Inst. de Entomología"
newdat$Collector[grepl("Exp. Ins", newdat$Collector, ignore.case=FALSE)] <- "Exp. Inst. de Entomología"
newdat$Collector <- gsub("Fermin Z. Cervera", "Fermín Z. Cervera", newdat$Collector, fixed=T)
newdat$Collector <- gsub("F. Escalera", "F.M. Escalera", newdat$Collector, fixed=T)
newdat$Collector <- gsub("F. M. Escalera", "F.M. Escalera", newdat$Collector, fixed=T)
newdat$Collector <- gsub("F. M.Escalera", "F.M. Escalera", newdat$Collector, fixed=T)
newdat$Collector[grepl("Giner", newdat$Collector, ignore.case=FALSE)] <- "Giner Marí"
newdat$Collector <- gsub("Gª. Varela", "G. Varela", newdat$Collector, fixed=T)
newdat$Collector <- gsub("Gª Mercet", "G. Mercet", newdat$Collector, fixed=T)
newdat$Collector <- gsub(". Alvarez", "J. Álvarez", newdat$Collector, fixed=T)
newdat$Collector <- gsub("J. Mª de la Fuente", "J. M. de la Fuente", newdat$Collector, fixed=T)
newdat$Collector <- gsub("JJ. Álvarez", "J. Álvarez", newdat$Collector, fixed=T)
newdat$Collector <- gsub("R. P. L Navás", "R.P.L. Navás", newdat$Collector, fixed=T)
newdat$Collector <- gsub("R.P.L. Navas", "R.P.L. Navás", newdat$Collector, fixed=T)
newdat$Collector <- gsub("F. Z. Cervera", "F.Z. Cervera", newdat$Collector, fixed=T)
newdat$Collector <- gsub("H. H. Hamm.", "H.H. Hamm", newdat$Collector)
newdat$Collector <- gsub("J. B. de Quiros", "J.B. de Quiros", newdat$Collector)
newdat$Collector <- gsub("J. M. Benedito", "J.M. Benedito", newdat$Collector)
newdat$Collector <- gsub("J. M. de la Fuente", "J.M. de la Fuente", newdat$Collector)
newdat$Collector <- gsub("J. M. Dusmet", "J.M. Dusmet", newdat$Collector)

#A bit cleaner now
newdat$Determined.by <- gsub("\\[", "", newdat$Determined.by)
newdat$Determined.by <- gsub("\\]", "", newdat$Determined.by)

#Now determined by. column
levels(factor(newdat$Determined.by))
newdat$Determined.by <- gsub("C. Oenosa",  "C. Ornosa", newdat$Determined.by)
newdat$Determined.by <- gsub("C. ornosa",  "C. Ornosa", newdat$Determined.by)
newdat$Determined.by <- gsub("Luís Oscar Aguado",  "L.O. Aguado", newdat$Determined.by)
newdat$Determined.by <- gsub("Luís Oscar Aguado",  "L.O. Aguado", newdat$Determined.by)
newdat$Determined.by <- gsub("F. J. Ortíz",  "F. J. Ortiz Sánchez", newdat$Determined.by)
newdat$Determined.by <- gsub("F. J. Ortiz Sánchez",  "F.J. Ortiz Sánchez", newdat$Determined.by)
newdat$Determined.by <- gsub("H. H. Dathe",  "H.H. Dathe", newdat$Determined.by)

#Work on dates (e.g.,months>12)
newdat$Month[newdat$Start.date=="13-08-1944"] <- "08"
newdat$Month[newdat$Start.date=="13-07-1985"] <- "07"
newdat$Month[newdat$Month=="18"] <- "07"

newdat$Authors.to.give.credit <- "P. Alvarez, M. Paris"

#Add unique identifier
newdat <- add_uid(newdat = newdat, '43_Alvarez_etal_')
write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 44_Ornosa  ----

help_structure()
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

#Rename country
newdat$Country <- gsub("España", "Spain", newdat$Country)

#Change separator in collector column
newdat$Collector <- gsub("\\/", ", ", newdat$Collector)

#Add author to give credit
newdat$Authors.to.give.credit <- "C. Ornosa"

#Add unique identifier
newdat <- add_uid(newdat = newdat, '44_Ornosa_')

write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 45_Nunez  ----

newdat <- read.csv(file = "rawdata/csvs/45_Nunez.csv")
colnames(newdat)
#old template, subgenus, start and end date missing.
newdat$Subgenus <- NA
newdat$Start.date <- NA
newdat$End.date <- NA
newdat$uid <- paste("45_Nunez_", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24,28)]#reorder
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)

#Rename variables
compare_variables(check, newdat)
colnames(newdat)[which(colnames(newdat)=="month")] <- "Month"
colnames(newdat)[which(colnames(newdat)=="day")] <- "Day"
colnames(newdat)[which(colnames(newdat)=="Reference..doi.")] <- "Reference.doi"
colnames(newdat)[which(colnames(newdat)=="Coordinate.precision..e.g..GPS...10km.")] <- "Coordinate.precision"
newdat <- drop_variables(check, newdat) #reorder and drop variables

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Add space after dot in collector and determined.by
levels(factor(newdat$Collector))
newdat$Collector <- gsub("\\.", ". ", newdat$Collector)
newdat$Determined.by <- gsub("\\.", ". ", newdat$Determined.by)

#Add author to give credit
newdat$Authors.to.give.credit <- "A. Núñez"

#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#####################################################################################---
# 46_Obeso  ----

#help_structure()
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

write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE,
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 47_Collado_etal  ----

help_structure()
newdat <- read.csv(file = "rawdata/csvs/47_Collado_etal.csv", sep = ";")
compare_variables(check, newdat)
colnames(newdat)[which(colnames(newdat) == 'Local_id')] <- 'Local_ID' #Rename variables if needed"
colnames(newdat)[which(colnames(newdat) == 'collector')] <- 'Collector' #Rename variables if needed"
colnames(newdat)[which(colnames(newdat) == 'taxonomist')] <- 'Determined.by' #Rename variables if needed"
colnames(newdat)[which(colnames(newdat) == 'm_plant_species')] <- 'Flowers.visited' 
colnames(newdat)[which(colnames(newdat) == 'Location')] <- 'Locality' 

#Recover some more coordinates
#There are two types mgrs and utm
#mgrs seems straightforward
temp <- mgrs::mgrs_to_latlng(as.character(newdat$UTM))
#Now lets fill the missing values in lat/lon with these values
lat_d <- as.data.frame(temp$lat)
lon_d <- as.data.frame(temp$lng)
colnames(lat_d) <- "l" #New colname for simplicity
colnames(lon_d) <- "l" #New colname for simplicity
#store cols
lat_d$lat <- newdat$Latitude
lon_d$lon <- newdat$Longitude
#Workaround to fill missing lat  and lon (needs Tydiverse)
lat_d_1 <- data.frame(t(lat_d)) %>% 
  fill(., names(.)) %>%
  t() %>% as.data.frame()

lon_d_1 <- data.frame(t(lon_d)) %>% 
  fill(., names(.)) %>%
  t() %>% as.data.frame()
#Takes a bit of time
#Works well, add now the column back to the dataframe
newdat$Latitude <- lat_d_1$lat 
newdat$Longitude <- lon_d_1$lon 

#check now how to work with the UTM ones
library(stringr)
library(dplyr)
levels(factor(newdat$UTM))
temp <- newdat %>%filter(str_detect(UTM, 
c("29S ","29T ", "30T ", "31S ", "31T ")))
#Just 2 records to fill... 
#I do it manually by record
#30T 	4656952 308856
#31T 4684106 431397
c_1 <- mgrs::utm_to_latlng(29, "N", 308856, 4656952)
c_2 <- mgrs::utm_to_latlng(29, "N", 431397, 4684106)
#Coordinate utm 1
newdat$Latitude[newdat$UTM=="30T 	4656952 308856"] <- c_1[1]
newdat$Longitude[newdat$UTM=="30T 	4656952 308856"] <- c_1[2]
#Coordinate utm 2
newdat$Latitude[newdat$UTM=="31T 4684106 431397"] <- c_2[1]
newdat$Longitude[newdat$UTM=="31T 4684106 431397"] <- c_2[2]

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

#Fix some impossible coordinates manually
newdat$Latitude[newdat$Latitude==41745.00000] <- 41.745 #Rabano de aliste
newdat$Latitude[newdat$Latitude==43517.00000] <- 43.517 #mondigo
newdat$Longitude[newdat$Longitude==-7133.0000000] <- -7.133 #mondigo
newdat$Latitude[newdat$Latitude==41499.00000] <- 41.499 #Teyà
newdat$Longitude[newdat$Longitude==2324.0000000] <- 2.324 
newdat$Latitude[newdat$Latitude==41393.00000] <- 41.393 
newdat$Latitude[newdat$Latitude==40568.00000] <- 40.568 
newdat$Longitude[newdat$Longitude==-5385.000000] <- -5.385 #Fuentelapeña

#Still two coordenates seem incorrect
#[1] "6.4550575"  (lagos)      "9.9949634" (huesca)
#Fix manually
levels(factor(newdat$Latitude))
newdat$Latitude[newdat$Latitude=="6.4550575"] <- "37.1028"
newdat$Longitude[newdat$Latitude=="37.1028"] <- "-8.67422"
newdat$Latitude[newdat$Latitude=="9.9949634"] <- "42.6287"
newdat$Longitude[newdat$Latitude=="42.6287"] <- "-0.1127"
#Now looks good to me

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
newdat$Authors.to.give.credit <- "Compiled by M.A. Collado"
newdat <- add_uid(newdat = newdat, '47_Collado_etal_')
summary(newdat)

#Check levels
levels(factor(newdat$Province))
newdat$Province[which(newdat$Province %in% c(""))] <- NA
newdat$Province[which(newdat$Province %in% c(" "))] <- NA

newdat$Province[newdat$Locality=="Espluga de Francoli"]<- "Tarragona"
newdat$Province[newdat$Locality=="Castellón de la Plana"]<- "Castellón"
newdat$Province[newdat$Locality=="Las Sabinas"]<- "Granada"
newdat$Province[newdat$Locality=="Borreguiles"]<- "Granada"
newdat$Province[newdat$Locality=="Valle Niza"]<- "Malaga"
newdat$Province[newdat$Locality=="Jimena"]<- "Jaén"
newdat$Province[newdat$Locality=="25km SW.Cartagena"]<- "Murcia"
newdat$Province[newdat$Province=="Avila"]<- "Ávila"
newdat$Province[newdat$Province=="Alava"]<- "Álava"
newdat$Province[newdat$Province=="A Coruña"]<- "La Coruña"
newdat$Province[newdat$Province=="Guipuzcua"]<- "Guipúzcoa"
newdat$Province[newdat$Province=="Guipuzcoa"]<- "Guipúzcoa"
newdat$Province[newdat$Province=="Guipúzcua"]<- "Guipúzcoa"
newdat$Province[newdat$Province=="Girona"]<- "Gerona"
newdat$Province[newdat$Province=="CÓRDOBA"]<- "Córdoba"
newdat$Province[newdat$Province=="Lleida"]<- "Lérida"
newdat$Province[newdat$Province=="Lerida"]<- "Lérida"
newdat$Province[newdat$Province=="Provincia de Huesca"]<- "Huesca"
newdat$Province[newdat$Province=="Gran canaria"]<- "Gran Canaria"

#Check levels
options(max.print=500)
levels(factor(newdat$Locality))
newdat$Locality[which(newdat$Locality %in% c(""))] <- NA

newdat$Locality[newdat$Locality=="A Coruña"]<- "La Coruña"
newdat$Locality[newdat$Locality=="Alcalá de henares"]<- "Alcalá de Henares"
newdat$Locality[newdat$Locality=="Alcuescar"]<- "Alcuéscar"
newdat$Locality[newdat$Locality=="Baides"]<- "Baídes"
newdat$Locality[newdat$Locality=="Baleña"]<- "Baleñá"
newdat$Locality[newdat$Locality=="Balsain"]<- "Balsaín"
newdat$Locality[newdat$Locality=="Balsain"]<- "Balsaín"
newdat$Locality[newdat$Locality=="Barbasto"]<- "Barbastro"
newdat$Locality[newdat$Locality=="Caldas de Maravella"]<- "Caldas de Malavella"
newdat$Locality[newdat$Locality=="Caldas de Montbouy"]<- "Caldas de Montbui"
newdat$Locality[newdat$Locality=="Caldas de Montbuy"]<- "Caldas de Montbui"
newdat$Locality[newdat$Locality=="Casas de D. Pedro."]<- "Casas de D. Pedro"
newdat$Locality[newdat$Locality=="Castelldefels"]<- "Castelldeféls"
newdat$Locality[newdat$Locality=="Cazorla"]<- "Sierra de Cazorla"
newdat$Locality[newdat$Locality=="Cazorla (Sa Cazorla)"]<- "Sierra de Cazorla"
newdat$Locality[newdat$Locality=="Colmenar viejo"]<- "Colmenar Viejo"
newdat$Locality[newdat$Locality=="Doñana"]<- "Parque Nacional de Doñana"
newdat$Locality[newdat$Locality=="Doñana National Park"]<- "Parque Nacional de Doñana"
newdat$Locality[newdat$Locality=="Estany de Mont cortes"]<- "Estany de Montcortès"
newdat$Locality[newdat$Locality=="Estany de Montcortes"]<- "Estany de Montcortès"
newdat$Locality[newdat$Locality=="Forníllos de Fermoselle"] <- "Fornillos de Fermoselle"
newdat$Locality[newdat$Locality=="Fuenterrabia"] <- "Fuenterrabía"
newdat$Locality[newdat$Locality=="Gerona"] <- "Girona"
newdat$Locality[newdat$Locality=="Gosol"] <- "Gósol"
newdat$Locality[newdat$Locality=="Hoya de la Guija"] <- "Hoyo de la Guija"
newdat$Locality[newdat$Locality=="La garganta"] <- "La Garganta"
newdat$Locality[newdat$Locality=="La garriga"] <- "La Garriga"
newdat$Locality[newdat$Locality=="Los molinos"] <- "Los Molinos"
newdat$Locality[newdat$Locality=="Los Moblinos"] <- "Los Molinos"
newdat$Locality[newdat$Locality=="Martolell"] <- "Martorell"
newdat$Locality[newdat$Locality=="Nuevo Batzan"] <- "Nuevo Batzán"
newdat$Locality[newdat$Locality=="Nuevo Baztan"] <- "Nuevo Batzán"
newdat$Locality[newdat$Locality=="Ormaitztegui"] <- "Ormaiztegi"
newdat$Locality[newdat$Locality=="Ormaíztegui"] <- "Ormaiztegi"
newdat$Locality[newdat$Locality=="Ormáiztegui"] <- "Ormaiztegi"
newdat$Locality[newdat$Locality=="Alcañices"] <- "Alcañices"
newdat$Locality[newdat$Locality=="Almacellas"] <- "Almacelles"
newdat$Locality[newdat$Locality=="Andavías"] <- "Andavías"
newdat$Locality[newdat$Locality=="Bobadilla del campo"] <- "Bobadilla del Campo"
newdat$Locality[newdat$Locality=="Bronchelas"] <- "Bronchales"
newdat$Locality[newdat$Locality=="Cabanas"] <- "Cabañas"
newdat$Locality[newdat$Locality=="Centellas"] <- "Centelles"
newdat$Locality[newdat$Locality=="Cerro colgado"] <- "Cerro Colgado"
newdat$Locality[newdat$Locality=="Yanguas de E[resma]"] <- "Yanguas de Eresma"
newdat$Locality[newdat$Locality=="Zaldivar"] <- "Zaldívar"
newdat$Locality[newdat$Locality=="Valdastilla"] <- "Valdastillas"
newdat$Locality[newdat$Locality=="Uña"] <- "Uña de Quintana" 
newdat$Locality[newdat$Locality=="Tabascan"] <- "Tabascán" 
newdat$Locality[newdat$Locality=="Soller"] <- "Sóller" 
newdat$Locality[newdat$Locality=="Sierra palomera"] <- "Sierra Palomera" 
newdat$Locality[newdat$Locality=="Sierra nevada"] <- "Sierra Nevada"  
newdat$Locality[newdat$Locality=="Sierra del Cadi"] <- "Sierra del Cadí"  
newdat$Locality[newdat$Locality=="Sierra de V iejas" ] <- "Sierra de Viejas"  
newdat$Locality[newdat$Locality=="Selva de Zurita" ] <- "Selva de Zuriza"  
newdat$Locality[newdat$Locality=="Santa Creu de Olorde" ] <- "Santa Cruz de Olorde"  
newdat$Locality[newdat$Locality=="Sant Joan de Abadesses" ] <- "Sant Joan de les Abadeses"  
newdat$Locality[newdat$Locality=="San Lorenzo de Morumys" ] <- "San Lorenzo de Morunys"  
newdat$Locality[newdat$Locality=="San Llorent del Munt" ] <- "San Llorent del Mont"  
newdat$Locality[newdat$Locality=="San Llorent de Mont" ] <- "San Llorent del Mont"  
newdat$Locality[newdat$Locality=="San Julian de la Cabrera" ] <- "San Julián de la Cabrera" 
newdat$Locality[newdat$Locality=="San Juán de la Peña"  ] <- "San Juan de la Peña"
newdat$Locality[newdat$Locality=="Rosinos de Vidríales"  ] <- "Rosinos de Vidrialea"
newdat$Locality[newdat$Locality=="Puebla de D. Fabriques"  ] <- "Puebla de Don Fadrique"
newdat$Locality[newdat$Locality=="Puebla de D. Fadrique"  ] <- "Puebla de Don Fadrique"
#Can be better but good for now...

#Now collector
levels(factor(newdat$Collector))
newdat$Collector[which(newdat$Collector %in% c(""))] <- NA
newdat$Collector[which(newdat$Collector %in% c("A. G. Velázquez"))] <- "A.G. Velázquez"
newdat$Collector[which(newdat$Collector %in% c("A. W. Ebmer"))] <- "A.W. Ebmer"
newdat$Collector[which(newdat$Collector %in% c("ANDRÉ"))] <- "André"
newdat$Collector[which(newdat$Collector %in% c("Castro, L."))] <- "L. Castro"
newdat$Collector[which(newdat$Collector %in% c("Castro, L., Herrera, C."))] <- "L. Castro, C. Herrera"
newdat$Collector[which(newdat$Collector %in% c("F. J. Ortiz-Sánchez"))] <- "F.J. Ortiz-Sánchez"
newdat$Collector[which(newdat$Collector %in% c("Gª Mercet"))] <- "G. Mercet"
newdat$Collector[which(newdat$Collector %in% c("García Mercet"))] <- "G. Mercet"
newdat$Collector[which(newdat$Collector %in% c("Herrera, C.t"))] <- "C. Herrera"
newdat$Collector[which(newdat$Collector %in% c("J. A. Acosta"))] <- "J.A. Acosta"
newdat$Collector[which(newdat$Collector %in% c("J. A. González"))] <- "J.A. González"
newdat$Collector[which(newdat$Collector %in% c("J. R. Obeso"))] <- "J.R. Obeso"
newdat$Collector[which(newdat$Collector %in% c("Jimenez, A."))] <- "A. Jimenez"
newdat$Collector[which(newdat$Collector %in% c("K. M. Guichard"))] <- "K.M. Guichard"
newdat$Collector[which(newdat$Collector %in% c("Madero, A."))] <- "A. Madero"
newdat$Collector[which(newdat$Collector %in% c("Nieves & Rey"))] <- "Nieves y Rey"
newdat$Collector[which(newdat$Collector %in% c("Ortiz-Sànchez, F.J."))] <- "F.J. Ortiz-Sánchez"
newdat$Collector[which(newdat$Collector %in% c("P. De la Rúa"))] <- "P. de la Rúa"
newdat$Collector[which(newdat$Collector %in% c("PÉREZ"))] <- "Pérez"
newdat$Collector[which(newdat$Collector %in% c("Pérez, F.J."))] <- "F.J. Pérez"
newdat$Collector[which(newdat$Collector %in% c("Rey del Castillo, C., Nieves-Aldrey, J.L."))] <- "C. Rey del Castillo, J.L. Nieves-Aldrey"
newdat$Collector[which(newdat$Collector %in% c("S. F-Gayubo"))] <- "S.F. Gayubo"
newdat$Collector[which(newdat$Collector %in% c("S. F. Gayubo"))] <- "S.F. Gayubo"
newdat$Collector[which(newdat$Collector %in% c("S. V. Peris"))] <- "S.V. Peris"
newdat$Collector[which(newdat$Collector %in% c("SCHMIEDEKN"))] <- "Schmiedekn"
newdat$Collector[which(newdat$Collector %in% c("Tinaut, A."))] <- "A. Tinaut"
newdat$Collector[which(newdat$Collector %in% c("V. Monsterrat"))] <- "V. Montserrat"
newdat$Collector[which(newdat$Collector %in% c("VACHAL"))] <- "Vachal"
newdat$Collector[which(newdat$Collector %in% c("C. Heras y S.F. Gayubo"))] <- "C. Heras, S.F. Gayubo"
newdat$Collector[which(newdat$Collector %in% c("Barranco, P."))] <- "P. Barranco"
newdat$Collector[which(newdat$Collector %in% c("Baena, M."))] <- "M. Baena"
newdat$Collector[which(newdat$Collector %in% c("Asensio & Parker"))] <- "Asensio, Parker"
newdat$Collector[which(newdat$Collector %in% c("´CE"))] <- "CE"

#Now determined by column
levels(factor(newdat$Determined.by))
newdat$Determined.by[which(newdat$Determined.by %in% c(""))] <- NA
newdat$Determined.by[which(newdat$Determined.by %in% c("Asensio, E."))] <- "E. Asensio"
newdat$Determined.by[which(newdat$Determined.by %in% c("Báez, J., Bowden, J."))] <- "J. Báez, J. Bowden"
newdat$Determined.by[which(newdat$Determined.by %in% c("C. Ornosa & M.D. Martínez"))] <- "C. Ornosa, M.D. Martínez"
newdat$Determined.by[which(newdat$Determined.by %in% c("C. Ornosa, F. Torres & F. J. Ortiz-Sánchez"))] <- "C. Ornosa, F. Torres, F.J. Ortiz-Sánchez"
newdat$Determined.by[which(newdat$Determined.by %in% c("Cobos, A."))] <- "A. Cobos"
newdat$Determined.by[which(newdat$Determined.by %in% c("Dathe, H. H., Kuhlmann, M."))] <- "H.H. Dathe, M. Kuhlmann"
newdat$Determined.by[grepl("Exp. In", newdat$Determined.by, ignore.case=FALSE)] <- "Expedición del Instituto Español de Entomología"
newdat$Determined.by[which(newdat$Determined.by %in% c("F. J. Ortiz-Sánchez"))] <- "F.J. Ortiz-Sánchez"
newdat$Determined.by[which(newdat$Determined.by %in% c("García Valera"))] <- "García Varela"
newdat$Determined.by[which(newdat$Determined.by %in% c("García y Varela"))] <- "García Varela"
newdat$Determined.by[which(newdat$Determined.by %in% c("Gayubo, S. F."))] <- "S.F. Gayubo"
newdat$Determined.by[which(newdat$Determined.by %in% c("Gil-Collado"))] <- "Gil Collado"
newdat$Determined.by[which(newdat$Determined.by %in% c("Gusenleitner, F."))] <- "F. Gusenleitner"
newdat$Determined.by[which(newdat$Determined.by %in% c("Herrera, C. M., Amat, C. M."))] <- "C.M. Herrera, C.M. Amat"
newdat$Determined.by[which(newdat$Determined.by %in% c("J. R. Obeso"))] <- "J.R. Obeso"
newdat$Determined.by[which(newdat$Determined.by %in% c("Marcos, M. A."))] <- "M.A. Marcos"
newdat$Determined.by[which(newdat$Determined.by %in% c("O Contreras"))] <- "O. Contreras"
newdat$Determined.by[which(newdat$Determined.by %in% c("Sag. y Nov."))] <- "Sagarra y Novellas"
newdat$Determined.by[which(newdat$Determined.by %in% c("Vives, A., Yela, J. L."))] <- "A. Vives, J.L. Yela"
newdat$Determined.by[which(newdat$Determined.by %in% c("Vila de Paz"))] <- "Vila de la Paz"
newdat$Determined.by[which(newdat$Determined.by %in% c("Martorell y Peña"))] <- "Martorell, Peña"
newdat$Determined.by[grepl("Esp. Inst. Esp. Ent.", newdat$Determined.by, ignore.case=FALSE)] <- "Expedición del Instituto Español de Entomología"
#Seems ok 

#Last column to edit Reference.doi
#There are few errors here too
levels(factor(newdat$Reference.doi))
newdat$Reference.doi[which(newdat$Reference.doi %in% c(""))] <- NA
#I have open this paper already, check for duplicate data?
newdat$Reference.doi[which(newdat$Reference.doi %in% c("10.1111/jeb.12609"))] <- "https://doi.org/10.1111/jeb.12609"
newdat$Reference.doi[grepl("10.14201/gredos", newdat$Reference.doi,ignore.case=F)] <- "https://doi.org/10.14201/gredos.135710"
newdat$Reference.doi[which(newdat$Reference.doi %in% c("10.2307/2260469"))] <- "https://doi.org/10.2307/2260469"
newdat$Reference.doi[grepl("10.3989/graellsia.2009", newdat$Reference.doi,ignore.case=F)] <- "https://doi.org/10.3989/graellsia.2009.v65.i2.145"
newdat$Reference.doi[grepl("https://doi.org/10.11646/", newdat$Reference.doi,ignore.case=F)] <- "https://doi.org/10.11646/zootaxa.4237.1.3"
newdat$Reference.doi[grepl("ISSN: 1134-61", newdat$Reference.doi,ignore.case=F)] <- "ISSN: 1134-6108"
#All dois work now

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE,
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 48_Casimiro-Soriguer_etal  ----

help_structure()
newdat <- read.csv(file = 'rawdata/csvs/48_Casimiro-Soriguer_etal.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Add flower visited is on additional info
newdat$Flowers.visited <- "Erophaca baetica"
#Set notes now to NA
newdat$Any.other.additional.data <- NA

#Add unique identifier
newdat <- add_uid(newdat = newdat, '48_Casimiro-Soriguer_etal_')

write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 49_Ornosa_etal  ----

help_structure()
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

#Delete row with NA in genus
newdat <- newdat[!is.na(newdat$Genus),]

#Add country to some missing values
newdat$Country <- "Spain"

#Add missing provinces
newdat$Province[newdat$Locality=="La Pleta  Garraf"] <- "Barcelona"
newdat$Province[newdat$Locality=="Valencia"] <- "Valencia"
newdat$Province[newdat$Locality=="Cuenca"] <- "Cuenca"
newdat$Province[newdat$Locality=="Mallorca"] <- "Baleares"
newdat$Province[newdat$Locality=="Coll d´en Rebassa"] <- "Baleares"
newdat$Province[newdat$Locality=="Puerto Santa María"] <- "Cádiz"
newdat$Province[newdat$Locality=="Jerez"] <- "Cádiz"
newdat$Province[newdat$Locality=="Cartagena"] <- "Cádiz"
newdat$Province[newdat$Locality=="Esporlas"] <- "Baleares"
newdat$Province[newdat$Locality=="Esporlas"] <- "Baleares"

#Fix spacing in some levels
levels(factor(newdat$Collector))
newdat$Collector <- gsub("\\.", ". ", newdat$Collector)
newdat$Collector <- gsub("F. J. Haering", "F.J. Haering", newdat$Collector)
newdat$Collector <- gsub("M. A. Barón", "M.A. Barón", newdat$Collector)
newdat$Collector <- gsub("M. J. Sanz", "M.J. Sanz", newdat$Collector)
newdat$Collector <- gsub("S. V. Peris", "S.V. Peris", newdat$Collector)

#Fixed determined.by levels
levels(factor(newdat$Determined.by))
newdat$Determined.by <- gsub("A.Compte", "A. Compte", newdat$Determined.by)
newdat$Determined.by <- gsub("C Ornosa", "C. Ornosa", newdat$Determined.by)
newdat$Determined.by <- gsub("C.Ornosa", "C. Ornosa", newdat$Determined.by)
newdat$Determined.by <- gsub("C.P-Iñigo", "C.P. Iñigo", newdat$Determined.by)
newdat$Determined.by <- gsub("Domínguez, Serranoy Montagud", "Domínguez, Serrano, Montagud", newdat$Determined.by)
newdat$Determined.by <- gsub("E.Mingo", "E. Mingo", newdat$Determined.by)
newdat$Determined.by <- gsub("J. A. González", "J.A. González", newdat$Determined.by)

#C.Ornosa to credits?
newdat$Authors.to.give.credit <- "C. Ornosa"

newdat <- add_uid(newdat = newdat, '49_Ornosa_etal_')
write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

#####################################################################################---
# 50_Heleno_etal  ----

newdat <- read.csv(file = "rawdata/csvs/50_Heleno_etal.csv")

colnames(newdat)
colnames(newdat)[9] <- "precision" #just to see them both in two lines
#subgenus missing.
newdat$Subgenus <- NA
newdat$uid <- paste("50_Heleno_etal_", 1:nrow(newdat), sep = "")
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

#Compare vars
compare_variables(check, newdat)
#Rename columns
colnames(newdat)[which(colnames(newdat)=="precision")] <- "Coordinate.precision"
colnames(newdat)[which(colnames(newdat)=="day")] <- "Day"
colnames(newdat)[which(colnames(newdat)=="Reference..doi.")] <- "Reference.doi"
colnames(newdat)[which(colnames(newdat)=="Collection.Location_ID")] <- "Local_ID"
colnames(newdat)[which(colnames(newdat)=="End.Date")] <- "End.date"

newdat <- drop_variables(check, newdat) #reorder and drop variables

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#####################################################################################---
# 51_Minarro  ----

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
newdat$uid <- paste("51_Minarro_", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,25,2:12,26,27,13:24,28)]
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
newdat$Authors.to.give.credit <- "M. Miñarro, A. Núñez"

#Compare vars
compare_variables(check, newdat)
#Rename columns
colnames(newdat)[which(colnames(newdat)=="Coordinate.precision..e.g..GPS...10km.")] <- "Coordinate.precision"
colnames(newdat)[which(colnames(newdat)=="day")] <- "Day"
colnames(newdat)[which(colnames(newdat)=="Reference..doi.")] <- "Reference.doi"
colnames(newdat)[which(colnames(newdat)=="Collection.Location_ID")] <- "Local_ID"
colnames(newdat)[which(colnames(newdat)=="End.Date")] <- "End.date"
colnames(newdat)[which(colnames(newdat)=="month")] <- "Month"

#Drop variables and reorder
newdat <- drop_variables(check, newdat)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Add an extra space on collectors
newdat$Collector <- gsub("\\.", ". ", newdat$Collector)
newdat$Determined.by <- gsub("\\.", ". ", newdat$Determined.by)
newdat$Determined.by <- gsub("Identified by A. Núñez, O.  Aguado and/or J.  Ortiz", "A. Núñez, O.  Aguado, J.  Ortiz", newdat$Determined.by)

#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#####################################################################################---
# 52_Picanco  ----

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
newdat$uid <- paste("52_Picanco_", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,27,2:26,28)]
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)

#Compare vars
compare_variables(check, newdat)
#Rename cols
colnames(newdat)[which(colnames(newdat)=="precision")] <- "Coordinate.precision"
colnames(newdat)[which(colnames(newdat)=="day")] <- "Day"
colnames(newdat)[which(colnames(newdat)=="End.Date")] <- "End.date"
colnames(newdat)[which(colnames(newdat)=="Reference..doi.")] <- "Reference.doi"
colnames(newdat)[which(colnames(newdat)=="Collection.Location_ID")] <- "Local_ID"
colnames(newdat)[which(colnames(newdat)=="Any.other.additional.data..Habitat.type.")] <- "Any.other.additional.data"

#Drop variables and reorder
newdat <- drop_variables(check, newdat)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Change day format to d-m-y
newdat$Start.date <- as.Date(newdat$Start.date)
newdat$Start.date <-format(newdat$Start.date, "%d-%m-%Y")
newdat$End.date <- as.Date(newdat$End.date)
newdat$End.date <-format(newdat$End.date, "%d-%m-%Y")

#Change separator in determined.by
newdat$Determined.by <- gsub("Ana Picanço/Paulo A. V. Borges", "Ana Picanço, Paulo A.V. Borges", newdat$Determined.by)

#Select a unique doi (Criteria:the oldest one) 
#Also one of them has excel error of scrolling down
levels(factor(newdat$Reference.doi))
#Both are from 2017, just keep one
newdat$Reference.doi <- "https://doi.org/10.1111/icad.12216"

#Authors to give credit, change separator
levels(factor(newdat$Authors.to.give.credit))
newdat$Authors.to.give.credit <- gsub("Ana Picanço; Paulo A. V.Borges", "Ana Picanço, Paulo A. V.Borges", newdat$Authors.to.give.credit)

#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#####################################################################################---
# 53_Ferrero  ----

newdat <- read.csv(file = "rawdata/csvs/53_Ferrero.csv")
colnames(newdat)
colnames(newdat)[9] <- "precision"
#subgenus missing.
newdat$Subgenus <- NA
newdat$uid <- paste("53_Ferrero_", 1:nrow(newdat), sep = "")
#reorder
newdat <- newdat[,c(1,27,2:26,28)]
#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
newdat$Latitude <- as.character(newdat$Latitude)
newdat$Latitude[61] <- 37.39836111111111
newdat$Latitude <- as.numeric(newdat$Latitude)

#Compare vars
compare_variables(check, newdat)
#Rename vars
colnames(newdat)[which(colnames(newdat)=="precision")] <- "Coordinate.precision"
colnames(newdat)[which(colnames(newdat)=="day")] <- "Day"
colnames(newdat)[which(colnames(newdat)=="End.Date")] <- "End.date"
colnames(newdat)[which(colnames(newdat)=="Reference..doi.")] <- "Reference.doi"
colnames(newdat)[which(colnames(newdat)=="Collection.Location_ID")] <- "Local_ID"
#Drop vars and reorder
newdat <- drop_variables(check, newdat)

#Clean genus with NA
newdat <- newdat[!is.na(newdat$Genus),]

#Reoganize month names
newdat$Start.date[newdat$Month=="April/May"] <- "01-04-2007"
newdat$End.date[newdat$Month=="April/May"] <- "31-05-2007"
newdat$Month[newdat$Month=="April/May"] <- NA
newdat$Start.date[newdat$Month=="Feb/March" & newdat$Year=="2006"] <- "01-02-2006"
newdat$End.date[newdat$Month=="Feb/March" & newdat$Year=="2006"] <- "31-03-2006"
newdat$Month[newdat$Month=="Feb/March" & newdat$Year=="2012"] <- NA
newdat$Start.date[newdat$Month=="Feb/March" & newdat$Year=="2012"] <- "01-02-2012"
newdat$End.date[newdat$Month=="Feb/March" & newdat$Year=="2012"] <- "31-03-2012"
newdat$Month[newdat$Month=="Feb/March" & newdat$Year=="2012"] <- NA
newdat$Start.date[newdat$Month=="May/June"] <- "01-05-2008"
newdat$End.date[newdat$Month=="May/June"] <- "30-05-2008"
newdat$Month[newdat$Month=="May/June"] <- NA
#Now convert month names to numbers
newdat$Month <- match(newdat$Month, month.name)
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)

#Fix one level in Flowers.visited
newdat$Flowers.visited <- gsub("Brassica oleracea Brassicaceae III", "Brassica oleracea", newdat$Flowers.visited)

#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#####################################################################################---
# 54_Wood_etal  ----

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
newdat$uid <- paste("54_Wood_etal_", 1:nrow(newdat), sep = "")
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

#Keep working from here

#newdat$Locality[12]
#gsub("[^[:alnum:]]", "_", newdat$Locality[12])
#newdat$Locality <- as.character(newdat$Locality)
#newdat$Locality <- gsub("[^[:alnum:]]", "", newdat$Locality)

#Compare vars
compare_variables(check, newdat)
#Rename some columns
colnames(newdat)[which(colnames(newdat)=="month")] <- "Month"
colnames(newdat)[which(colnames(newdat)=="day")] <- "Day"
colnames(newdat)[which(colnames(newdat)=="End.date.original")] <- "End.date"
colnames(newdat)[which(colnames(newdat)=="Determiner")] <- "Determined.by"
colnames(newdat)[which(colnames(newdat)=="refbib")] <- "Reference.doi"
colnames(newdat)[which(colnames(newdat)=="Code")] <- "Local_ID"

#Check levels
levels(factor(newdat$Country))
#Rename countries
newdat$Country <- gsub("SPAIN", "Spain", newdat$Country)
newdat$Country[which(newdat$Country %in% c(""))] <- NA

#Rename provinces
newdat$Province[which(newdat$Province %in% c(""))] <- NA
newdat$Province[newdat$Province=="(Alic.)"] <- "Alicante"
newdat$Province[newdat$Province=="(Alic)"] <- "Alicante"
newdat$Province[newdat$Province=="(Ciudad-Real)"] <- "Ciudad Real"
newdat$Province[newdat$Province=="(Gran)"] <- "Granada"
newdat$Province[newdat$Province=="(Gren)"] <- "Granada"
newdat$Province[newdat$Province=="(Jaen)"] <- "Jaén"
newdat$Province[newdat$Province=="(Leon)"] <- "León"
newdat$Province[newdat$Province=="(N.)"] <- "Navarra"
newdat$Province[newdat$Province=="(Navarra)"] <- "Navarra"
newdat$Province[newdat$Province=="(SraDE GREDOS)"] <- "Ávila"
newdat$Province[newdat$Province=="(Viscaya)"] <- "Vizcaya"
newdat$Province[newdat$Province=="(Zaragosa)"] <- "Zaragoza"
newdat$Province[newdat$Province=="Alava"] <- "Álava"
newdat$Province[newdat$Province=="Ã\u0081lava"] <- "Álava"
newdat$Province[newdat$Province=="Algarva"] <- "Algarve"
newdat$Province[newdat$Province=="Algeciras, achterland van"] <- "Algeciras"
newdat$Province[newdat$Province=="Algeciras, province"] <- "Algeciras"
newdat$Province[newdat$Province=="Almeria"] <- "Almería"
newdat$Province[newdat$Province=="Andalucia"] <- "Andalucía"
newdat$Province[newdat$Province=="Andalusia"] <- "Andalucía"
newdat$Province[newdat$Province=="AragÃ³n, Huesca"] <- "Huesca"
newdat$Province[newdat$Province=="Aragon, Huesca"] <- "Huesca"
newdat$Province[newdat$Province=="Aragon, Teruel"] <- "Huesca"
newdat$Province[newdat$Province=="AZORÃ\u0089S Santa Maria"] <- "Isla Santa María (Azores)"
newdat$Province[newdat$Province=="Azoren, SÃ£o Miguel"] <- "Isla Sao Miguel (Azores)"
newdat$Province[newdat$Province=="Baleares, Menorca"] <- "Islas Baleares"
newdat$Province[newdat$Province=="Balearic Islands"] <- "Islas Baleares"
newdat$Province[newdat$Province=="Basses PyrÃ©nÃ©es"] <- "Huesca"
newdat$Province[newdat$Province=="Biscay"] <- "Vizcaya"
newdat$Province[newdat$Province=="Biskaje"] <- "Vizcaya"
newdat$Province[newdat$Province=="Burgos, Central Spain"] <- "Burgos"
newdat$Province[newdat$Province=="CÃ¡ceres"] <- "Cáceres"
newdat$Province[newdat$Province=="CÃ¡diz"] <- "Cádiz"
newdat$Province[newdat$Province=="Caceres"] <- "Cáceres"
newdat$Province[newdat$Province=="CadÃ­s"] <- "Cádiz"
newdat$Province[newdat$Province=="Cadia"] <- "Cádiz"
newdat$Province[newdat$Province=="Cadis"] <- "Cádiz"
newdat$Province[newdat$Province=="Cadiz"] <- "Cádiz"
newdat$Province[newdat$Province=="Canary Islands"] <- "Islas Canarias"
newdat$Province[newdat$Province=="capana.LeÃ³n"] <- "Zamora"
newdat$Province[newdat$Province=="Castile-la-Mancha"] <- "Castilla-La Mancha"
newdat$Province[newdat$Province=="CastiliÃ«-La Mancha"] <- "Castilla-La Mancha"
newdat$Province[newdat$Province=="Castilien"] <- "Cuenca"
newdat$Province[newdat$Province=="Castilla i LeÃ³n"] <- "Castilla y León"
newdat$Province[newdat$Province=="Castilla i Leon"] <- "Castilla y León"
newdat$Province[newdat$Province=="Castilla la Mancha"] <- "Castilla-La Mancha"
newdat$Province[newdat$Province=="Castilla-Leon"] <- "Castilla y León"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Prades"] <- "Tarragona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="10 km N of Lerida (Lleida)"] <- "Lérida"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="10 km E of Lerida (Lleida)"] <- "Lérida"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Lerida"] <- "Lérida"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Canet de mar"] <- "Barcelona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Martinet, 20 km SE of Andorra, Pyrenees (East)"] <- "Lérida"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Martinet20kmSEofAndorraPyreneesEast"] <- "Lérida"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Cerbi, 36 km NW of Andorra Esterri, 1600-2000 m"] <- "Lérida"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="18 km SW of Tortosa, Puertos de Beseit (Ports de Tortosa-Beseit)"] <- "Tarragona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Parc Natural del Garraf"] <- "Barcelona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Mont-roig del Camp, 8 km W of Cambrils"] <- "Tarragona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Barcelona"] <- "Barcelona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Pineda de Mar"] <- "Barcelona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="S. Pere de Vilamajor"] <- "Barcelona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Gerona"] <- "Gerona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Malgrat de Mar"] <- "Barcelona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Monserrat"] <- "Barcelona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Anglesola"] <- "Lérida"
newdat$Province[newdat$Province=="Catalonia, Barcelona" & newdat$Locality=="Monserrat"] <- "Barcelona"
newdat$Province[newdat$Province=="Catalonia, Barcelona" & newdat$Locality=="Monte Serrato"] <- "Barcelona"
newdat$Province[newdat$Province=="Catalonia, Barcelona" & newdat$Locality=="Montserrat"] <- "Barcelona"
newdat$Province[newdat$Locality=="Catalonia, Palamos"] <- "Gerona"
newdat$Province[newdat$Locality=="Catalonia, 40 km N Tortosa, riv. Ebre"] <- "Tarragona"
newdat$Province[newdat$Locality=="Catalonia, Lleida env."] <- "Lérida"
newdat$Province[newdat$Locality=="Catalonia - 8 km W of Cambrils, Mont-Roig del Camp"] <- "Tarragona"
newdat$Province[newdat$Province=="CataluÃ±a, Sierra del Cadi"] <- "Lérida"
newdat$Province[newdat$Province=="Cataluna"] <- "Gerona"
newdat$Province[newdat$Province=="Catalunia"] <- "Barcelona"
newdat$Province[newdat$Province=="Catalunia, Barcelona"] <- "Barcelona"
newdat$Province[newdat$Province=="Centr., Castile-La Mancha"] <- "Castilla-La Mancha"
newdat$Province[newdat$Province=="Centr., Cuenca"] <- "Cuenca"
newdat$Province[newdat$Province=="Centr., Montes Universales"] <- "Teruel"
newdat$Province[newdat$Province=="Centr., Seg."] <- "Segovia"
newdat$Province[newdat$Province=="Central Spain [Aragon]"] <- "Aragón"
newdat$Province[newdat$Province=="Central Spain [Cuenca]"] <- "Cuenca"
newdat$Province[newdat$Province=="Central Spain, Burgos"] <- "Burgos"
newdat$Province[newdat$Province=="Central Spain, Madrid"] <- "Madrid"
newdat$Province[newdat$Province=="Central Spain, Soria"] <- "Soria"
newdat$Province[newdat$Province=="Central Spain, Toledo"] <- "Toledo"
newdat$Province[newdat$Province=="Central-Spain, Toledo"] <- "Toledo"
newdat$Country[newdat$Province=="charente maritime"] <- "France"
newdat$Province[newdat$Province=="charente maritime"] <- "Charente maritime"
newdat$Province[newdat$Province=="Coruna"] <- "La Coruña"
newdat$Province[newdat$Province=="Cuenca, Castilien"] <- "Cuenca"
newdat$Province[newdat$Province=="E. Spain, prov. MÃ¡laga"] <- "Málaga"
newdat$Province[newdat$Province=="East Spain" & newdat$Locality=="Altea, 10 km N of Benidorm"] <- "Alicante"
newdat$Province[newdat$Province=="East Spain" & newdat$Locality=="Altea"] <- "Alicante"
newdat$Province[newdat$Province=="East Spain" & newdat$Locality=="Ferrandet, near Calpe"] <- "Alicante"
newdat$Province[newdat$Province=="East Spain, Albacete"] <- "Albacete"
newdat$Province[newdat$Province=="East Spain, Alicante"] <- "Alicante"
newdat$Province[newdat$Province=="East Spain, Tarragona"] <- "Tarragona"
newdat$Province[newdat$Province=="Extramadura" & newdat$Locality=="HervÃ¡s"] <- "Cáceres"
newdat$Province[newdat$Province=="Extramadura" & newdat$Locality=="HervÃ¡s"] <- "Cáceres"
newdat$Province[newdat$Province=="Fuertaventura"] <- "Islas Canarias"
newdat$Province[newdat$Province=="Fuertaventura, Canarias"] <- "Islas Canarias"
newdat$Province[newdat$Province=="Fuerteventura"] <- "Islas Canarias"
newdat$Province[newdat$Province=="Fuerto-ventura"] <- "Islas Canarias"
newdat$Province[newdat$Province=="G. v. Biscaje"] <- "Guipúzcoa"
newdat$Province[newdat$Province=="Galicia, Pontevedra"] <- "Pontevedra"
newdat$Province[newdat$Province=="Gipuzkoa"] <- "Guipúzcoa"
newdat$Province[newdat$Province=="Gran Canaria"] <- "Islas Canarias"
newdat$Province[newdat$Province=="Granada, Sierra Nevada"] <- "Granada"
newdat$Province[newdat$Province=="Avila"] <- "Ávila"
newdat$Province[newdat$Province=="Al."] <- "Alicante"
newdat$Province[newdat$Province=="Aragon"] <- "Aragón"
newdat$Province[newdat$Province=="Aragon, Centr."] <- "Aragón"
newdat$Province[newdat$Province=="Aragon, Hispania Centr."] <- "Aragón"
newdat$Province[newdat$Province=="Centr." & newdat$Locality=="Tragacete"] <- "Cuenca"
newdat$Province[newdat$Province=="GiupÃºzcoa"] <- "Guipúzcoa"
newdat$Province[newdat$Province=="GuipÃºzcoa"] <- "Guipúzcoa"
newdat$Province[newdat$Province=="GuipÃºzcoa / Basque Country"] <- "Guipúzcoa"
newdat$Province[newdat$Province=="Guipuzcoa"] <- "Guipúzcoa"
newdat$Province[newdat$Province=="Hisp. centr."] <- "Teruel"
newdat$Province[newdat$Province=="Hisp. centr."] <- "Teruel"
newdat$Province[newdat$Province=="Hispania Centr." & newdat$Locality=="C. Encantada, Cuenca"] <- "Cuenca"
newdat$Province[newdat$Province=="Hispania Centr." & newdat$Locality=="Cercedilla Dehesas"] <- "Madrid"
newdat$Province[newdat$Province=="Hispania Centr." & newdat$Locality=="Tragacete-Huelamos"] <- "Cuenca"
newdat$Province[newdat$Province=="Hispania Centr." & newdat$Locality=="Tragacete-Huelamo"] <- "Cuenca"
newdat$Province[newdat$Province=="Hispania Centr., Cuenca"] <- "Cuenca"
newdat$Province[newdat$Province=="Hispania Centr., Sierra de Albarracin"] <- "Teruel"
newdat$Province[newdat$Province=="Hispania Central" & newdat$Locality=="Tragacete-Huelamo"] <- "Cuenca"
newdat$Province[newdat$Province=="Hispania Central" & newdat$Locality=="Albarracin"] <- "Teruel"
newdat$Province[newdat$Province=="Hispania Central" & newdat$Locality=="Tragacete"] <- "Cuenca"
newdat$Province[newdat$Province=="Hispania Central" & newdat$Locality=="Sierra de Albarracin"] <- "Teruel"
newdat$Province[newdat$Province=="Hispania Central" & newdat$Locality=="Cercedilla Dehesas"] <- "Madrid"
newdat$Province[newdat$Province=="Hispania Central" & newdat$Locality=="Tragacete, Huelamo"] <- "Cuenca"
newdat$Province[newdat$Province=="Hispania Central" & newdat$Locality=="Pto. de Navacerrada"] <- "Madrid"
newdat$Province[newdat$Province=="Hispania Central" & newdat$Locality=="Puerto de Navacerrada"] <- "Madrid"
newdat$Province[newdat$Province=="Guad."] <- "Guadalajara"
newdat$Province[newdat$Province=="Hispania Central, Aragon"] <- "Aragón"
newdat$Province[newdat$Province=="Hispania Central, Cuenca"] <- "Cuenca"
newdat$Province[newdat$Province=="Hispania Central, Segovia"] <- "Segovia"
newdat$Province[newdat$Province=="Hispania Central, Sierra de Guadarrama"] <- "Madrid"
newdat$Province[newdat$Province=="Hispania Central, Teruel"] <- "Teruel"
newdat$Province[newdat$Province=="IBIZA (Bal.)"] <- "Islas Baleares"
newdat$Province[newdat$Province=="Is. Baleares MALLORCA"] <- "Islas Baleares"
newdat$Province[newdat$Province=="Is.Baleares"] <- "Islas Baleares"
newdat$Province[newdat$Province=="Islas Baleares, Mallorca"] <- "Islas Baleares (Mallorca)"
newdat$Province[newdat$Province=="Islas Canarias, La Palma"] <- "Islas Canarias (La Palma)"
newdat$Province[newdat$Province=="Islas Canarias, Tenerife"] <- "Islas Canarias (Tenerife)"
newdat$Province[newdat$Province=="JaÃ©n"] <- "Jaén"
newdat$Province[newdat$Province=="Jaen"] <- "Jaén"
newdat$Province[newdat$Province=="La Coruna"] <- "Jaén"
newdat$Province[newdat$Province=="La Palma"] <- "Islas Canarias (La Palma)"
newdat$Province[newdat$Province=="LeÃ³n"] <- "León"
newdat$Province[newdat$Province=="LeÃ³n, Montes de LeÃ³n"] <- "León"
newdat$Province[newdat$Province=="Leon"] <- "León"
newdat$Province[newdat$Province=="Lerida"] <- "Lérida"
newdat$Province[newdat$Province=="LlanÃ§Ã "] <- "Gerona"
newdat$Province[newdat$Province=="MÃ¡laga"] <- "Málaga"
newdat$Province[newdat$Province=="Malaga"] <- "Málaga"
newdat$Province[newdat$Province=="Mallorca"] <- "Islas Baleares (Mallorca)"
newdat$Province[newdat$Province=="Mallorca, East"] <- "Islas Baleares (Mallorca)"
newdat$Province[newdat$Province=="Merida"] <- "Mérida"
newdat$Province[newdat$Province=="Minorca"] <- "Islas Baleares (Menorca)"
newdat$Province[newdat$Province=="Montes de LÃ©on"] <- "Montes de León"
newdat$Province[newdat$Province=="Murcia, province"] <- "Murcia"
newdat$Province[newdat$Province=="N. Spain"] <- "Navarra"
newdat$Province[newdat$Province=="Nav."] <- "Navarra"
newdat$Province[newdat$Province=="Navarra, South Spain"] <- "Navarra"
newdat$Province[newdat$Province=="near MÃ laga"] <- "Málaga"
newdat$Province[newdat$Province=="Nordost"] <- "Barcelona"
newdat$Province[newdat$Province=="North Spain, prov. Burgos"] <- "Burgos"
newdat$Province[newdat$Province=="North Spain, prov. Navarra"] <- "Navarra"
newdat$Province[newdat$Province=="North West Spain" & newdat$Locality=="Viscaya, kust bij Somorrostro (tussen Bilbao en Castro Urdiales)"] <- "Vizcaya"
newdat$Province[newdat$Province=="North West Spain" & newdat$Locality=="Villajuan, S.W. of Villagarcia (Pontevedra)"] <- "Pontevedra"
newdat$Province[newdat$Province=="North West Spain, Coruna"] <- "La Coruña"
newdat$Province[newdat$Province=="North-East Spain" & newdat$Locality=="La Garriga"] <- "Barcelona"
newdat$Province[newdat$Province=="North-East Spain" & newdat$Locality=="Collsacabra"] <- "Barcelona"
newdat$Province[newdat$Province=="North-West Spain" & newdat$Locality=="Caldas de Reyes"] <- "Pontevedra"
newdat$Province[newdat$Province=="North-West Spain" & newdat$Locality=="Boiro, 3 km South-East of"] <- "La Coruña"
newdat$Province[newdat$Province=="North-West Spain" & newdat$Locality=="Boiro, 2 km. S.E. of"] <- "La Coruña"
newdat$Province[newdat$Province=="North-West Spain" & newdat$Locality=="Callas de Reyes"] <- "Pontevedra"
newdat$Province[newdat$Province=="North-West Spain, Pontevedra"] <- "Pontevedra"
newdat$Province[newdat$Province=="prov. Almeria"] <- "Almería"
newdat$Province[newdat$Province=="prov. Murcia"] <- "Murcia"
newdat$Province[newdat$Province=="prov. Navarra"] <- "Navarra"
newdat$Province[newdat$Province=="Provence"] <- "Barcelona"
newdat$Province[newdat$Province=="Province Burgos"] <- "Burgos"
newdat$Province[newdat$Province=="Province Murcia"] <- "Murcia"
newdat$Province[newdat$Province=="PyrÃ©nÃ©es Espagnol" & newdat$Locality=="Panticosa"] <- "Huesca"
newdat$Province[newdat$Province=="PyreneeÃ«n" & newdat$Locality=="Salau"] <- "Tarragona"
newdat$Province[newdat$Province=="PyreneeÃ«n" & newdat$Locality=="Alos de Isile"] <- "Lérida"
newdat$Province[newdat$Province=="PyreneeÃ«n, noordhelling" & newdat$Locality=="Col du Somport"] <- "Huesca"
newdat$Province[newdat$Province=="PyreneeÃ«n, noordhelling" & newdat$Locality=="Col de Somport Noord Helling PyreneeÃ«n"] <- "Huesca"
newdat$Province[newdat$Province=="PyreneeÃ«n, noordhelling"] <- "Ávila"
newdat$Province[newdat$Province=="S. E. Spain, prov. Murcia"] <- "Murcia"
newdat$Province[newdat$Province=="Sierra"] <- "Jaén"
newdat$Province[newdat$Province=="Sierra de Gredos"] <- "Ávila"
newdat$Province[newdat$Province=="Sierra de Guadarama"] <- "Madrid"
newdat$Province[newdat$Province=="Sierra de Guadarrama"] <- "Madrid"
newdat$Province[newdat$Province=="Sierra Nevada"] <- "Granada"
newdat$Province[newdat$Province=="Sierra Nevada, Granada"] <- "Granada"
newdat$Province[newdat$Province=="South Spain, Alicante"] <- "Alicante"
newdat$Province[newdat$Province=="South Spain, Cadiz"] <- "Cádiz"
newdat$Province[newdat$Province=="South Spain, MÃ¡laga"] <- "Málaga"
newdat$Province[newdat$Province=="South Spain, Navarra"] <- "Navarra"
newdat$Province[newdat$Province=="South Spain, prov. MÃ¡laga"] <- "Málaga"
newdat$Province[newdat$Province=="South-East Spain, dept. MÃ laga"] <- "Málaga"
newdat$Province[newdat$Province=="South-Spain, Malaga near"] <- "Málaga"
newdat$Province[newdat$Province=="South-West Spain, prov. Cadiz"] <- "Cádiz"
newdat$Province[newdat$Province=="South-West Spain, prov. Sevilla"] <- "Sevilla"
newdat$Province[newdat$Province=="Southeast Spain, MÃ£laga"] <- "Málaga"
newdat$Province[newdat$Province=="Southern Spain, Alicante"] <- "Alicante"
newdat$Province[newdat$Province=="Southern Spain, Granada"] <- "Granada"
newdat$Province[newdat$Province=="Southern Spain, Malaga, Sierra Bermeja"] <- "Málaga"
newdat$Province[newdat$Province=="Southern Spain, prov. CadÃ­z"] <- "Cádiz"
newdat$Province[newdat$Province=="Southern Spain, Teruel"] <- "Teruel"
newdat$Province[newdat$Province=="Spanische Pyrenaeen"] <- "Gerona"
newdat$Province[newdat$Province=="near MÃ laga"] <- "Málaga"
newdat$Province[newdat$Province=="S. de Gredos"] <- "Ávila"
newdat$Province[newdat$Province=="South-East Spain, dept. MÃ laga"] <- "Málaga"
newdat$Province[newdat$Province=="Tarrazona"] <- "Tarragona"
newdat$Province[newdat$Province=="Ternel"] <- "Teruel"
newdat$Province[newdat$Province=="Teruel, Hautes PyrÃ©nÃ©Ã©s"] <- "Teruel"
newdat$Province[newdat$Province=="Val de Ordesa"] <- "Huesca"
newdat$Province[newdat$Province=="Valentia"] <- "Valencia"
newdat$Province[newdat$Province=="Vizcaya, northwestern part of Spain"] <- "Vizcaya"
newdat$Province[newdat$Province=="West Mallorca"] <- "Islas Baleares (Mallorca)"
newdat$Province[newdat$Province=="West Spain, Badajoz"] <- "Badajoz"
newdat$Province[newdat$Province=="West Spain, prov. Caseres"] <- "Cáceres"
newdat$Province[newdat$Province=="West-Spain, prov. Caceres"] <- "Cáceres"
newdat$Province[newdat$Province=="Za"] <- "Zaragoza"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Gerez"] <- "Cádiz"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Villaricios"] <- "Almería"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Ronda"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Granada, Sierra de Almijara, 19 km N of Almunecar, 945 m"] <- "Granada"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Benidorm"] <- "Alicante"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Estepona"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Granada, Pantano de Cubillas"] <- "Granada"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Torremolinos (nr Malaga)"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="50 km N of Granada"] <- "Granada"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="AlmuÃ±Ã©car, Granada"] <- "Granada"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Almeria, Mojacar"] <- "Almería"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Alicante, Denia"] <- "Alicante"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Cadiz, Castellar de la Frontera"] <- "Cádiz"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, Arriate"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, 5 km S Ronda"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, Benalmadena"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, 5 km E Alhaurin el Grande"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, Torre del Mar"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, Rincon de la Victoria"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, San Julian"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, El Chorro"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, San Julian, 8 km SW of Malaga"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, Velez Malaga"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, Torre del Mar"] <- "Málaga"
newdat$Province[newdat$Province=="Vieja"] <- "Soria"
newdat$Province[newdat$Province=="South-East Spain, dept. MÃ laga"] <- "Málaga"
newdat$Province[newdat$Locality=="(Huesca) Toria, 1000 m."] <- "Huesca"

#Organize Portugal by districts (equivalent of provinces in Spain?)
#This is going to take ages and portugal is small, maybe something to do in the future
#I tried a bit...
#newdat$Province[newdat$Province=="(Minles-Portugal)"] <- "Porto"
#newdat$Province[newdat$Province=="Algarve"] <- "Faro"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Estremoz"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Elvas"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Évora"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Mitra, Évora"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Castelo de Vide"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Castelo de Vide"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Almendras"] <- "Guarda"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Ribeira de Valverde"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Almendres"] <- "Guarda"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Álamo"] <- "Guarda"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Castelo do Vide"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Vila Nova de São Bento"] <- "Beja"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Évora, Ribeira de Valverde "] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Montemor-o-novo"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Almandres"] <- "Guarda"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Serra Monfurado"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Serra do Monfurado"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Vila Visçosa"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Vila Visçosa"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Alandroal"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="BORBA"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Marvão, Castelo"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Portalegre"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Reguengo, Portalegre"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Montargil, Portalegre"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Montargil, Ponte de Sor, Portalegre"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Flor de Rosa"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Ponte de Sor"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Montemor-o-Novo"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Foros de Vale de Figueria, Montemor-o-novo"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Portalegre, Vaiamonte"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Vaiamonte, near Portalegre"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Vaiamonte"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Foros de Mora, Mora, Évora"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Évora, Mora"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Coruche, Couço"] <- "Santarém"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Mora, near Évora"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Albufeira de Montagil"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Barragem de Montargil, Portalegre"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Portalegre, Ribeira de Nisa"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Marvão, Santo Maria de Marvão, Portalegre"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Mértola, Alcaria river, Beja"] <- "Beja"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Mora, Cabecao, Gameiro"] <- "Beja"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Barrancos"] <- "Beja"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Mora, Cabeção"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Mora, Cabeção, Gameiro"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Montemor-o-Novo, Foros de Vale de Figeira"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Montemor-o-Novo,Foros de Vale da Figueira M2"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Montemor-o-Novo,Foros de Vale da Figueira A1"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Montemor-o-Novo,Foros de Vale da Figueira M1"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Montemor-o-Novo,Foros de Vale da Figueira M2 "] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Montemor-o-Novo,Foros de Vale da Figueira A1 "] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Montemor-o-Novo,Foros de Vale da Figueira dam "] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Montemor-o-Novo,Foros de Vale da Figueira "] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Montemor-o-Novo,Foros de Vale da Figueira A2"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Portalegre, PN Serra São Mamede"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Portalegre, PN Serra São Mamede, Barretos"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Portalegre, PN Serra São Mamede, Castelo de Vide"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Cerros, near to Restaurante Herdade do Esporão"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Foros de Vale Figueira, Montemor-o-Novo"] <- "Évora"

#They look better now but still more work can be done here
levels(factor(newdat$Province))

#Check localities
levels(factor(newdat$Locality))
#Do a bit of cleaning (not something crazy)
newdat$Locality[newdat$Locality==" "] <- NA
newdat$Locality[newdat$Locality==""] <- NA
newdat$Locality[newdat$Locality=="@"] <- NA
newdat$Locality[newdat$Locality=="@@"] <- NA
newdat$Locality <- gsub("\\- Andalucia, ", "", newdat$Locality)
newdat$Locality[newdat$Locality=="#NAME?"] <- NA
newdat$Locality[newdat$Locality=="#NOM?"] <- NA

#This is going to be 4ever too so lets make string to title
#And check if its not too bad
newdat$Locality <- stringr::str_to_title(newdat$Locality)
newdat$Locality <- gsub("\\ De", " de", newdat$Locality)
newdat$Locality <- gsub("\\ Do", " do", newdat$Locality)
newdat$Locality <- gsub("\\ Of", " of", newdat$Locality)
newdat$Locality <- gsub("\\ El", " el", newdat$Locality)
newdat$Locality <- gsub("\\ La", " la", newdat$Locality)
newdat$Locality <- gsub("\\ Los", " los", newdat$Locality)

newdat$Locality[newdat$Locality=="Barcelona, Provincia de"] <- NA
newdat$Locality[newdat$Locality=="Córdoba, Provincia de"] <- NA
newdat$Locality[newdat$Locality=="- 23 Km S Cadiz,Chiclana de la Frontera"] <- "23 km S Cádiz, Chiclana de la Frontera"
newdat$Locality[newdat$Locality=="- 25 Km Sww Sevilla, Aznalcazar"] <- "25 km SW Sevilla, Aznalcazar"
newdat$Locality[newdat$Locality=="- 26 Km Sww Sevilla, Aznalcazar"] <- "26 km SW Sevilla, Aznalcazar"
newdat$Locality[newdat$Locality=="- 27 Km Sww Sevilla, Aznalcazar"] <- "27 km SW Sevilla, Aznalcazar"
newdat$Locality[newdat$Locality=="- 23 Km S Cadiz, Chiclana"] <- "23 km S Cadiz, Chiclana"
newdat$Locality[newdat$Locality=="- 28 Km Sww Sevilla, Aznalcazar"] <- "28 km SW Sevilla, Aznalcazar"
newdat$Locality[newdat$Locality=="- 65 Km Sw Sevilla, W Matalascanas"] <- "65 km SW Sevilla, W Matalascanas"
newdat$Locality[newdat$Locality=="(Madrid) Bij Camping Osuna Bij Madrid"] <- "Camping Osuna (Madrid)"
newdat$Locality[newdat$Locality=="20km Sw.murcie"] <- "20 km SW Murcia"
newdat$Locality[newdat$Locality=="20km W.montforte de Lemos"] <- "20 km W Montforte de Lemos"
newdat$Locality[newdat$Locality=="25 Km Sww Sevilla, Aznalcazar, E-Sev "] <- "25 km SW Sevilla, Aznalcazar"
newdat$Locality[newdat$Locality=="25 Km Sww Sevilla, Aznalcazar"] <- "25 km SW Sevilla, Aznalcazar"
newdat$Locality[newdat$Locality=="25km Sw.cartagena"] <- "25km SW Cartagena"
newdat$Locality[newdat$Locality=="10 Km Se Baza"] <- "10 km SE Baza"
newdat$Locality[newdat$Locality=="10 Km. W, Van Jaca"] <- "10 km W Van Jaca"
newdat$Locality[newdat$Locality=="10km N.albacete"] <- "10 km N Albacete"
newdat$Locality[newdat$Locality=="10km No.calatayud"] <- "10 km NO Calatayud"
newdat$Locality[newdat$Locality=="10km W.navalcan"] <- "10 km W Navalcan"
newdat$Locality[newdat$Locality=="15 Km.n.w. Van Tarifa"] <- "15 km NW Tarifa"
newdat$Locality[newdat$Locality=="15km E.marbella"] <- "15 km E Marbella"
newdat$Locality[newdat$Locality=="20km Sw.murcia"] <- "20 km SW Murcia"
newdat$Locality[newdat$Locality=="20km Sw.murcia"] <- "20 km SW Murcia"
newdat$Locality[newdat$Locality=="20km Sw.murcia"] <- "20 km SW Murcia"
newdat$Locality[newdat$Locality=="20km Sw.murcia"] <- "20 km SW Murcia"
newdat$Locality[newdat$Locality=="15km N.coimbra"] <- "15 km N Coimbra"
newdat$Locality[newdat$Locality=="3 Km Ne Quarteira, N 37º04'23\" W 08º04'05\""] <- "3 km NE Quarteira"
newdat$Locality[newdat$Locality=="3 Km Nw Monchique"] <- "3 km NW Monchique"
newdat$Locality[newdat$Locality=="30km E.cartagena"] <- "30 km E Cartagena"
newdat$Locality[newdat$Locality=="30km E.carthagena"] <- "30 km E Cartagena"
newdat$Locality[newdat$Locality=="30km Sw.almeria"] <- "30km SW Almería"
newdat$Locality[newdat$Locality=="30 Km Sw Almeria"] <- "30km SW Almería"
newdat$Locality[newdat$Locality=="5km Sw.ronda"] <- "5 km SW Ronda"
newdat$Locality[newdat$Locality=="8km Zw.malaga"] <- "8 km SW Málaga"
newdat$Locality[newdat$Locality=="10 Km W. Van Jaca"] <- "10 km W Van Jaca"
newdat$Locality[newdat$Locality=="20 Km Ne Ronda"] <- "20 Km NE Ronda"
newdat$Locality[newdat$Locality=="25 Km Sw Cartagena"] <- "25 km SW Cartagena"
newdat$Locality[newdat$Locality=="2km E.póvoa de Varzim"] <- "2 km E Póvoa de Varzim"
newdat$Locality[newdat$Locality=="35km Ne.plasencia"] <- "35 km NE Plasencia"
newdat$Locality[newdat$Locality=="Albufeira, Hapimag, N 37º04'33\" W 08º17'37\""] <- "Albufeira, Hapimag"
newdat$Locality[newdat$Locality=="Albufeira, Torre Velhas, N 37º04'38\" W 08º17'55\""] <- "Albufeira, Torre Velhas"
newdat$Locality[newdat$Locality=="Alcuzcuz, North of San Pedro de Alcã£Ntara"] <- "Alcuzcuz, North of San Pedro de Alcántara"
newdat$Locality[newdat$Locality=="Almuã±Ã©Car"] <- "Almuñécar"
newdat$Locality[newdat$Locality=="Almuã±Ã©Car, Beach"] <- "Almuñécar"
newdat$Locality[newdat$Locality=="Almuã±Ã©Car, Granada"] <- "Almuñécar"
newdat$Locality[newdat$Locality=="AlmunãCar"] <- "Almuñécar"
newdat$Locality[newdat$Locality=="Almunecar"] <- "Almuñécar"
newdat$Locality[newdat$Locality=="Brito, N 37º12'18\" W 08º12'16\""] <- "Brito"
newdat$Locality[newdat$Locality=="Brito, N 37º13'59\" W 08º09'50\""] <- "Brito"
newdat$Locality[newdat$Locality=="C´?¢Diz"] <- "Cádiz"
newdat$Locality[newdat$Locality=="Coto doñana: See Coto de doñana, Parque Nacional"] <- "Parque Nacional de Doñana"
newdat$Locality[newdat$Locality=="Coto donana"] <- "Parque Nacional de Doñana"
newdat$Locality[newdat$Locality=="Coto doñana"] <- "Parque Nacional de Doñana"
newdat$Locality[newdat$Locality=="Foz do laje, N 37º14'42\" W 08º30'27\""] <- "Foz do laje"
newdat$Locality[newdat$Locality=="Guö?¡A de Isora; Llano de la Santidad (Pn Teide)"] <- "Guía de Isora; Llano de la Santidad (PN del Teide)"
newdat$Locality[newdat$Locality=="Guö?¡A de Isora; Zanjones, los (Pn Teide)"] <- "Guía de Isora; Zanjones (PN del Teide)"
newdat$Locality[newdat$Locality=="Helechar (Bada Joz)"] <- "Helechar (Badajoz)"
newdat$Locality[newdat$Locality=="Helechar, Badajoz"] <- "Helechar (Badajoz)"
newdat$Locality[newdat$Locality=="Hervã¡S"] <- "Hervás"
newdat$Locality[newdat$Locality=="Hervas"] <- "Hervás"
newdat$Locality[newdat$Locality=="Hispania: See Spain, Kingdom of"] <- NA
newdat$Locality[newdat$Locality=="Hostalets de Baleny?Á"] <- "Balenyá"
newdat$Locality[newdat$Locality=="Jbiza (Also As 'Ibiza' Or ' Iviza'), Town of"] <- "Ibiza"
newdat$Locality[newdat$Locality=="Jerez de la Froutera"] <- "Jerez de la Frontera"
newdat$Locality[newdat$Locality=="Jerez: See Jerez de la Frontera"] <- "Jerez de la Frontera"
newdat$Locality[newdat$Locality=="Jimena: See Jimena de la Frontera"] <- "Jerez de la Frontera"
newdat$Locality[newdat$Locality=="La Coruña, Provincia de"] <- "La Coruña"
newdat$Locality[newdat$Locality=="Mazagã³N"] <- "Mazagón"
newdat$Locality[newdat$Locality=="Mazarron"] <- "Mazarrón"
newdat$Locality[newdat$Locality=="Sabinanigo, 42â°32'N-0â°23'W"] <- "Sabiñánigo"
newdat$Locality[newdat$Locality=="Sabinanigo"] <- "Sabiñánigo"
newdat$Province[newdat$Locality=="Sacromonte / Granada"] <- "Granada"
newdat$Locality[newdat$Locality=="Sacromonte / Granada"] <- "Sacromonte"
newdat$Locality[newdat$Locality=="Sallent 42 Â° 45' N- 0 Â° 20' W"] <- "Sallent de Gállego"
newdat$Locality[newdat$Locality=="Sallent de Gã¡Llego"] <- "Sallent de Gállego"
newdat$Locality[newdat$Locality=="Sallent de Gã¡Llego, 42â°45' N-0â°20' W"] <- "Sallent de Gállego"
newdat$Locality[newdat$Locality=="Sallent de Gallego"] <- "Sallent de Gállego"
newdat$Locality[newdat$Locality=="Valley of Ordesa [Ordesa Valley], Pyrenees"] <- "Valle de Ordesa"
newdat$Locality[newdat$Locality=="Velez Mã Lã Ga 7 Km N"] <- "Velez, 7 km N Málaga"
newdat$Locality[newdat$Locality=="Velez Mã¡Laga, 7 Km N."] <- "Velez, 7 km N Málaga"
newdat$Locality[newdat$Locality=="Vï¿½Lez de Benaudalla"] <- "Vélez de Benaudalla"
newdat$Locality[newdat$Locality=="Villabã¡Ã±Ez"] <- "Villabáñez"
newdat$Locality[newdat$Locality=="Villabanez"] <- "Villabáñez"
newdat$Locality[newdat$Locality=="Villab´?¢´?¢Ez"] <- "Villabáñez"
newdat$Locality[newdat$Locality=="?Übeda"] <- "Úbeda"
newdat$Locality[newdat$Locality=="?Sandosa"] <- "Sandosa"
newdat$Locality[newdat$Locality=="?Avoberal"] <- "Avoberal"
newdat$Locality[newdat$Locality=="??Vila Franca"] <- "Vila Franca"
newdat$Locality[newdat$Locality=="40 Km Sse of Zaragoza, Belchite"] <- "40 Km SE of Zaragoza, Belchite"
newdat$Locality[newdat$Locality=="40km N.tortosa"] <- "40km N Tortosa"
newdat$Locality[newdat$Locality=="4km S.betancuria"] <- "4km S Betancuria"
newdat$Locality[newdat$Locality=="5km O.alhaurin el Grande"] <- "5km O Alhaurin el Grande"
newdat$Locality[newdat$Locality=="60 Km Ne of Alicante, Vall de laguar, Fleix"] <- "60 km NE of Alicante, Vall de laguar, Fleix"
newdat$Locality[newdat$Locality=="8km Sw.orgiva"] <- "8 km SW Orgiva"
newdat$Locality[newdat$Locality=="ÃCjia"] <- "Écija"
newdat$Locality[newdat$Locality=="Albergue Universitario; G´?¢Ejar Sierra; Sierra N	2550	19940712	Ortiz, J	Gbif,2015	Ku"] <- "Albergue Universitario de Sierra Nevada - Güejar Sierra"
newdat$Locality[newdat$Locality=="Alarã³"] <- "Alaró"
newdat$Locality[newdat$Locality=="Albarracã­n 1200 M³"] <- "Albarracín"
newdat$Locality[newdat$Locality=="Albarracin"] <- "Albarracín"
newdat$Locality[newdat$Locality=="Albarracin (800m)"] <- "Albarracín"
newdat$Locality[newdat$Locality=="Albarracín, Sierra de"] <- "Albarracín"
newdat$Locality[newdat$Locality=="Albufeira de Montagil"] <- "Albufeira de Montargil"
newdat$Locality[newdat$Locality=="Albufeira de Montargil"] <- "Albufeira de Montargil"
newdat$Locality[newdat$Locality=="Albunol"] <- "Albuñol"
newdat$Locality[newdat$Locality=="Alcala de Henares"] <- "Alcalá de Henares"
newdat$Locality[newdat$Locality=="Alcalá de los Gázules"] <- "Alcalá de los Gazules"
newdat$Province[newdat$Locality=="Alcala: See Alcalá de Chivert"] <- "Castellón"
newdat$Locality[newdat$Locality=="Alcala: See Alcalá de Chivert"] <- "Alcalá de Xivert"
newdat$Locality[newdat$Locality=="7 Km Sw of Toro"] <- "7 km SW of Toro"
newdat$Locality[newdat$Locality=="Ado Pinto???, Near Santarem"] <- "Near Santarem"
newdat$Locality[newdat$Locality=="Aguirre, Barranco del"] <- "Barranco del Aguirre"
newdat$Locality[newdat$Locality=="Alba de los Cardaï¿½Os"] <- "Camino de la Binesa, Velilla del Río Carrión"
newdat$Locality[newdat$Locality=="Albaizin: See el Albaicín"] <- "Albaicín (Granada)"
newdat$Locality[newdat$Locality=="Alhama de Aragã³N"] <- "Alhama de Aragón"
newdat$Locality[newdat$Locality=="Alhama: See Alhama de Granada"] <- "Alhama de Granada"
newdat$Locality[newdat$Locality=="Alhama: See Alhama de Murcia"] <- "Alhama de Murcia"
newdat$Locality[newdat$Locality=="Alhamilla, Sierra de"] <- "Sierra Alhamilla"
newdat$Locality[newdat$Locality=="Alhaurin de la Torre"] <- "Alhaurín de la Torre"
newdat$Province[newdat$Locality=="Alicante, Provincia de"] <- "Alicante"
newdat$Locality[newdat$Locality=="Alicante, Provincia de"] <- NA
newdat$Province[newdat$Locality=="Almería, Provincia de"] <- "Alicante"
newdat$Locality[newdat$Locality=="Almería, Provincia de"] <- NA
newdat$Locality[newdat$Locality=="Andalucía [Spanish]; Andalusia [Conventional]"] <- "Andalucía"
newdat$Locality[newdat$Locality=="Andalusia: See Andalucía"] <- "Andalucía"
newdat$Locality[newdat$Locality=="Arandade Duero"] <- "Aranda de Duero"
newdat$Locality[newdat$Locality=="Arantzazu / 20567 Arantzazu, Gipuzkoa, Spain"] <- "Aránzazu"
newdat$Locality[newdat$Locality=="Arantzazu"] <- "Aránzazu"


l <- as.data.frame(unique(newdat$Locality))


#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

#####################################################################################---
#Add data internet ----

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
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)


#####################################################################################---
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


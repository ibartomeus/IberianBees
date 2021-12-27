#####################################################################################

#In this script the different unprocessed csvs from rawdata/csvs/
#are edited to match a default template and joined together

#####################################################################################
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

#set up----
#Load functions NOW is manually done from cleaner repo
library(cleanR)
check <- define_template(data, NA)

#Load library mgrs
#install.packages("remotes") #Install remotes if not installed
#remotes::install_gitlab("hrbrmstr/mgrs") #there are other alternatives in the repo for installation
library(dplyr)
library(tidyr) 

#####################################################################################
#ADD DATA NOW
#####################################################################################
# 1_Ornosa_etal

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

#####################################################################################
# 2_Ornosa_etal

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

#####################################################################################
# 3_Montero_etal

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

#Fix author name IML to IM Liberal
newdat$Collector <- gsub("IML", "IM Liberal", newdat$Collector)

#Convert DOI to link
levels(factor(newdat$Reference.doi))
newdat$Reference.doi <- paste0("https://doi.org/",newdat$Reference.doi)
#Both links work

write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
#keep track of expected length
size <- size + nrow(newdat)

#####################################################################################
# 4_Arroyo-Correa

#The following items are done before the functions were up and running.
#Add data BAC ----
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

#####################################################################################
# 5_Banos-Picon_etal

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

#####################################################################################
# 6_Moreira

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

#####################################################################################
# 7_Ornosa

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

#####################################################################################
# 8_Ornosa

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

#####################################################################################
# 9_Ornosa

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

#####################################################################################
# 10_Ornosa_etal

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

#####################################################################################
# 11_Ornosa_etal

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

#####################################################################################
# 12_Ornosa_etal

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

#####################################################################################
# 13_Gomez

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

#####################################################################################
#14_Marshall

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

#####################################################################################
# 15_Bartomeus_etal

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

#####################################################################################
# 16_Carvalho

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

#####################################################################################
# 17_Carvalho
#newdat <- read.csv(file = "rawdata/csvs/17_Carvalho.csv")
#Is the same as 16_Carvalho, no need to add it
#####################################################################################
# 18_Castro_etal

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

#####################################################################################
# 19_Kuhlmann_etal

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

#####################################################################################
# 20_Gayubo

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

##################################################################################### 
# 21_Boieiro_etal

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

##################################################################################### 
# 22_Nunez

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

##################################################################################### 
# 23_Costa

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

##################################################################################### 
#24_Magrach

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

##################################################################################### 
# 25_Trillo

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

##################################################################################### 
# 26_Ornosa_etal (Old file name Vicente Martínez-López, maybe rename to Martinez?)

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

##################################################################################### 
# 27_Azpiazu_etal

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

##################################################################################### 
# 28_Roberts.csv

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

##################################################################################### 
# 29_Hormaza_etal

help_structure()
newdat <- read.csv(file = 'rawdata/csvs/29_Hormaza_etal.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, '29_Hormaza_etal_')
write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

##################################################################################### 
# 30_Lazaro_etal

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
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)
##################################################################################### 
# 31_Diaz-Calafat

help_structure()
newdat <- read.csv(file = 'rawdata/csvs/31_Diaz-Calafat.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, '31_Diaz-Calafat_')
write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

##################################################################################### 
# 32_Valverde

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
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

##################################################################################### 
# 33_Lara-Romero_etal

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
newdat$Reference..doi. <- "10.1111/1365-2435.12719" #I assume a single paper
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

##################################################################################### 
# 34_dePablos

help_structure()
newdat <- read.csv('rawdata/csvs/34_dePablos.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
#extract_pieces()
#help_geo()
#help_species()
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, '34_dePablos_')
write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

##################################################################################### 
# 35_Magrach

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
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

##################################################################################### 
# 36_Nunez

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
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

##################################################################################### 
# 37_Ortiz_etal

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
newdat$Authors.to.give.credit <- "Ortiz, Ornosa, Torres"
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, '37_Ortiz_etal_')
write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

##################################################################################### 
# 38_Ortiz_etal

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
newdat$Authors.to.give.credit <- "Ortiz, Torres, Ornosa"
newdat <- add_uid(newdat = newdat, '38_Ortiz_etal_')
write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

##################################################################################### 
# 39_Ortiz_etal

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
newdat$Authors.to.give.credit <- "Ortiz, Torres, Ornosa"
newdat <- add_uid(newdat = newdat, '39_Ortiz_etal_')
write.table(x = newdat, file = 'data/data.csv',
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

##################################################################################### 
# 40_Gonzalez

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
newdat <- add_uid(newdat = newdat, '40_Gonzalez_')
write.table(x = newdat, file = 'data/data.csv',
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

##################################################################################### 
# 41_Torres

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
newdat <- add_uid(newdat = newdat, '41_Torres_')
write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

##################################################################################### 
# 42_Ornosa_etal

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
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

##################################################################################### 
# 43_Alvarez_etal
 
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
unique(newdat$Month) #THIS CAN BE DEPURATED e.g. month 18
newdat$Authors.to.give.credit <- "compiled by P. Alvarez and M. Paris"
newdat <- add_uid(newdat = newdat, '43_Alvarez_etal_')
write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

##################################################################################### 
# 44_Ornosa

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
newdat <- add_uid(newdat = newdat, '44_Ornosa_')
write.table(x = newdat, file = 'data/data.csv', quote = TRUE, sep = ',', col.names = FALSE, row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

##################################################################################### 
# 45_Nunez

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
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

##################################################################################### 
# 46_Obeso

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
newdat$Reference.doi <- "10.1007/s00442-013-2731-7"
newdat$Authors.to.give.credit <- "EF Ploquin, JM Herrera, JR Obeso"
#extract_pieces()
#help_geo()
#help_species()
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)  
newdat <- add_uid(newdat = newdat, '46_Obeso_')
write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE,
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

##################################################################################### 
# 47_Collado_etal

help_structure()
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
newdat <- add_uid(newdat = newdat, '47_Collado_etal_')
summary(newdat)
write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE,
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

##################################################################################### 
# 48_Casimiro-Soriguer_etal

help_structure()
newdat <- read.csv(file = 'rawdata/csvs/48_Casimiro-Soriguer_etal.csv', sep = ";")
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, '48_Casimiro-Soriguer_etal_')
write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

##################################################################################### 
# 49_Ornosa_etal.csv

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
newdat <- add_uid(newdat = newdat, '49_Ornosa_etal_')
write.table(x = newdat, file = 'data/data.csv', 
    quote = TRUE, sep = ',', col.names = FALSE, 
    row.names = FALSE, append = TRUE)
size <- size + nrow(newdat) #keep track of expected length

##################################################################################### 
# 50_Heleno_etal

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
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)
##################################################################################### 
# 51_Minarro

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
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

##################################################################################### 
# 52_Picanco

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
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

##################################################################################### 
# 53_Ferrero

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
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

##################################################################################### 
# 54_Wood_etal

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
newdat$Locality[12]
gsub("[^[:alnum:]]", "_", newdat$Locality[12])
newdat$Locality <- as.character(newdat$Locality)
newdat$Locality <- gsub("[^[:alnum:]]", "", newdat$Locality)
#write
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)
size <- size + nrow(newdat)

##################################################################################### 
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


##################################################################################### 
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


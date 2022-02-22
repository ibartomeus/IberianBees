source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 13_Gomez ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/13_Gomez.csv', sep = ";")
head(newdat)

#Check vars
compare_variables(check, newdat)

#Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Plant_species')] <- 'Flowers.visited' 
colnames(newdat)[which(colnames(newdat) == 'Frequency.of.visits')] <- 'Not.specified' 

#Fix date
(temp <- extract_date(newdat$Date, "%d/%m/%Y"))
newdat$Day <- ifelse(is.na(newdat$Day), temp$day, newdat$Day)
newdat$Month <- as.character(newdat$Month)
newdat$Month <- ifelse(as.character(newdat$Month) == "", as.character(temp$month), newdat$Month)
newdat$Month[newdat$Month=="August"] <- "08"
newdat$Year <- as.character(newdat$Year)
newdat$Year <- ifelse(newdat$Year == "", temp$year, newdat$Year)

#Fix some years
levels(factor(newdat$Year))
newdat$Year[newdat$Year=="Iberideae"] <- NA
#Some have two dates on them...
#Maybe just show one of them? 
#Just showing the fisrt one for now
newdat$Year <- sub("-.*", "", newdat$Year)

#Fill genus, spp and subspecies cols
newdat$Genus <- word(newdat$GenSp, 1)
newdat$Species <- word(newdat$GenSp, 2)
newdat$Subspecies <- word(newdat$GenSp, 3)

#Add missing vars and drop
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Add country, all records seem that are from Spain
newdat$Country <- "Spain"
newdat$Province[newdat$Province=="Canarias"] <- "Islas Canarias"
newdat$Province[newdat$Province=="Almeria"] <- "Almería"
newdat$Province[newdat$Province=="Avila"] <- "Ávila"
newdat$Province[newdat$Province=="Cadiz"] <- "Cádiz"
newdat$Province[newdat$Province=="Aragon"] <- NA
newdat$Province[newdat$Province=="Extremadura"] <- NA

#Substitute underscore by space
newdat$Flowers.visited <- gsub("\\_", " ", newdat$Flowers.visited)

#Credit
newdat$Authors.to.give.credit <- "Compiled by J.M. Gomez"

#Fix this, gives issues when merge all datasets
newdat$Locality[newdat$Locality=="S\" Baza"] <-"Sierra de Baza"

#Clean some species names
#Na's on genus
newdat <- newdat %>% filter(!is.na(Genus))
#Fix lower case
newdat$Genus <- gsub("andrena", "Andrena", newdat$Genus, fixed=T)

#Fix species name
#1st
newdat$Species[newdat$Species=="~aestivalis"] <- NA
newdat$Subspecies[newdat$Subspecies=="~aestivalis"] <- NA
#2nd
newdat$Species[newdat$Species=="abd"] <- NA
newdat$Subspecies[newdat$Subspecies=="negro"] <- NA
#3rd
newdat$Species[newdat$Species=="muy"] <- NA
newdat$Subspecies[newdat$Subspecies=="pequeña"] <- NA
#4th
newdat$Subspecies[newdat$Species=="aff"] <- NA
newdat$Species[newdat$Species=="aff"] <- NA
#5th
newdat$Species[newdat$Species==""] <- NA
newdat$Subspecies[newdat$Subspecies==""] <- NA
#6th
newdat$Species[newdat$Species=="sp"] <- NA
#7th
newdat$Species[newdat$Species=="simplex,"] <- "simplex"
newdat$Species[newdat$Species=="grande"] <- NA
newdat$Species[newdat$Species=="antena"] <- NA
newdat$Species[newdat$Species=="clipeo"] <- NA
newdat$Species[newdat$Species=="clípeo"] <- NA
#8th
newdat$Subspecies[newdat$Subspecies=="abdomen"] <- NA
newdat$Subspecies[newdat$Subspecies=="ssp."] <- NA
newdat$Subspecies[newdat$Subspecies=="y"] <- NA
newdat$Subspecies[newdat$Subspecies=="negra"] <- NA
newdat$Subspecies[newdat$Subspecies=="larga"] <- NA
newdat$Subspecies[newdat$Subspecies=="amarillo"] <- NA
newdat$Subspecies[newdat$Subspecies=="Andrena"] <- NA
#9th
newdat$Species[newdat$Species=="humlis"] <- "humilis"
#10th
newdat$Species[newdat$Species=="subge"] <- NA
newdat$Subgenus[newdat$Subspecies=="micrandrena"] <- "Micrandrena"
newdat$Subspecies[newdat$Subspecies=="micrandrena"] <-NA
#11th
newdat$Species[newdat$Species=="nigraenea"] <- "nigroaenea"
#12th
newdat$Species[newdat$Species=="pelirroja"] <- NA
#13th
newdat$Species[newdat$Genus=="Andrena_nigroaenea"] <- "nigroaenea"
newdat$Genus[newdat$Genus=="Andrena_nigroaenea"] <- "Andrena"
#14th
newdat$Species[newdat$Genus=="Apis_mellifera"] <- "mellifera"
newdat$Genus[newdat$Genus=="Apis_mellifera"] <- "Apis"

#Add unique identifier
newdat <- add_uid(newdat = newdat, '13_Gomez_')

write.table(x = newdat, file = 'Data/Processed_raw_data/13_Gomez.csv', 
            quote = TRUE, sep = ',', col.names = TRUE,
            row.names = FALSE)

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

#Fix this, gives issues when merge all datasets
newdat$Locality[newdat$Locality=="S\" Baza"] <-"Sierra de Baza"

#Add unique identifier
newdat <- add_uid(newdat = newdat, '13_Gomez_')

write.table(x = newdat, file = 'Data/Processed_raw_data/13_Gomez.csv', 
            quote = TRUE, sep = ',', col.names = TRUE,
            row.names = FALSE)
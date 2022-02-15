source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 18_Castro_etal ----

#Read data
newdat <- read.csv(file = "Data/Rawdata/csvs/18_Castro_etal.csv")

#Just to see them both in two lines
colnames(newdat)[10] <- "precision" 
colnames(newdat)[which(colnames(newdat) == 'precision')] <- 'Coordinate.precision' 
colnames(newdat)[which(colnames(newdat) == 'day')] <- 'Day' 
colnames(newdat)[which(colnames(newdat) == 'End.Date')] <- 'End.date' 
colnames(newdat)[which(colnames(newdat) == 'Reference..doi.')] <- 'Reference.doi' 
colnames(newdat)[which(colnames(newdat) == 'COLLECTION')] <- 'Local_ID' 



#Quick way to compare colnames
head(newdat)
cbind(colnames(newdat), colnames(data)) #can be merged
summary(newdat)
#Species contains genus.
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

#Clean unsure species
newdat$Genus <- gsub("Hylaeus?", "delete", newdat$Genus, fixed=T)
newdat$Genus <- gsub("?", NA, newdat$Genus, fixed=T)
newdat$Species[grepl("?", newdat$Species,fixed=T)] <- "delete"
#delete
newdat <- newdat %>% filter(!Species=="delete")
newdat <- newdat %>% filter(!Genus=="delete")

#Fix string pattern that gives trouble when merging all files
newdat$Notes.and.queries <- gsub("AVAILABLE ON ", "", newdat$Notes.and.queries)
newdat$Notes.and.queries <- gsub("ADD AN \"A\" BEFORE COLLECTION NUMBER TO SEARCH ON ", "", newdat$Notes.and.queries, fixed=T)

#Add uid
newdat$uid <- paste("18_Castro_etal_", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/18_Castro_etal.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

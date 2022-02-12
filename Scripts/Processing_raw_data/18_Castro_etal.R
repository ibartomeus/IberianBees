source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 18_Castro_etal ----

#Read data
newdat <- read.csv(file = "Data/Rawdata/csvs/18_Castro_etal.csv")

#Just to see them both in two lines
colnames(newdat)[10] <- "precision" 
#Quick way to compare colnames
head(newdat)
newdat$uid <- paste("18_Castro_etal_", 1:nrow(newdat), sep = "")
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

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/18_Castro_etal.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE)

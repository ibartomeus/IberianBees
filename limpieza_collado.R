#Collado databasing cleaning
data<-read_csv("rawdata/Collado1.csv")
is.data.frame(data)
data$Author

#1) cleaning----
#Check Genus, Subgenus, Species, Subspecies and maybe add family.----
#strip start and end spaces
data$genus <- trimws(data$Genus)
is.factor(data$genus)
data$genus<-as.factor(data$genus)
summary(data$genus, maxsum = 1000)




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

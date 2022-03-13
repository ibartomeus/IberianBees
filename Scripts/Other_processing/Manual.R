#I don't think we will use it more, so I am not cleaning much this code.
#This created manual_checks.csv for first time.
#Now it works by appending data manually. 
#NEVER OVERWRITE.


#use fuzzy matching
to_check <- unique(missed)
checked <- c()
for(i in 1:length(to_check)){
  temp2 <- master$Genus_species[as.logical(adist(to_check[i],master$Genus_species) <= 2)]
  if(length(temp2) == 1){
    checked[i] <- temp2
  } else {
    checked[i] <- NA
  }
}
checked <- data.frame(to_check, checked, stringsAsFactors = FALSE)

#taxize here. Clean species!
library(traitbaser)
library(taxize)
#clean <- cleanSpecies(to_check[which(is.na(checked))])
#This is slow and whould be done aside and load when necessary.
#clean
#cleanSpecies("Pseudoanthidium lituratum") #Above it fails somewhere... !!!#
temp <- taxize::synonyms(to_check[which(is.na(checked$checked))], db = "itis")
synonym_ids <- grep(pattern = "acc_name", temp)
accepted_names_temp <- unlist(lapply(temp[synonym_ids], "[", "acc_name"), 
                              use.names = FALSE, recursive = FALSE)
accepted_names <- unlist(lapply(accepted_names_temp, `[[`, 1))
synonym_names <- rep(NA, length(to_check[which(is.na(checked$checked))]))
synonym_names[synonym_ids] <- accepted_names
synonims <- data.frame(to_check = to_check[which(is.na(checked$checked))], synonym_names)

#write.csv(synonims, "data/synonims.csv")

data2 <- merge(data, checked, by.x = "Genus_species", by.y = "to_check", all.x = TRUE)
data3 <- merge(data2, synonims, by.x = "Genus_species", by.y = "to_check", all.x = TRUE)
data3$questionable <- NA
data3$questionable[grep("?", data3$Species, fixed = TRUE)] <- "?"
data3$questionable[grep("???", data3$Species, fixed = TRUE)] <- "???"
data3$questionable[grep("_or_", data3$Species, fixed = TRUE)] <- "_or_"
data3$questionable[grep(" o ", data3$Species, fixed = TRUE)] <- " o "
data3$questionable[grep("_agg", data3$Species, fixed = TRUE)] <- "_agg"
data3$questionable[grep("s.l.", data3$Species, fixed = TRUE)] <- "s.l."
data3$questionable[grep("/", data3$Species, fixed = TRUE)] <- "/"
data3$questionable[grep("-alike", data3$Species, fixed = TRUE)] <- "-alike"
head(data3)

for_thomas <- data3[which(!is.na(data3$flag)),]
colnames(for_thomas)
dim(for_thomas)
forThomasUnique <- unique(for_thomas[,30:33])
dim(forThomasUnique) #340
unique(forThomasUnique$checked)
unique(forThomasUnique$synonym_names)
length(forThomasUnique$questionable[!is.na(forThomasUnique$questionable)])
for_thomas$accepted_name <- NA
for_thomas$accepted_subspecies <- NA
for_thomas$Notes <- NA
#DO NOT OVERWRITE
#write.table(unique(for_thomas[,30:36]), "manual_checks.csv", sep = ";", quote = "FALSE", row.names = FALSE, col.names = TRUE)

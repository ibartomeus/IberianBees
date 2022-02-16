#Final cleaning script 

#Read compressed csv with data.table library
library(data.table)
data <- read.table("Data/iberian_bees_raw.csv.gz",  header=T, quote="\"", sep=",")
#Delete first col that are rownames
data <- data %>% select(-X)

#Delete leading and trailing spaces for all columns
library(dplyr)
data <- data %>%  mutate(across(c(colnames(data)), trimws))

#######################################-
#Cleaning of genus and subgenus names----
#######################################-
library(stringr)
#Make upper case first letter of genus
data$Genus <- str_to_title(data$Genus)

#Read iberian species masterlist to filter incorrect species names
master <- read.csv("Data/Iberian_species_masterlist.csv", stringsAsFactors = FALSE)
head(master);nrow(master); unique(master$Genus) #1055 spp and 57 genus

#Check spelling mistakes
genus <- unique(master$Genus) #correct and approved existing genus
mismatches <- unique(data$Genus[which(!data$Genus %in% genus)])

#Partial matching with possible genus typos
fixed <- c()
for(i in 1:length(mismatches)){
  temp2 <- genus[as.logical(adist(mismatches[i],genus) <= 2)]
  if(length(temp2) == 1){
    fixed[i] <- temp2
  } else {
    fixed[i] <- NA
  }
}
tesaurus <- data.frame(mismatches, fixed, stringsAsFactors = FALSE)


#Recover subgenus listed as genus
tesaurus$subgenus <- NA
head(master)
temp <- unique(master[,2:3]) #issue, here we may be missing a lot of subgenus.
replace <- temp[which(temp$Subgenus %in% mismatches[-1]),]
tesaurus2 <- merge(tesaurus, replace, by.x = "mismatches", by.y = "Subgenus", all.x = TRUE)
tesaurus2$fixed <- ifelse(is.na(tesaurus2$Genus) == FALSE, tesaurus2$Genus, tesaurus2$fixed)
tesaurus2$subgenus <- ifelse(is.na(tesaurus2$Genus) == FALSE, tesaurus2$mismatches, tesaurus2$subgenus)
tesaurus2

#Fix some things manually
tesaurus2[which(tesaurus2$mismatches == "Elis"),"fixed"] <- NA #Elis was named Apis. Need to remove
tesaurus2[which(tesaurus2$mismatches %in% c("Chalicedoma", "Chalicodoma", "Chalidocoma")),"fixed"] <- "Megachile"
tesaurus2[which(tesaurus2$mismatches %in% c("Chalicedoma", "Chalicodoma", "Chalidocoma")),"subgenus"] <- "Chalicodoma"
tesaurus2[which(tesaurus2$mismatches %in% c("Creghtorella", "Creigthonella")),"fixed"] <- "Megachile"
tesaurus2[which(tesaurus2$mismatches %in% c("Creghtorella", "Creigthonella")),"subgenus"] <- "Creightonella"
tesaurus2[which(tesaurus2$mismatches %in% c("Halcitus")),"fixed"] <- "Halictus"
tesaurus2
#Quite good overall.

#Remove non matching genus
head(data)
head(tesaurus2)
data2 <- merge(data, tesaurus2[,1:3], by.x = "Genus", by.y = "mismatches", all.x = TRUE)
data2$Genus <- ifelse(is.na(data2$fixed), data2$Genus, data2$fixed)
data2$Subgenus <- ifelse(is.na(data2$subgenus), data2$Subgenus, data2$subgenus)
data2$fixed <- NULL
data2$subgenus <- NULL
#check again after the fixes
mis <- data2$Genus[which(!data2$Genus %in% genus)]
mismatches <- unique(mis) #CHECK with Thomas / Curro none of those are bees. 
mismatches 
#exclude synonims that need to be fixed
mm <- mismatches[-which(mismatches %in% c(master$Subgenus, "Nomia", 
                                          "Tetraloniella",
                                          "Melissodes", "Haetosmia", "Trianthidium", "Peponapis"))]       

#Save removed genus
write.csv(mm, "data/genus_removed.csv")
data2$rm <- rep(NA, nrow(data2))
data2$rm[which(data2$Genus %in% mm)] <- "Remove"
data3 <- data2
head(data3)
dim(data3) #[1] 113679     29


#######################################-
#Cleaning of species names ----
#######################################-
#Non identified species are deleted directly
data <- subset(data3, !Species %in% c("sp.", "sp.1", "sp.2", "sp.3", "sp.4", "sp.5", "sp.6",
                                      "sp.7", "", "sp1", "sp2", "sp"))

#Partial string matching, convert to NA unsure species (e.g., species and after "?")
data$Species[grepl("?", data$Species, ignore.case=FALSE, fixed=TRUE)] <- NA

#Delete also species with field=NA
data <- data %>% filter(!is.na(Species))

#Some manual cleaning
#Select manually undet species
undet_species <- c("spinulosus_or_ferruginatus", "sin gáster....", "rufa/aurulenta-alike",
                   "rufa/aurulenta", "cf pyrenaica", "cf pascuorum", "(microandrena)",
                   "alfkenella o nana", "dargius/cephalotes", "ferruginatus_or_croaticus",
                   "lagopoda-maritima", "lativentre/sexnotatum/laterale",
                   "leucoleucozonium/immunitum", "malachurum/mediterraneum")
#Filter out undet species
data <- data %>% filter(!Species %in% undet_species)
#s <- data.frame(unique(data$Species)) seems ok now


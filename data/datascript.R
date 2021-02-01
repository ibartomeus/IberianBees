#This script takes data.csv and make a sanity check and updates metadata

#load data, checklist and manual checks.
data <- read.csv("data/data.csv", stringsAsFactors = FALSE) #gerenated in rawdata/Add_data.R
head(data)

master <- read.csv("data/Iberian_species_masterlist.csv", stringsAsFactors = FALSE)
head(master)
nrow(master) #1055 species!
unique(master$Genus) #57 generos

manual <- read.csv("data/manual_checks.csv", sep = ";", stringsAsFactors = FALSE, 
                   na.strings = c(NA, ""))
head(manual)

#1) cleaning----
#Check Genus, Subgenus, Species, Subspecies and maybe add family.----
#strip start and end spaces
data$Genus <- trimws(data$Genus)
data$Subgenus <- trimws(data$Subgenus)
#check spelling
genus <- unique(master$Genus)
mis <- data$Genus[which(!data$Genus %in% genus)]
mismatches <- unique(mis)
mismatches
#mispellings:fuzzy matching
fixed <- c()
#agrep is too lax, and I can't make it to work, adist is better
#agrep(c("Coleoxys"), genus, value = TRUE, max = list(all = 2))
#agrep(c("Lasius"), genus, value = TRUE, max = list(ins = 3, del = 3, sub = 2))
for(i in 1:length(mismatches)){
  temp2 <- genus[as.logical(adist(mismatches[i],genus) <= 2)]
  if(length(temp2) == 1){
    fixed[i] <- temp2
  } else {
    fixed[i] <- NA
  }
}
tesaurus <- data.frame(mismatches, fixed, stringsAsFactors = FALSE)
#recover Subgenus form ()
tesaurus$subgenus <- NA
temp <- unlist(gregexpr(pattern = "(", fixed = TRUE, text = mismatches))
for(i in which(temp > 0)){
  tesaurus$subgenus[i] <- substr(tesaurus$mismatches[i], start = temp[i]+1, 
                               stop = nchar(tesaurus$mismatches[i])-1)
  tesaurus$fixed[i] <- substr(tesaurus$mismatches[i], start = 1, 
                            stop = temp[i]-1)
}
#recover subgenus listed as genus
head(master)
temp <- unique(master[,2:3]) #issue, here we may be missing a lot of subgenus.
replace <- temp[which(temp$Subgenus %in% mismatches[-1]),]
tesaurus2 <- merge(tesaurus, replace, by.x = "mismatches", by.y = "Subgenus", all.x = TRUE)
tesaurus2$fixed <- ifelse(is.na(tesaurus2$Genus) == FALSE, tesaurus2$Genus, tesaurus2$fixed)
tesaurus2$subgenus <- ifelse(is.na(tesaurus2$Genus) == FALSE, tesaurus2$mismatches, tesaurus2$subgenus)
tesaurus2
#check
data[which(data$Genus %in% c("Elis", "Hylaeus?")),] 
tesaurus2[which(tesaurus2$mismatches == "Elis"),"fixed"] <- NA
#Quite good.

#Remove non matching genus
head(data)
head(tesaurus2)
data2 <- merge(data, tesaurus[,1:3], by.x = "Genus", by.y = "mismatches", all.x = TRUE)
data2$Genus <- ifelse(is.na(data2$fixed), data2$Genus, data2$fixed)
data2$Subgenus <- ifelse(is.na(data2$subgenus), data2$Subgenus, data2$subgenus)
data2$fixed <- NULL
data2$subgenus <- NULL
#check again after the fixes
mis <- data2$Genus[which(!data2$Genus %in% genus)]
mismatches <- unique(mis) #CHECK with Thomas
mismatches #
#exclude synonims that need to be fixed
mm <- mismatches[-which(mismatches %in% c(master$Subgenus, "Nomia", 
                         "Tetraloniella",
                         "Melissodes", "Haetosmia"))]
#write.csv(mm, "genus_removed.csv")
data2$rm <- rep(NA, nrow(data2))
data2$rm[which(data2$Genus %in% mm)] <- "Remove"
data3 <- data2
head(data3)

#Go with species----
data3$Species <- trimws(data3$Species)
#Remove species = sp or NA
unique(data3$Species)
#overwrite data #Non identifies species are removed directly.
data <- subset(data3, !Species %in% c("sp.", "sp.1", "sp.2", "sp.3", "sp.4", "sp.5", "sp.6",
                                    "sp.7", "", "sp1", "sp2"))
#IF NO NA, the next line will fail.
data <- data[-which(is.na(data$Species) == TRUE),] 
unique(data$Species)
#Move ?? and "_or_" "o" , "_agg" , "s.l.", "/" to $flag.
data$flag <- NA
#Create Gen_sp
data$Genus_species <- paste(data$Genus, data$Species)

#compare with Thomas accepted names
master$Genus_species <- paste(master$Genus, master$Species)
missed <- data$Genus_species[which(!data$Genus_species %in% master$Genus_species)]
length(missed)
unique(missed)
#flag all records not matching thomas master list.
data$flag <- ifelse(data$Genus_species %in% master$Genus_species,
                    NA, data$Genus_species)

#Manual.R If you want to use taxize to further clean the data check Manual.R.----
#Now use manual checks to update/remove species.
head(data)
head(manual)
data2 <- merge(data, 
               manual[,c("flag", "accepted_name", "accepted_subspecies")], 
               by = "flag", all.x = TRUE)
dim(data2)
head(data2)
data2$Subspecies <- ifelse(is.na(data2$accepted_subspecies), 
                           data2$Subspecies, data2$accepted_subspecies)
data2$accepted_subspecies <- NULL
#Flag removed 
head(data2)
data2$rm[which(data2$accepted_name == "Remove")] <- "Remove"
head(data2)
#recheck for new species not in manual checking.
to_check <- data2[which(!is.na(data2$flag) & 
                          is.na(data2$accepted_name) & 
                          is.na(data2$rm)),c(1,32)]
to_check$checked <- NA
to_check$synonym_names <- NA
to_check$questionable <- NA
to_check$accepted_name <- NA
to_check$accepted_subspecies <- NA
to_check$Notes <- NA
to_check <- to_check[,c("flag", "checked",
            "synonym_names", "questionable",
            "accepted_name", "accepted_subspecies", "Notes")]

#UNCOMMENT TO RUN, COMMENTED FOR SECURITY.
#write.table(unique(to_check), "data/manual_checks.csv", append = TRUE, quote = FALSE, sep = ";", row.names = FALSE, col.names = FALSE)
#Now, when the csv is manually fixed, next time those names will be fixed too.
#quite elegant.
#NOTE: Three species to fix.

#unify names
summary(as.factor(data2$accepted_name))
data2$accepted_name <- ifelse(is.na(data2$accepted_name), 
                              data2$Genus_species, data2$accepted_name)

data <- subset(data2, select = -flag)
head(data)
dim(data) 
#need to decompose genus and species again...
temp <- unlist(gregexpr(pattern = " ", fixed = TRUE, text = data$accepted_name))
#slow
for(i in which(temp > 0)){ 
  data$Species[i] <- substr(data$accepted_name[i], start = temp[i]+1, 
                               stop = nchar(data$accepted_name[i]))
  data$Genus[i] <- substr(data$accepted_name[i], start = 1, 
                            stop = temp[i]-1)
}
head(data)
tail(data)
unique(data$accepted_name)
unique(data[which(data$Genus_species != data$accepted_name),
     c("Genus", "Species", "Genus_species", "accepted_name", "rm")])
#recheck after fixes
missed <- data$accepted_name[which(!data$accepted_name %in% master$Genus_species & is.na(data$rm))]
unique(missed)
unique(data[which(!data$accepted_name %in% master$Genus_species),c(29:31)])
unique(data[which(!data$accepted_name %in% master$Genus_species & is.na(data$rm)),c(29:31)])

#Good!
colnames(data)[30] <- "original_species"

unique(data$Subspecies)
data$Subspecies[which(data$Subspecies == "")] <- NA
data$Subspecies <- gsub("ssp. ", "", data$Subspecies, fixed = TRUE)
data$Subspecies <- gsub("ssp.", "", data$Subspecies, fixed = TRUE)
data$Subspecies <- gsub("spp.", "", data$Subspecies, fixed = TRUE)
data$Subspecies <- trimws(data$Subspecies)
unique(data$Subspecies)
#Check
unique(data[which(!data$accepted_name %in% master$Genus_species & is.na(data$rm)),c(29:31)])

#Check Country Province Locality----
unique(data$Country) 
data$Country <- ifelse(data$Country %in% c("España", "SPAIN"), "Spain", data$Country)
unique(data$Country) 
unique(data$Province) #Need to fix several. It can wait.
unique(data$Locality) #some " " at the end of the string can be striped, 
#Not done for now. use trimws

#Check Latitude Longitude Coordinate.precision----
#data$Latitude <- as.numeric(as.character(data$Latitude))
max(data$Latitude, na.rm = TRUE) < 44.15 #expect TRUE for Iberia
min(data$Latitude, na.rm = TRUE) > 35.67 #expect TRUE
#unique(data[which(data$Latitude < 35.67),"Province"]) #canary Islands
#data <- subset(data, Province != "Canary Islands")
#unique(data[which(data$Latitude < 35.67),]) #Melilla, etc... some can be potentially recovered
max(data$Longitude, na.rm = TRUE) < 4.76 
#unique(data[which(data$Longitude < 4.76),]) 
#unique(data[which(data$Longitude > 4.76), "Authors.to.give.credit"]) #idem.
min(data$Longitude, na.rm = TRUE) > -10.13

#bound
#outs
removed <- subset(data, Latitude > 44.15 | Latitude < 35.67 | 
         Longitude > 4.76 | Longitude < -10.13)
str(removed) #1600 records... 
#ADD THOSE TO REMOVED
removed[,5:6] #Most Canary Islands, Azores and melilla. A few can be traced down, but now is unpractical.
data$rm <- ifelse(is.na(data$Latitude), data$rm, 
                   ifelse(data$Latitude > 44.15 | data$Latitude < 35.67 | 
                    data$Longitude > 4.76 | data$Longitude < -10.13, "Remove", data$rm))
colnames(data)
unique(data[which(!data$accepted_name %in% master$Genus_species & is.na(data$rm)),c(7:9,29:31)])

unique(data$Coordinate.precision) 
data$Coordinate.precision <- ifelse(data$Coordinate.precision %in% c("uncert. < than 1km"),
                                    "<1km", data$Coordinate.precision)
data$Coordinate.precision <- ifelse(data$Coordinate.precision %in% c("0,1 km"),
                                    "<100m", data$Coordinate.precision)
data$Coordinate.precision <- ifelse(data$Coordinate.precision %in% c("gps", "GPS; ~400m",
                                                                     "GPS"),
                                    "GPS", data$Coordinate.precision)
data$Coordinate.precision <- ifelse(data$Coordinate.precision %in% c("uncert. < than 10km"),
                                    "<10km", data$Coordinate.precision)
data$Coordinate.precision <- ifelse(data$Coordinate.precision %in% c("uncert. < than 100km"),
                                    "<100km", data$Coordinate.precision)
data$Coordinate.precision <- ifelse(data$Coordinate.precision %in% c("3 km"),
                                    "<3km", data$Coordinate.precision)
data$Coordinate.precision <- ifelse(data$Coordinate.precision %in% c("<5Km"),
                                    "<5km", data$Coordinate.precision)
data$Coordinate.precision <- ifelse(data$Coordinate.precision %in% c("0.01", "0.001"),
                                    "<10m", data$Coordinate.precision)
data$Coordinate.precision <- ifelse(data$Coordinate.precision %in% c("","true", "false"),
                                    NA, data$Coordinate.precision)
#Check false and true, probably coming from Gbif/iNat
unique(data$Coordinate.precision) 

#Check Year Month Day Start.date End.date -----
unique(data$Year) 
unique(data$Month) #fix months! + #Idem as year :(
data$Month <- ifelse(data$Month %in% c("July"),
                                    7, data$Month)
data$Month <- ifelse(data$Month %in% c("July"),
                     7, data$Month)
data$Month <- ifelse(data$Month %in% c("June"),
                     6, data$Month)
data$Month <- ifelse(data$Month %in% c("May"),
                     5, data$Month)
data$Month <- ifelse(data$Month %in% c("April"),
                     4, data$Month)
data$Month <- ifelse(data$Month %in% c("March"),
                     3, data$Month)
data$Month <- ifelse(data$Month %in% c("Feb/March"),
                     3, data$Month)
data$Month <- ifelse(data$Month %in% c("April/May"),
                     5, data$Month)
data$Month <- ifelse(data$Month %in% c("May/June"),
                     5, data$Month)
data$Month <- ifelse(data$Month %in% c("February"),
                     2, data$Month)
data$Month <- ifelse(data$Month %in% c(""),
                     NA, data$Month)
unique(data$Month)
data$Month <- as.numeric(data$Month)
unique(data$Month)
unique(data$Day) 
data$Day <- ifelse(data$Day %in% c("5/15"),
                     10, data$Day)
data$Day <- ifelse(data$Day %in% c("21/26"),
                     23, data$Day)
data$Day <- ifelse(data$Day %in% c("19/21"),
                     20, data$Day)
data$Day <- ifelse(data$Day %in% c("4/5"),
                     4, data$Day)
data$Day <- ifelse(data$Day %in% c("See Notes page."),
                     NA, data$Day)
data$Day <- ifelse(data$Day %in% c("23/30"),
                     26, data$Day)
data$Day <- ifelse(data$Day %in% c("13/16"),
                     14, data$Day)
data$Day <- ifelse(data$Day %in% c("24/30"),
                     27, data$Day)
data$Day <- ifelse(data$Day %in% c("17/20"),
                     18, data$Day)
data$Day <- ifelse(data$Day %in% c(""),
                   NA, data$Day)
unique(data$Day) 
data$Day <- as.numeric(data$Day)
summary(data$Day) 

unique(data$Start.date) 
unique(data$End.date) 
#Se puede calculat mean day's y months cuando estos son NA?

#Check Collector, Determined.by-----
unique(data$Collector) 
#Maybe iNaturalist users can have a prefix? 
#some encoding bugs, 
#a couple of "-264761682" and similars... provide as is.
unique(data$Determined.by) #similar here, as iNat... 
#Here we can have a list of Trusted Taxonomists?

#Check Female Male Worker Not.specified-----
#Fuck, male and female factors!! Why!!
unique(data$Male)
data$Male[which(is.na(data$Male))] <- 0
data$Female[which(is.na(data$Female))] <- 0
data$Worker[which(is.na(data$Worker))] <- 0
data$Not.specified[which(is.na(data$Not.specified))] <- 0
Total <- data$Male + data$Female + data$Worker + data$Not.specified
summary(Total) #Total = 0 imply Not.specified should = 1.
data$Not.specified <- ifelse(data$Not.specified > 0, data$Not.specified, 1)
#FIX! CHECK THIS AS WE ARE INFLATING CAPTURES: USE TOTAL!!
#Add total column?

#Check Reference.doi, Flowers.visited, Local_ID, Authors.to.give.credit----
unique(data$Reference.doi) 
#In the future we can test format AND retrieve paper info in another table
#This one is fuck up: 10.1111/1365-2745.13334 in excel.
#Also: DOI 10.1007/s11258-013-0247-1
#For anna montero, maybe select just one doi?
unique(data$Flowers.visited)
#remove "" <- NA
#Gsub "_" " ".
#"nido", "Al vuelo", "No ensayo", "HIBERNATING" Remove? Move to comments?
#Quite good. Provide as.is.
#strip final " ".
unique(data$Local_ID) #as.is
unique(data$Authors.to.give.credit) #list of coautors
#Can be pasted, then split by , and create new dataset where total records is added?

#Check Any.other.additional.data, Notes.and.queries -----
unique(data$Any.other.additional) 
unique(data$Notes.and.queries)
#NEEDS FURTHER CHECKING to FLAG column?

#2) Flags and consolidating bbdd----
#species in the sea (ignore for now?)
#Remove duplicates? (ignore for now)
#Trusted column? (ignore for now)

#how to sort it? and remove some internal data for publishing?
data <- data[order(data$accepted_name),]
head(data)

data_f <- subset(data, !rm %in% c("Remove"), select = -rm)
unique(data_f$accepted_name)
unique(data[which(!data$accepted_name %in% master$Genus_species),c(29:31)])
removed <- subset(data, rm == "Remove")
dim(data_f)
dim(removed)
head(data_f)
head(removed)
removed[,c("Province", "uid", "accepted_name")]

#Write new file-----
write.table(x = data_f, file = "data/data_clean.csv", 
            quote = TRUE, sep = ",",
            row.names = FALSE)

write.table(x = removed, file = "data/removed.csv", 
            quote = TRUE, sep = ",",
            row.names = FALSE)

#NEED TO ADD TAXONOMY TO FINAL DATA (easy)

#Old Notes:----
#Make automatic tests for this things.
#flowers species with Genus_spcies -> change in bulk.
#questions: flowers species visited list more than one flower, comma separated. Fix Later
#newdat$Reference..doi. several doi's listed "," and "and" separated. Fix later? What to do with dois?
#remove duplicates?
#create column of trusted / untrusted.
#summaries -> how to separate authors? 
  
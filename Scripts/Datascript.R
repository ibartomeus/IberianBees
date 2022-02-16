#This script takes data.csv and make a sanity check and updates metadata

#load data, checklist and manual checks.
data <- read.csv("data/data.csv", stringsAsFactors = FALSE) #gerenated in rawdata/Add_data.R
head(data)
str(data)
dim(data) #91260

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
genus <- unique(master$Genus) #correct and approved existing genus
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
#remove "_"
tesaurus2$fixed <- gsub("_", "", tesaurus2$fixed) #to recover an Andrena_
#fix some things manually
tesaurus2[which(tesaurus2$mismatches == "Elis"),"fixed"] <- NA #Elis was named Apis. Need to remove
tesaurus2[which(tesaurus2$mismatches %in% c("Chalicedoma", "chalicodoma", "Chalidocoma")),"fixed"] <- "Megachile"
tesaurus2[which(tesaurus2$mismatches %in% c("Chalicedoma", "chalicodoma", "Chalidocoma")),"subgenus"] <- "Chalicodoma"
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
#write.csv(mm, "data/genus_removed.csv")
data2$rm <- rep(NA, nrow(data2))
data2$rm[which(data2$Genus %in% mm)] <- "Remove"
data3 <- data2
head(data3)
dim(data3) #91260

#Go with species----
data3$Species <- trimws(data3$Species)
#Remove species = sp or NA
unique(data3$Species)
#overwrite data #Non identified species are removed directly.
data <- subset(data3, !Species %in% c("sp.", "sp.1", "sp.2", "sp.3", "sp.4", "sp.5", "sp.6",
                                    "sp.7", "", "sp1", "sp2", "sp"))

#remove numbers.
numbers <- unlist(grepl("[[:digit:]]", data$Species))
#data[which(numbers == TRUE),3]
#WARNING: this just identifies a species called "on Echium no. 49\\,NA,,,,NA,NA,,NA,NA,NA,NA,//"
# This is likely a processing error and can be fixed somewhere, when there is time.
data <- data[-which(numbers == TRUE),]
dim(data) #89779

#If no NA, the next line will fail.
if(length(which(is.na(data$Species) == TRUE)) > 0){
  data <- data[-which(is.na(data$Species) == TRUE),] 
}
unique(data$Species)
#Move ?? and "_or_" "o" , "_agg" , "s.l.", "/" to $flag.
data$flag <- NA

#FOR JOSE: KEEP WORKING FROM HERE

#Create Gen_sp
data$Genus_species <- paste(data$Genus, data$Species)

#compare with Thomas accepted names
master$Genus_species <- paste(master$Genus, master$Species)
missed <- data$Genus_species[which(!data$Genus_species %in% master$Genus_species)]
length(missed) #5631
unique(missed) #638 (let's see how many we can fix)
#flag all records not matching Thomas master list.
data$flag <- ifelse(data$Genus_species %in% master$Genus_species,
                    NA, data$Genus_species)

#If you want to use taxize to further clean the data check Manual.R. Not used anymore----
#Now we use code/check to update/remove species.
head(data)
head(manual)
data2 <- merge(data, 
               manual[,c("flag", "accepted_name", "accepted_subspecies")], 
               by = "flag", all.x = TRUE)
dim(data2) == dim(data) #sanity check expect TRUE FALSE
head(data2)
data2$Subspecies <- ifelse(is.na(data2$accepted_subspecies), 
                           data2$Subspecies, data2$accepted_subspecies) 
data2$accepted_subspecies <- NULL
#mark the species to be removed according to manual checks.
head(data2)
data2$rm[which(data2$accepted_name == "Remove")] <- "Remove"
head(data2)
#recheck for new species not in manual checking.
to_check <- data2[which(!is.na(data2$flag) & 
                          is.na(data2$accepted_name) & 
                          is.na(data2$rm)),c(1,32)]
to_check
unique(to_check$flag) #231
#Add needed columns to append it to the manual_check.csv
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

#unify names
summary(as.factor(data2$accepted_name))
data2$accepted_name <- ifelse(is.na(data2$accepted_name), 
                              data2$Genus_species, data2$accepted_name)
#For now, we removed flagged species not tagged to remove, 
#but I am commenting this line for security reasons
#data2 <- data2[which(is.na(data2$flag)),] #removing here ~5000 entries. Those will be recovered when maual_check.csv is updated

data <- subset(data2, select = -flag)
head(data)
dim(data) #83106

#need to decompose genus and species again...
temp <- unlist(gregexpr(pattern = " ", fixed = TRUE, text = data$accepted_name))
length(temp) == length(data$accepted_name) #EXPECT TRUE
#slow
for(i in which(temp > 0)){ 
  data$Species[i] <- substr(data$accepted_name[i], start = temp[i]+1, 
                               stop = nchar(data$accepted_name[i]))
  data$Genus[i] <- substr(data$accepted_name[i], start = 1, 
                            stop = temp[i]-1)
} 
head(data)
tail(data)
unique(data$accepted_name) #921 species!!
unique(data[which(data$Genus_species != data$accepted_name),
     c("Genus", "Species", "Genus_species", "accepted_name", "rm")])
#recheck after fixes #Note that if flags removed above, this is empty
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
data$Subspecies[which(data$Subspecies %in% c("abdomen rayado", "no se distingue"))] <- NA
data$Subspecies[which(data$Subspecies %in% c("Ibericus"))] <- "ibericus"
data$Subspecies[which(data$Subspecies %in% c("y cupromicans"))] <- "cupromicans"
unique(data$Subspecies) 
#NEED TO DECIDE HOW MUCH CHECKING TO DO ON Subspecies
temp <- data[!is.na(data$Subspecies),c(1,3,4)]
#suspicious all the Bombus "vasco". Also bombus seems like a mess...
unique(temp) 
data$Subspecies[which(data$Subspecies %in% c("vasco"))] <- NA
dim(data) #83106

#Check Country Province Locality----
unique(data$Country) 
data$Country <- ifelse(data$Country %in% c("España", "SPAIN", "Spain "), "Spain", data$Country)
data$Country <- ifelse(data$Country %in% c("Francia"), "France", data$Country)
data$Country <- ifelse(data$Country %in% c("Italia"), "Italy", data$Country)
unique(data$Country) 
unique(data$Province) #Need to fix a lot BUT It can wait. + some encoding issues :(
#First load final provinces
provinces <- read.csv(file = "data/provincias.csv")
head(provinces)
unique(data$Province[which(!data$Province %in% provinces$Provincia_final)]) #303 errors!!
#NOTE: Here we can retrieve all of them (fuzzy matching or via csv tesaurus) and add Lat Long when this one is missing and set prcision to "province"
unique(data$Locality) #some " " at the end of the string can be striped, 
#Not done for now. use trimws

#Check Latitude Longitude Coordinate.precision----
str(data)
data$Latitude <- as.numeric(as.character(data$Latitude)) #NEED TO FIND THE OFFENDING LAT
max(data$Latitude, na.rm = TRUE) < 44.15 #expect TRUE for Iberia
min(data$Latitude, na.rm = TRUE) > 35.67 #expect TRUE
unique(data[which(data$Latitude < 35.67),"Province"]) #canary Islands and the like, This is nice
#data <- subset(data, Province != "Canary Islands")
unique(data[which(data$Latitude < 35.67),]) #Melilla, etc... some can be potentially recovered
data$Longitude <- as.numeric(as.character(data$Longitude)) #NEED TO FIND THE OFFENDING LAT
max(data$Longitude, na.rm = TRUE) < 4.76 
#unique(data[which(data$Longitude < 4.76),]) 
#unique(data[which(data$Longitude > 4.76), "Authors.to.give.credit"]) #idem.
min(data$Longitude, na.rm = TRUE) > -10.13

#bound
#outs
removed <- subset(data, Latitude > 44.15 | Latitude < 35.67 & #check this &
         Longitude > 4.76 | Longitude < -10.13) 
dim(removed) #8735 records... 
#ADD THOSE TO REMOVED
removed[,5:6] #Most Canary Islands, Azores and melilla. A few can be traced down, but now is unpractical.
#THE PROBLEM HERE IS THAT WE REMOVE GOOD DATA WITH WRONG COORDINATES
data$rm <- ifelse(is.na(data$Latitude), data$rm, 
                   ifelse(data$Latitude > 44.15 | data$Latitude < 35.67 & #check this & 
                    data$Longitude > 4.76 | data$Longitude < -10.13, "Remove", data$rm))
colnames(data)
unique(data[which(!data$accepted_name %in% master$Genus_species & is.na(data$rm)),c(7:9,29:31)])

unique(data$Coordinate.precision) 
#WOPS::: WHY THE NUMBERS??
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
#CHECK WHICH IS THE OFFENDING DATASET

#Check Year Month Day Start.date End.date -----
unique(data$Year) 
data[which(data$Year %in% c("19822",
                            "1279[sic]",
                            "192i[sic]",
                            "129i")),] #CHECK 19822 in COLLADO, and 1279 and 129i in Piluca to see if we can guesstimate the date. 
# The other can be moved to start date and fill Year with 1925 (mid point)
#TODO; For now
data$Year <- as.numeric(data$Year)
data$Year[which(data$Year %in% c("19822"))] <- NA
sort(unique(data$Year))
unique(data$Month) #fix months!
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
data$Month <- ifelse(data$Month %in% c("Agosto"),
                     8, data$Month)
data$Month <- ifelse(data$Month %in% c("January"),
                     1, data$Month)
data$Month <- ifelse(data$Month %in% c(""),
                     NA, data$Month)
unique(data$Month) #months 14 and 18!! Trace them back...
data$Month <- as.numeric(data$Month)
data$Month[which(data$Month > 12)] <- NA
sort(unique(data$Month)) #bees all year round!
#hist(data$Month)
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
data$Day <- ifelse(data$Day %in% c("1/26", "1/28", "1/18"),
                   NA, data$Day)
unique(data$Day) 
data$Day <- as.numeric(data$Day)
summary(data$Day) 

unique(data$Start.date) 
unique(data$End.date) 
#Se puede calculat mean day's y months cuando estos son NA?

#Check Collector, Determined.by-----
unique(data$Collector) 
#Maybe iNaturalist users can have a prefix? Need to be done in idata.
#some encoding bugs, 
#a couple of "-264761682" and similars... provide as is.
unique(data$Determined.by) #similar here, as iNat... 
#Here we can have a list of Trusted Taxonomists?

#Check Female Male Worker Not.specified-----
#Fuck, male and female factors!! Why!!
unique(data$Male) #why some years... Find the offender.
data$Male[which(data$Male %in% c("macho", "m"))] <- 1
data$Male[which(data$Male %in% c("2008", "2010", "2009", "2011"))] <- NA
data$Male <- as.numeric(as.character(data$Male)) 
unique(data$Female)
data$Female[which(data$Female %in% c("1 reina", "1  reina"))] <- 1
data$Worker[which(data$Female %in% c("1 obrera"))] <- 1
data$Female <- as.numeric(as.character(data$Female)) 
unique(data$Worker) #good
unique(data$Not.specified) #good
data$Male[which(is.na(data$Male))] <- 0
data$Female[which(is.na(data$Female))] <- 0
data$Worker[which(is.na(data$Worker))] <- 0
data$Not.specified[which(is.na(data$Not.specified))] <- 0
Total <- data$Male + data$Female + data$Worker + data$Not.specified
summary(Total) #Total = 0 imply Not.specified should = 1. 
hist(Total) #the > 500 should be checked. WARNING
data$Not.specified <- ifelse(Total > 0, data$Not.specified, 1)
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
dim(data) #83106

data_f <- subset(data, !rm %in% c("Remove"), select = -rm)
unique(data_f$accepted_name) #904 species!
unique(data[which(!data$accepted_name %in% master$Genus_species),c(29:31)])
removed <- subset(data, rm == "Remove")
dim(data_f) #74371
dim(removed) #8735
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
  
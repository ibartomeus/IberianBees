#Final cleaning script 

#Read compressed csv with data.table library
library(data.table)
data <- read.table("Data/Processing_iberian_bees_raw/iberian_bees_raw.csv.gz",  header=T, quote="\"", sep=",", row.names=1)

#Delete leading and trailing spaces for all columns
library(dplyr)
data <- data %>%  mutate(across(c(colnames(data)), trimws))

#Create column for original species name
data$Original_name <- paste(data$Genus, data$Species)

#######################################-
#Cleaning of genus and subgenus names----
#######################################-
library(stringr)
#Make upper case first letter of genus
data$Genus <- str_to_title(data$Genus)
#Make specific epithet to lower case
data$Species <- tolower(data$Species)
#Read iberian species masterlist to filter incorrect species names
master <- read.csv("Data/Processing_iberian_bees_raw/Iberian_species_masterlist.csv", stringsAsFactors = FALSE)
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
#exclude synonyms that need to be fixed
mm <- mismatches[-which(mismatches %in% c(master$Subgenus, "Nomia", "Megachilini", "Osmiini",
                                          "Tetraloniella", "Reanthidium", "Vestitohalictus", "Paranthidiellum",
                                          "Melissodes", "Haetosmia", "Trianthidium", "Peponapis"))]       

#Save removed genus
write.csv(mm, "Data/Processing_iberian_bees_raw/genus_removed.csv")
data2$rm <- rep(NA, nrow(data2))
data2$rm[which(data2$Genus %in% mm)] <- "Remove"
data3 <- data2
#Safety checking 
head(data3)
dim(data3) #[1] 113679     29


#######################################-
#Cleaning of specific epithet ----
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
                   "leucoleucozonium/immunitum", "malachurum/mediterraneum", "diminuta")
#Filter out undet species
data <- data %>% filter(!Species %in% undet_species)

#######################################################################-
#Now compare full species names with master list of iberian species ----
#######################################################################-
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

############################################################################################-
#Fill not found genus in iberian masterlist with a manual check when possible ----
############################################################################################-
#Load data and use it to update/remove species
#This file is generated later and now is rename to "to_check.csv"
#All species names in the file "to_check.csv" would be manually searched
#and  finally unified to manual checks which would be load here
manual <- read.csv("Data/Processing_iberian_bees_raw/manual_checks.csv", sep = ";", stringsAsFactors = FALSE, 
                   na.strings = c(NA, ""))
#Merge with raw data
data2 <- merge(data, 
               manual[,c("flag", "accepted_name", "accepted_subspecies")], 
               by = "flag", all.x = TRUE)
#Should have same dimension but different number of cols
dim(data2) == dim(data) #sanity check expect TRUE FALSE
#Seems correct

######-
#Generate list of species for the "to_check" file
######-

#Mark the species to be removed according to manual checks
data2$rm[which(data2$accepted_name == "Remove")] <- "Remove"
#recheck for new species not in manual checking

#Generate future data to check
to_check <- data2[which(!is.na(data2$flag) & 
                          is.na(data2$accepted_name) & 
                          is.na(data2$rm)),c(1,32)]

#Add needed columns to create another future manual check list of species 
#(not included in the previous one) 
#This is done with dplyr because it can add the cols with 0 rows so we don't get an error
to_check <- to_check %>% dplyr::mutate(checked=NA, synonym_names=NA, questionable=NA, accepted_name=NA,
                           accepted_subspecies=NA, Notes=NA)
#Select unique cases
unique(to_check$flag)

#Select columns of interest
to_check <- to_check[,c("flag", "checked",
                        "synonym_names", "questionable",
                        "accepted_name", "accepted_subspecies", "Notes")]
dim(unique(to_check))
#Save species list to check manually
write.csv(unique(to_check), "Data/Processing_iberian_bees_raw/to_check.csv")

######-
#Unify names
######-
#Add subspecies names
data2$Subspecies <- ifelse(is.na(data2$accepted_subspecies), 
                    data2$Subspecies, data2$accepted_subspecies) 
#Convert to NULL the col from manual checks
data2$accepted_subspecies <- NULL

#Now, unify species names
summary(as.factor(data2$accepted_name))
data2$accepted_name <- ifelse(is.na(data2$accepted_name), 
                       data2$Genus_species, data2$accepted_name)


#For now, we removed flagged species not tagged to remove
#These are the ones that would be checked in the next manual check, don't worry!
removed <- data2[which(!is.na(data2$flag)),] #Save removed entries
write.csv(removed, "Data/Processing_iberian_bees_raw/removed.csv")
data2 <- data2[which(is.na(data2$flag)),] #removing here ~5000 entries. Those will be recovered when maual_check.csv is updated
#Delete flag column and back to data
data <- subset(data2, select = -flag)

#Split accepted names again and rename genus and species cols
data$Genus <- word(data$accepted_name,1)
data$Species <- word(data$accepted_name,2)
nlevels(factor(data$accepted_name)) #923 species!!

#Recheck after fixes #Note that if flags removed above, this is empty
(missed <- data$accepted_name[which(!data$accepted_name %in% master$Genus_species & is.na(data$rm))])
#Good!

#Now accepted_name and Genus_species should be identical
#The original names were "corrected" already and the ones that not
#have been deleted

#So now we filter out one of these cols
data <- data %>%  dplyr::select(-Genus_species)
#I think that if there is the need to check specific species
#Always the raw data can be checked because is available

#########################-
#Fix now subgenus ----
#########################-
#Convert to NA confusing subgenus
data$Subgenus[data$Subgenus=="Thoracobombus ? Rhodobombus?"] <- NA
data$Subgenus[data$Subgenus=="Anthid"] <- NA
data$Subgenus[data$Subgenus=="Apis"] <- NA
data$Subgenus[data$Subgenus=="Rhod."] <- NA
data$Subgenus[data$Subgenus=="Neoeutric."] <- NA
data$Subgenus[data$Subgenus=="Eutrich."] <- NA
data$Subgenus[data$Subgenus=="Megach."] <- NA
#now gsub spaces "()" sobe are in parenthesis
data$Subgenus <- gsub("[()]", "", data$Subgenus)
#Seems ok now


################################################################################-
#Check now the rest of the columns (e.g., country, coordinates, etc) ----
################################################################################-

#Check country levels
levels(factor(data$Country))
#Seems ok

#Check province levels
nlevels(factor(data$Province))
#This field is a bit chaotic
#I'm going to try to recover the province by coordinate
#Maybe this will clean a bit
#Nice function to add Spanish standard provinces
lonlat_to_state <- function(pointsDF,
                            states = mapSpain::esp_get_prov(),
                            name_col = "ine.prov.name") {
  ## Convert points data.frame to an sf POINTS object
  pts <- sf::st_as_sf(pointsDF, coords = 1:2, crs = 4326)
  
  ## Transform spatial data to some planar coordinate system
  ## (e.g. Web Mercator) as required for geometric operations
  states <- sf::st_transform(states, crs = 3857)
  pts <- sf::st_transform(pts, crs = 3857)
  
  ## Find names of state (if any) intersected by each point
  state_names <- states[[name_col]]
  ii <- as.integer(sf::st_intersects(pts, states))
  state_names[ii]
}

#Add province name to the dataset
data$Longitude <- gsub(",", ".", data$Longitude)
data$Latitude <- gsub(",", ".", data$Latitude)
#Separate missing values not allowed for this function
data$Longitude <- as.numeric(data$Longitude)
data$Latitude <- as.numeric(data$Latitude)

data_na <- data %>% dplyr::filter(is.na(Longitude) & is.na(Latitude))
data_non_na <- data %>% dplyr::filter(!is.na(Longitude) & !is.na(Latitude))
#Create dataframe with coordinates
ine_province <- data.frame(x = data_non_na$Longitude, y = data_non_na$Latitude)
#Add standard province names
data_non_na$Province <- lonlat_to_state(ine_province)
#Rbind again data
#Filter out by coordinate Canary Islands
data_non_na <- data_non_na %>% filter(Latitude>35.7 & Latitude < 44 & Longitude > - 10.4 & Longitude < 4.6)
data <- rbind(data_na, data_non_na)
#Ok some have been fixed by coordinate!

#Keep homgeneizing province names (this could go forever)
#Remember all are ine standard: 
#One exception: Islas Canarias are not divided in their provinces
#because their are filtered out (easier to have everything as Islas Canarias) 
#not in the Iberian Peninsula
#https://www.ine.es/daco/daco42/codmun/cod_provincia_estandar.htm
data$Province[grepl("Alicante", data$Province)] <- "Alicante/Alacant"
data$Province[grepl("Islas Bal", data$Province)] <- "Balears, Illes"
data$Province[grepl("Balear", data$Province)] <- "Balears, Illes"
data$Province[grepl("Guip", data$Province)] <- "Gipuzkoa"
data$Province <- gsub("Gerona", "Girona", data$Province, fixed=T)
data$Province[grepl("Valencia", data$Province)] <- "Valencia/València"
data$Province[grepl("Valencia", data$Province)] <- "Valencia/València"
data$Province[grepl("Vizcaya", data$Province)] <- "Bizkaia"
data$Province[grepl("Lérida", data$Province)] <- "Lleida"
data$Province[grepl("La Coruña", data$Province)] <- "Coruña, A"
data$Province[grepl("Albacetel", data$Province)] <- "Albacete"
data$Province[grepl("Jaen", data$Province)] <- "Jaén"
data$Province[grepl("Majorca", data$Province)] <- "Mallorca"
data$Province[grepl("Orense", data$Province)] <- "Ourense"
data$Province[grepl("Léon", data$Province)] <- "León"
data$Province[grepl("Muercia", data$Province)] <- "Murcia"
data$Province[grepl("near", data$Province, fixed=T)] <- "Málaga"
data$Province[grepl("Álava", data$Province, fixed=T)] <- "Araba/Álava"
data$Province[grepl("unknown", data$Province, fixed=T)] <- NA
data$Province[grepl("South-East Spain, dept.", data$Province)] <- "Málaga"
data$Province[grepl("La Rioja", data$Province)] <- "Rioja, La"
data$Province[grepl("Algeciras", data$Province)] <- "Cádiz"
data$Province[grepl("Castellón", data$Province)] <- "Castellón/Castelló"
data$Province[grepl("Santander", data$Province)] <- "Cantabria"
data$Province[grepl("Mérida", data$Province)] <- "Badajoz"
data$Province[grepl("Mahón", data$Province)] <- "Balears, Illes"
data$Province[grepl("Canary", data$Province)] <- "Islas Canarias"
data$Province[grepl("Fuerteventura, Canarias", data$Province)] <- "Islas Canarias"
data$Province[grepl("Islas Canarias", data$Province)] <- "Islas Canarias"
data$Province[grepl("Cádiz?", data$Province)] <- "Cádiz"
data$Province[grepl("North-East Spain", data$Province) & grepl("Barcelona", data$Locality)] <- "Barcelona"
data$Province[grepl("North-East Spain", data$Province)] <- NA #No idea where these are
data$Province[grepl("PyreneeÃ«n", data$Province) & grepl("Alã²S", data$Locality)] <- "Lleida"
data$Locality[grepl("PyreneeÃ«n", data$Province) & grepl("Noarte", data$Locality)] <- "Pirineos"
data$Province[grepl("PyreneeÃ«n", data$Province) & grepl("Noarte", data$Locality)] <- NA
data$Locality[grepl("PyreneeÃ«n", data$Province)] <- "Pirineos"
data$Province[grepl("PyreneeÃ«n", data$Province)] <- NA
data$Province[grepl("Tenerife", data$Province)] <- "Islas Canarias"
data$Province[grepl("Cataluña", data$Province)] <- NA
data$Country[grepl("Andorra", data$Province)] <- "Andorra"
data$Province[grepl("Andorra", data$Province)] <- NA
data$Country[grepl("Francia", data$Province)] <- "Francia"
data$Province[grepl("Francia", data$Province)] <- NA
data$Province[grepl("Estremadura", data$Province)] <- "Estramadura"
data$Country[grepl("Portugal", data$Province)] <- "Portugal"
data$Province[grepl("Portugal", data$Province)] <- NA

#Filter out Canary islands by province
data <- data %>% dplyr::filter(!Province %in% "Islas Canarias")
#Select just 3 decimals for coordinates (this rounds last decimals but i think it's fine)
data$Latitude = formatC(as.numeric(data$Latitude), digits = 3, format = "f")
data$Longitude = formatC(as.numeric(data$Longitude), digits = 3, format = "f")

#Add leading 0 to months under 10
data$Month <- as.numeric(data$Month)  
data$Month <- ifelse(data$Month < 10, paste0("0", data$Month), data$Month)

#Add leading 0 to days under 10
data$Day <- as.numeric(data$Day)  
data$Day <- ifelse(data$Day < 10, paste0("0", data$Day), data$Day)

#Now 00 in Start.date is converted to 01 
data$Start.date <- gsub("00/", "01/", data$Start.date)
#Fix empty level
data$Start.date[data$Start.date==""] <- NA
data$Coordinate.precision[data$Coordinate.precision==""] <- NA
data$Locality[data$Locality==""] <- NA
data$Province[data$Province==""] <- NA

#delete rm col 
data <- data %>% dplyr::select(-c(rm))

#Make first letter upper case for all cols
colnames(data) <- str_to_title(colnames(data))

#Reorder cols, final order! :) 
data_1 <- data %>% dplyr::select(Genus, Subgenus, Species, Subspecies, Accepted_name, Original_name)
data_2 <- data %>% dplyr::select(!c(Genus, Subgenus, Species, Subspecies, Accepted_name, Original_name))
#All species cols are now first
data <- cbind(data_1, data_2)

#Exclude Apis mellifera records
data <- data %>% filter(!Accepted_name == "Apis mellifera")

#Rename colname uid to Unique.identifier
data <- data %>% rename(Unique.identifier = Uid)

#Save as a zip file
write.csv(data, file=gzfile("Data/iberian_bees.csv.gz"))


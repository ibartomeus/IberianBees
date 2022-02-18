#Fetch data from internet

########################################-
# Download GBIF data ----
########################################-
#Load libraries
library(rgbif)
library(cleanR)
library(tidyverse)

########################################-
#Prepare data download-
########################################-
#get codes of places and families
spain_code <- isocodes[grep("Spain", isocodes$name), "code"]
portugal_code <- isocodes[grep("Portugal", isocodes$name), "code"]
apidae_key <- name_backbone(name="Apidae", rank = "family")$usageKey
andrenidae_key <- name_backbone(name="Andrenidae", rank = "family")$usageKey
halictidae_key <- name_backbone(name="Halictidae", rank = "family")$usageKey
colletidae_key <- name_backbone(name="Colletidae", rank = "family")$usageKey
megachilidae_key <- name_backbone(name="Megachilidae", rank = "family")$usageKey
stenotritidae_key <- name_backbone(name="Stenotritidae", rank = "family")$usageKey
melittidae_key <- name_backbone(name="Melittidae", rank = "family")$usageKey

occ_count(taxonKey= apidae_key, 
          georeferenced=TRUE, 
          country=spain_code) #4343
occ_count(taxonKey= andrenidae_key, 
          georeferenced=TRUE, 
          country=spain_code) #897
occ_count(taxonKey= halictidae_key, 
          georeferenced=TRUE, 
          country=spain_code) #1153
occ_count(taxonKey= colletidae_key, 
          georeferenced=TRUE, 
          country=spain_code) #691
occ_count(taxonKey= megachilidae_key, 
          georeferenced=TRUE, 
          country=spain_code) #1914
occ_count(taxonKey= stenotritidae_key, 
          georeferenced=TRUE, 
          country=spain_code) #0 (expected)
occ_count(taxonKey= melittidae_key, 
          georeferenced=TRUE, 
          country=spain_code) #203

occ_count(taxonKey= apidae_key, 
          georeferenced=TRUE, 
          country=portugal_code) #2828
occ_count(taxonKey= andrenidae_key, 
          georeferenced=TRUE, 
          country=portugal_code) #258
occ_count(taxonKey= halictidae_key, 
          georeferenced=TRUE, 
          country=portugal_code) #454
occ_count(taxonKey= colletidae_key, 
          georeferenced=TRUE, 
          country=portugal_code) #158
occ_count(taxonKey= megachilidae_key, 
          georeferenced=TRUE, 
          country=portugal_code) #387
occ_count(taxonKey= stenotritidae_key, 
          georeferenced=TRUE, 
          country=portugal_code) #0 (expected)
occ_count(taxonKey= melittidae_key, 
          georeferenced=TRUE, 
          country=portugal_code) #14
#fetch data
check <-  data.frame(scientificName = NA, decimalLatitude = NA,
                     decimalLongitude = NA,
                     family = NA, genus = NA, species = NA,
                     year = NA, month = NA, day = NA, recordedBy = NA,
                     identifiedBy = NA, sex = NA,  stateProvince = NA,
                     locality = NA, coordinatePrecision=NA)

check <- define_template(check, NA)

family_key <- c(apidae_key, andrenidae_key,
                halictidae_key, colletidae_key,
                megachilidae_key, 
                melittidae_key)

dat <-  data.frame(scientificName = NA, decimalLatitude = NA,
                   decimalLongitude = NA,
                   family = NA, genus = NA, species = NA,
                   year = NA, month = NA, day = NA, recordedBy = NA,
                   identifiedBy = NA, sex = NA,  stateProvince = NA,
                   locality = NA,  coordinatePrecision=NA)

#Load data separately
dat_spain <- dat
########################################-
#Fetch Spain data-
########################################-

for(i in family_key){
  
  temp <- occ_search(taxonKey= i, 
                     return='data', 
                     hasCoordinate=TRUE,
                     hasGeospatialIssue=FALSE,
                     limit=7000, #safe threshold based on rounding up counts above
                     country = c(spain_code),
                     fields = c('scientificName','decimalLatitude',
                                'decimalLongitude',
                                'family','genus', 'species',
                                'year', 'month', 'day', 'recordedBy',
                                'identifiedBy', 'sex', 'stateProvince', 
                                'locality', 'coordinatePrecision'))
  
  #Convert to dataframe and add cols if necessary
  temp <- as.data.frame(temp$data)
  temp <- add_missing_variables(check, temp)
  #store the data
  dat_spain <- rbind(dat_spain, temp)
  
} 

#Delete first row with full NA's
dat_spain <- dat_spain[-1,]

#check if max number is right
dat_spain %>% 
  group_by(family) %>%
  summarise(no_rows = length(family))
#7000 as a max for gbif seems ok but this may need to be increased in the next year or so
head(dat_spain)
tail(dat_spain)
dim(dat_spain) #16146 records 14/02/2022
dat_spain$Country <- "Spain" 
#The good thing of doing this separately 
#is that we can add country and is missing for many

########################################-
#Fetch Portugal data-
########################################-
#Exclude coordinate precision for Portugal for now, it is giving trouble...
#I'll have to check what is happening running one by one, future caveat
#Seems that there are just few records with coordinate precision overall

check <-  data.frame(scientificName = NA, decimalLatitude = NA,
                     decimalLongitude = NA,
                     family = NA, genus = NA, species = NA,
                     year = NA, month = NA, day = NA, recordedBy = NA,
                     identifiedBy = NA, sex = NA,  stateProvince = NA,
                     locality = NA)

check <- define_template(check, NA)

dat <-  data.frame(scientificName = NA, decimalLatitude = NA,
                   decimalLongitude = NA,
                   family = NA, genus = NA, species = NA,
                   year = NA, month = NA, day = NA, recordedBy = NA,
                   identifiedBy = NA, sex = NA,  stateProvince = NA,
                   locality = NA)
dat_portugal <- dat

temp <- NULL

for(i in family_key){
  
  temp <- occ_search(taxonKey= i, 
                     return='data', 
                     hasCoordinate=TRUE,
                     hasGeospatialIssue=FALSE,
                     limit=7000, #safe threshold based on rounding up counts above
                     country = c(portugal_code),
                     fields = c('scientificName','decimalLatitude',
                                'decimalLongitude',
                                'family','genus', 'species',
                                'year', 'month', 'day', 'recordedBy',
                                'identifiedBy', 'sex', 'stateProvince', 
                                'locality'))
  
  #Convert to dataframe and add cols if necessary
  temp <- as.data.frame(temp$dat)
  temp <- add_missing_variables(check, temp)
  #store the data
  dat_portugal <- rbind(dat_portugal, temp)
  
} 

#Delete first row with full NA's
dat_portugal <- dat_portugal[-1,]

#check if max number is right
dat_portugal %>% 
  group_by(family) %>%
  summarise(no_rows = length(family))
#7000 as a max for gbif seems ok but this may need to be increased in the next year or so
head(dat_portugal)
tail(dat_portugal)
dim(dat_portugal) #16146 records 14/02/2022
#Add country
dat_portugal$Country <- "Portugal"
dat_portugal$coordinatePrecision <- NA #This was giving trouble!
colnames(dat_spain)
colnames(dat_portugal)

#Unify gbif data for Spain and Portugal
dat <- rbind(dat_spain, dat_portugal)
#Add unique identifier
dat$uid <-  paste("55_Gbif_", 1:nrow(dat), sep = "")

########################################-
# Download inaturalist data ----
########################################-
#library(devtools)
#install_github(repo = "ropensci/rinat")
library(rinat)
bounds <- c(35.67, -10.13, 44.15, 4.76) #Iberian peninsula
#Divide it for apidae because we reach the max number of records
bound_1 <- c(35.67, -10.13, 44.15, -2.99) #Iberian peninsula in half
bound_2 <- c(35.67, -3.00, 44.15, 4.76) #Iberian peninsula in half
apidae_1 <- get_inat_obs(taxon_name = "Apidae", geo = TRUE, maxresults = 9999 , bounds = bound_1)
apidae_2 <- get_inat_obs(taxon_name = "Apidae", geo = TRUE, maxresults = 9999 , bounds = bound_2)
andrenidae <- get_inat_obs(taxon_name = "Andrenidae", geo = TRUE, maxresults = 9999 , bounds = bounds)
halictidae <- get_inat_obs(taxon_name = "Halictidae", geo = TRUE, maxresults = 9999 , bounds = bounds)
colletidae <- get_inat_obs(taxon_name = "Colletidae", geo = TRUE, maxresults = 9999 , bounds = bounds)
megachilidae <- get_inat_obs(taxon_name = "Megachilidae", geo = TRUE, maxresults = 9999 , bounds = bounds)
melittidae <- get_inat_obs(taxon_name = "Melittidae", geo = TRUE, maxresults = 9999 , bounds = bounds)

#This needs to be fixed, at the moment we are losing species of Apidae because of the max limit
inat <- rbind(apidae_1,apidae_2, andrenidae, halictidae, colletidae, megachilidae)
unique(inat$scientific_name) #need to clean data, a couple subsp.
head(inat)

#Merge Gen sp plant lat long, date, credit----
colnames(inat)[which(colnames(inat) == "scientific_name")] <- "species"
colnames(inat)[which(colnames(inat) == "latitude")] <- "decimalLatitude"
colnames(inat)[which(colnames(inat) == "longitude")] <- "decimalLongitude"
colnames(inat)[which(colnames(inat) == "place_guess")] <- "locality"
colnames(inat)[which(colnames(inat) == "positional_accuracy")] <- "coordinatePrecision"
inat$family <- NA
inat$sex <- NA
inat$recordedBy  <- inat$user_login
inat$identifiedBy <- inat$user_login
inat$stateProvince <- NA
date <- as.POSIXlt(strptime(inat$observed_on, "%Y-%m-%d")) #convert to date class
inat$day <- date$mday #extract the day only
inat$month <- date$mon+1 #extract the day only
inat$year <- date$year + 1900 #extract the day only
inat$uid <- paste("55_inaturalist_", 1:nrow(inat), sep = "")
inat$Country <- NA

d <- rbind(dat[,c("species", "decimalLatitude",  "decimalLongitude", "family",
                  "year", "month",  "day", "recordedBy", "identifiedBy", "sex",
                  "stateProvince", "locality", "coordinatePrecision", "uid", "Country")], 
           inat[, c("species", "decimalLatitude",  "decimalLongitude", "family",
                    "year", "month",  "day", "recordedBy", "identifiedBy", "sex",
                    "stateProvince", "locality", "coordinatePrecision", "uid", "Country")])

#Clean and merge Gbig and inat----
#species in canary islands
d2 <- subset(d, decimalLatitude > 35.8 & decimalLatitude < 43.88 & 
               decimalLongitude > - 10.11 & decimalLongitude < 4.56)
#species in the see (ignore for now?)
#species with only genus (Gbif, done using species column)
d3 <- d2[which(is.na(d2$species) == FALSE),]
unique(d3$species) #681
d4 <- d3[grep(" ", d3$species, fixed = TRUE, value = FALSE),]
unique(d4$species) #591 sp ... not bad...some subspecies...

#Save data
write.csv(d4, file = "Data/Processing_raw_data/online_data.csv")


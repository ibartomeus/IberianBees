
########################################-
# Download gbif data ----
########################################-

#Load libraries
library(rgbif) #fetch data
library(cleanR) #add missing cols
library(tidyverse) #edit data structure

#Set species key
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

family_key <- c(apidae_key, andrenidae_key,
                halictidae_key, colletidae_key,
                megachilidae_key, 
                melittidae_key)

#fetch data
check <-  data.frame(scientificName = NA, decimalLatitude = NA,
                     decimalLongitude = NA,
                     family = NA, genus = NA, species = NA,
                     year = NA, month = NA, day = NA, recordedBy = NA,
                     identifiedBy = NA, sex = NA,  stateProvince = NA,
                     locality = NA, coordinatePrecision=NA)

check <- define_template(check, NA)

cols <-  c("scientificName", "decimalLatitude",
           "decimalLongitude",
           "family", "genus", "species",
           "year", "month", "day", "recordedBy",
           "identifiedBy", "sex",  "stateProvince",
           "locality", "coordinatePrecision")

dat <-  data.frame(scientificName = NA, decimalLatitude = NA,
                   decimalLongitude = NA,
                   family = NA, genus = NA, species = NA,
                   year = NA, month = NA, day = NA, recordedBy = NA,
                   identifiedBy = NA, sex = NA,  stateProvince = NA,
                   locality = NA,  coordinatePrecision=NA)


for(i in family_key){
  temp <- occ_data(taxonKey= i, 
                   hasCoordinate=TRUE,
                   hasGeospatialIssue=FALSE,
                   limit=10000, 
                   country = c("ES","PT"))
  
  #Convert to dataframe and add cols if necessary
  temp_ES <- as.data.frame(temp$ES$data) 
  temp_ES = temp_ES %>% select(any_of(cols))
  temp_PT <- as.data.frame(temp$PT$data)
  temp_PT = temp_PT %>% select(any_of(cols)) 
  #Add missing vars
  temp_ES <- add_missing_variables(check, temp_ES)
  temp_PT <- add_missing_variables(check, temp_PT)
  #Rbind forloop results
  dat <- rbind(dat, temp_ES, temp_PT)
  
}

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
#Apidae is divided in two in order to get the max records of the Iberia peninsula
apidae_1 <- get_inat_obs(taxon_name = "Apidae", geo = TRUE, maxresults = 9999 , bounds = bound_1)
apidae_2 <- get_inat_obs(taxon_name = "Apidae", geo = TRUE, maxresults = 9999 , bounds = bound_2)
andrenidae <- get_inat_obs(taxon_name = "Andrenidae", geo = TRUE, maxresults = 9999 , bounds = bounds)
halictidae <- get_inat_obs(taxon_name = "Halictidae", geo = TRUE, maxresults = 9999 , bounds = bounds)
colletidae <- get_inat_obs(taxon_name = "Colletidae", geo = TRUE, maxresults = 9999 , bounds = bounds)
megachilidae <- get_inat_obs(taxon_name = "Megachilidae", geo = TRUE, maxresults = 9999 , bounds = bounds)
melittidae <- get_inat_obs(taxon_name = "Melittidae", geo = TRUE, maxresults = 9999 , bounds = bounds)

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

d <- rbind(dat[,c("decimalLatitude",
                  "decimalLongitude",
                  "family", "species",
                  "year", "month", "day", "recordedBy",
                  "identifiedBy", "sex",  "stateProvince",
                  "locality", "coordinatePrecision", "uid")], 
           inat[, c("decimalLatitude",
                    "decimalLongitude",
                    "family", "species",
                    "year", "month", "day", "recordedBy",
                    "identifiedBy", "sex",  "stateProvince",
                    "locality", "coordinatePrecision", "uid")])


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
write.csv(d4, file = "Data/Processing_iberian_bees_raw/online_data.csv")



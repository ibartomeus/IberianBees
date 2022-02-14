#Fetch data from internet

#Gbif----
library(rgbif)
library(cleanR)
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
                   locality = NA, coordinatePrecision=NA)

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
  
  #C
  temp <- as.data.frame(temp$data)
  temp <- add_missing_variables(check, temp)
  
  dat <- rbind(dat, temp)
  
} 

#Delete first row with full NA's
dat <- dat[-1,]
#Add unique identifier
dat$uid <-  paste("55_Gbif_", 1:nrow(newdat), sep = "")

dat %>% 
  group_by(family) %>%
  summarise(no_rows = length(family))
#7000 as a max for gbif seems ok but this may need to increase in the next year or so
#see apidae 6224 records
head(dat)
tail(dat)
dim(dat) #16146 records 14/02/2022

#iNaturalist----
#library(devtools)
#install_github(repo = "ropensci/rinat")
library(rinat)
bounds <- c(35.67, -10.13, 44.15, 4.76) #Iberian peninsula
apidae <- get_inat_obs(taxon_name = "Apidae", geo = TRUE, maxresults = 9999 , bounds = bounds)
andrenidae <- get_inat_obs(taxon_name = "Andrenidae", geo = TRUE, maxresults = 9999 , bounds = bounds)
halictidae <- get_inat_obs(taxon_name = "Halictidae", geo = TRUE, maxresults = 9999 , bounds = bounds)
colletidae <- get_inat_obs(taxon_name = "Colletidae", geo = TRUE, maxresults = 9999 , bounds = bounds)
megachilidae <- get_inat_obs(taxon_name = "Megachilidae", geo = TRUE, maxresults = 9999 , bounds = bounds)
melittidae <- get_inat_obs(taxon_name = "Melittidae", geo = TRUE, maxresults = 9999 , bounds = bounds)
length(apidae$scientific_name) #7258
length(andrenidae$scientific_name) #884 (most genus only)
length(halictidae$scientific_name) #1152
length(colletidae$scientific_name) #238
length(megachilidae$scientific_name) #1262
length(melittidae$scientific_name) #62

inat <- rbind(apidae, andrenidae, halictidae, colletidae, megachilidae)
unique(inat$scientific_name) #need to clean data, a couple subsp.
head(inat)

#Other sources----
#Traitbase?
#Observado?

#Merge Gen sp plant lat long, date, credit----
colnames(dat)
head(dat)
head(inat)
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

d <- rbind(dat[,c("species", "decimalLatitude",  "decimalLongitude", "family",
                  "year", "month",  "day", "recordedBy", "identifiedBy", "sex",
                  "stateProvince", "locality", "coordinatePrecision")], 
           inat[, c("species", "decimalLatitude",  "decimalLongitude", "family",
                    "year", "month",  "day", "recordedBy", "identifiedBy", "sex",
                    "stateProvince", "locality", "coordinatePrecision")])

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

#Load and merge Beefun----

library(BeeFunData)
data(all_interactions)
head(all_interactions)
data(sites)
head(sites)
data(traits_pollinators_estimated)
head(traits_pollinators_estimated)
beefun <- merge(all_interactions, sites)
beefun <- merge(beefun, traits_pollinators_estimated)

unique(beefun$family)
beefun <- subset(beefun, family %in% c("Andrenidae", "Apidae", "Megachilidae",
                                       "Colletidae", "Melittidae"))

head(beefun)
beefun$species <- beefun$Pollinator_gen_sp
unique(beefun$species)
beefun <- subset(beefun, !species %in% c("Osmia sp", "Panurgus sp",
                                         "Nomada sp", "Megachile sp",
                                         "Hoplitis sp", "Eucera sp",
                                         "Dasypoda sp", "Colletes sp",
                                         "Coelioxys sp", "Ceratina sp",
                                         "Ceratina sp", "Apidae NA",
                                         "Anthophora sp", "Andrena sp"))
beefun$decimalLatitude <- beefun$latitude
beefun$decimalLongitude <- beefun$longitude
beefun$family <- beefun$family
beefun$year <- 2015
beefun$month <- NA #this can be added...
beefun$day <- NA
beefun$recordedBy <- "Curro Molina"
beefun$identifiedBy <- "Oscar Aguado"
beefun$sex <- beefun$Pollinator_sex
beefun$stateProvince <- "Huelva"
beefun$locality <- beefun$Site_ID            
beefun$coordinatePrecision <- "gps"
#Add
beefun$Reference.doi <- "http://doi.org/10.5281/zenodo.3364037"
beefun$Local_ID <- beefun$Pollinator_id
beefun$Authors.to.give.credit <- "I. Bartomeus, C. Molina"
beefun$Any.other.additional.data <- NA
beefun$Country <- "Spain"
#Add
d4$Reference.doi <- NA
d4$Local_ID <- NA
d4$Authors.to.give.credit <- NA
d4$Any.other.additional.data <- "Gbif/iNat"
d4$Country <- NA

head(beefun)
colnames(d4)
colnames(beefun)
d5 <- rbind(d4, 
            beefun[, c("species", "decimalLatitude",  "decimalLongitude", "family",
                       "year", "month",  "day", "recordedBy", "identifiedBy", "sex",
                       "stateProvince", "locality", "coordinatePrecision",
                       "Reference.doi", "Local_ID", "Authors.to.give.credit",
                       "Any.other.additional.data", "Country")])

unique(d5$species) #543 #some subspecies!!
d5$subspecies <- NA  
for(i in 1:length(d5$species)){
  temp <- unlist(gregexpr(pattern = " ", text = d5$species[i]))
  if(length(temp) == 2){
    d5$subspecies[i] <- substr(d5$species[i], start = temp[2]+1, stop = nchar(d5$species[i]))
    d5$species[i] <- substr(d5$species[i], start = 1, stop = temp[2]-1)
  }
}
dim(d5) #15026 occurrences...

#export
write.csv(d5, file = "data/idata.csv")

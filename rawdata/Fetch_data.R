#Fetch data from internet

#Gbif----
library(rgbif)
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
          country=spain_code) #2679
occ_count(taxonKey= andrenidae_key, 
          georeferenced=TRUE, 
          country=spain_code) #722
occ_count(taxonKey= halictidae_key, 
          georeferenced=TRUE, 
          country=spain_code) #958
occ_count(taxonKey= colletidae_key, 
          georeferenced=TRUE, 
          country=spain_code) #597
occ_count(taxonKey= megachilidae_key, 
          georeferenced=TRUE, 
          country=spain_code) #1623
occ_count(taxonKey= stenotritidae_key, 
          georeferenced=TRUE, 
          country=spain_code) #0 (expected)
occ_count(taxonKey= melittidae_key, 
          georeferenced=TRUE, 
          country=spain_code) #178

occ_count(taxonKey= apidae_key, 
          georeferenced=TRUE, 
          country=portugal_code) #1286
occ_count(taxonKey= andrenidae_key, 
          georeferenced=TRUE, 
          country=portugal_code) #133
occ_count(taxonKey= halictidae_key, 
          georeferenced=TRUE, 
          country=portugal_code) #329
occ_count(taxonKey= colletidae_key, 
          georeferenced=TRUE, 
          country=portugal_code) #139
occ_count(taxonKey= megachilidae_key, 
          georeferenced=TRUE, 
          country=portugal_code) #238
occ_count(taxonKey= stenotritidae_key, 
          georeferenced=TRUE, 
          country=portugal_code) #0 (expected)
occ_count(taxonKey= melittidae_key, 
          georeferenced=TRUE, 
          country=portugal_code) #10
#fetch data
dat <-  data.frame(scientificName = NA, decimalLatitude = NA,
                  decimalLongitude = NA, scientificName = NA,
                  family = NA, genus = NA, species = NA,
                  year = NA, month = NA, day = NA, recordedBy = NA,
                  identifiedBy = NA, sex = NA, stateProvince = NA,
                  locality = NA, coordinatePrecision = NA)
for(i in c(apidae_key, andrenidae_key,
           halictidae_key, colletidae_key,
           megachilidae_key, 
           melittidae_key)){
  temp <- occ_search(taxonKey= i, 
                     return='data', 
                     hasCoordinate=TRUE,
                     hasGeospatialIssue=FALSE,
                     limit=7000, #safe threshold based on rounding up counts above
                     country = c(spain_code, portugal_code),
                     fields = c('scientificName','name', 'decimalLatitude',
                                'decimalLongitude', 'scientificName',
                                'family','genus', 'species',
                                'year', 'month', 'day', 'recordedBy',
                                'identifiedBy', 'sex', 'stateProvince', 
                                'locality', 'coordinatePrecision'))
  if(length(temp$PT) == 1){
    temp$PT <- data.frame(scientificName = NA, decimalLatitude = NA,
                          decimalLongitude = NA, scientificName = NA,
                          family = NA, genus = NA, species = NA,
                          year = NA, month = NA, day = NA, recordedBy = NA,
                          identifiedBy = NA, sex = NA,  stateProvince = NA,
                          locality = NA, coordinatePrecision = NA)
  }
  if(is.null(temp$ES$sex)){
    temp$ES$sex <- NA
  }
  if(is.null(temp$PT$sex)){
    temp$PT$sex <- NA
  }
  if(is.null(temp$PT$coordinatePrecision)){
    temp$PT$coordinatePrecision <- NA
  }
  if(is.null(temp$ES$coordinatePrecision)){
    temp$ES$coordinatePrecision <- NA
  }
  if(is.null(temp$ES$stateProvince)){
    temp$ES$stateProvince <- NA
  }
  if(is.null(temp$PT$stateProvince)){
    temp$PT$stateProvince <- NA
  }
  temp$ES <- temp$ES[,c('scientificName','decimalLatitude',
                        'decimalLongitude', 'scientificName',
                        'family','genus', 'species',
                        'year', 'month', 'day', 'recordedBy',
                        'identifiedBy', 'sex',  'stateProvince', 
                        'locality', 'coordinatePrecision')]
  temp$PT <- temp$PT[,c('scientificName','decimalLatitude',
                        'decimalLongitude', 'scientificName',
                        'family','genus', 'species',
                        'year', 'month', 'day', 'recordedBy',
                        'identifiedBy', 'sex',  'stateProvince', 
                        'locality', 'coordinatePrecision')]
  dat <- rbind(dat, as.data.frame(temp$ES), as.data.frame(temp$PT))
}
dat <- dat[-1,]
head(dat)
tail(dat)
dim(dat) #8889

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
length(apidae$scientific_name) #3938
length(andrenidae$scientific_name) #590 (most genus only)
length(halictidae$scientific_name) #609
length(colletidae$scientific_name) #112
length(megachilidae$scientific_name) #710
length(melittidae$scientific_name) #33

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
colnames(inat) <- c("species"                           ,"datetime"                        
                    ,"description"                      ,"locality"                     
                    ,"decimalLatitude"                  ,"decimalLongitude"                       
                    ,"tag_list"                         ,"common_name"                     
                    ,"url"                              ,"image_url"                       
                    ,"user_login"                       ,"id"                              
                    ,"species_guess"                    ,"iconic_taxon_name"               
                    ,"taxon_id"                         ,"id_please"                       
                    ,"num_identification_agreements"   , "num_identification_disagreements"
                    ,"observed_on_string"              , "observed_on"                     
                    ,"time_observed_at"                , "time_zone"                       
                    ,"positional_accuracy"             , "private_place_guess"             
                    ,"geoprivacy"                      , "coordinates_obscured"            
                    ,"coordinatePrecision"              , "positioning_device"              
                    ,"out_of_range"                    , "user_id"                         
                    ,"created_at"                      , "updated_at"                      
                    ,"quality_grade"                   , "license"                         
                    ,"sound_url"                       , "oauth_application_id"            
                    ,"captive_cultivated")
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
unique(d3$species) #600
d4 <- d3[grep(" ", d3$species, fixed = TRUE, value = FALSE),]
unique(d4$species) #522 sp ... not bad...some subspecies...

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
dim(d5) #9041 occurrences...

#export
write.csv(d5, file = "data/idata.csv")

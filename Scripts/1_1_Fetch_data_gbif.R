
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
          country="ES") #4343
occ_count(taxonKey= andrenidae_key, 
          georeferenced=TRUE, 
          country="ES") #897
occ_count(taxonKey= halictidae_key, 
          georeferenced=TRUE, 
          country="ES") #1153
occ_count(taxonKey= colletidae_key, 
          georeferenced=TRUE, 
          country="ES") #691
occ_count(taxonKey= megachilidae_key, 
          georeferenced=TRUE, 
          country="ES") #1914
occ_count(taxonKey= stenotritidae_key, 
          georeferenced=TRUE, 
          country="ES") #0 (expected)
occ_count(taxonKey= melittidae_key, 
          georeferenced=TRUE, 
          country="ES") #203

occ_count(taxonKey= apidae_key, 
          georeferenced=TRUE, 
          country="PT") #2828
occ_count(taxonKey= andrenidae_key, 
          georeferenced=TRUE, 
          country="PT") #258
occ_count(taxonKey= halictidae_key, 
          georeferenced=TRUE, 
          country="PT") #454
occ_count(taxonKey= colletidae_key, 
          georeferenced=TRUE, 
          country="PT") #158
occ_count(taxonKey= megachilidae_key, 
          georeferenced=TRUE, 
          country="PT") #387
occ_count(taxonKey= stenotritidae_key, 
          georeferenced=TRUE, 
          country="PT") #0 (expected)
occ_count(taxonKey= melittidae_key, 
          georeferenced=TRUE, 
          country="PT") #14

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
  temp_ES = temp_ES %>% dplyr::select(any_of(cols))
  temp_PT <- as.data.frame(temp$PT$data)
  temp_PT = temp_PT %>% dplyr::select(any_of(cols)) 
  #Add missing vars
  temp_ES <- add_missing_variables(check, temp_ES)
  temp_PT <- add_missing_variables(check, temp_PT)
  #Rbind forloop results
  dat <- rbind(dat, temp_ES, temp_PT)
  
}

#Add unique identifier
dat$uid <-  paste("i1_Gbif_", 1:nrow(dat), sep = "")

id1 <- dat[,c("decimalLatitude",
                  "decimalLongitude",
                  "family", "species",
                  "year", "month", "day", "recordedBy",
                  "identifiedBy", "sex",  "stateProvince",
                  "locality", "coordinatePrecision", "uid")]


#Clean and merge Gbig and inat----
#species in canary islands
id1.1 <- subset(id1, decimalLatitude > 35.8 & decimalLatitude < 43.88 & 
               decimalLongitude > - 10.11 & decimalLongitude < 4.56)

#species with only genus (Gbif, done using species column)
id1.2 <- id1.1[which(is.na(id1.1$species) == FALSE),]
id1.3 <- id1.2[grep(" ", id1.2$species, fixed = TRUE, value = FALSE),]

#Save data
write.csv(id1.3, file = "Data/Rawdata/online/i1_Gbif.csv")



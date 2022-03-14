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
inat$uid <- paste("i2_inaturalist_", 1:nrow(inat), sep = "")

id2 <- inat[, c("decimalLatitude",
                "decimalLongitude",
                "family", "species",
                "year", "month", "day", "recordedBy",
                "identifiedBy", "sex",  "stateProvince",
                "locality", "coordinatePrecision", "uid")]


#Clean and merge Gbig and inat----
#species in canary islands
id2.1 <- subset(id2, decimalLatitude > 35.8 & decimalLatitude < 43.88 & 
                  decimalLongitude > - 10.11 & decimalLongitude < 4.56)

#species with only genus (Gbif, done using species column)
id2.2 <- id2.1[which(is.na(id2.1$species) == FALSE),]
id2.3 <- id2.2[grep(" ", id2.2$species, fixed = TRUE, value = FALSE),]

#Save data
write.csv(id2.3, file = "Data/Rawdata/online/i2_Inaturalist.csv")



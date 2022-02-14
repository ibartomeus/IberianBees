#Load and merge Beefun----
install.packages("devtools")
require(devtools)
devtools::install_github("ibartomeus/BeeFunData")
library(BeeFunData)


install_github("BeeFunData", "ibartomeus")

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
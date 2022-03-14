source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

#This is a special processing file the data comes from the Beefun project and not a csv
#Installation of Beefun
#install.packages("devtools")
#require(devtools)
#devtools::install_github("ibartomeus/BeeFunData")

#Load library which contains the data
library(BeeFunData)
#Load data
data(all_interactions)

#Check data
head(all_interactions)
data(sites)
head(sites)
data(traits_pollinators_estimated)
head(traits_pollinators_estimated)

#Merge with sites
beefun <- merge(all_interactions, sites)
beefun <- merge(beefun, traits_pollinators_estimated)

#Check and filter by family of interest
unique(beefun$family)
beefun <- subset(beefun, family %in% c("Andrenidae", "Apidae", "Megachilidae",
                                       "Colletidae", "Melittidae"))
#Clean species
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

#Check colnames
compare_variables(check, beefun)

#Rename and add cols
beefun$Species <- beefun$species
beefun$Latitude <- beefun$latitude
beefun$Longitude <- beefun$longitude
beefun$family <- beefun$family
beefun$Year <- 2015
beefun$Collector <- "Curro Molina"
beefun$Determined.by <- "Oscar Aguado"
beefun$Province <- "Huelva"
beefun$Locality <- beefun$Site_ID            
beefun$Coordinate.precision <- "gps"
#Just by count and no frequency
beefun$Female <-  ifelse(beefun$Pollinator_sex =="female", "female", NA)
beefun$Male <-  ifelse(beefun$Pollinator_sex =="male", "male", NA)
#Convert to one if equal male or female
beefun$Female[beefun$Female=="female"] <- "1"
beefun$Male[beefun$Male=="male"] <- "1"
#Plants
beefun$Flowers.visited <- beefun$Plant_gen_sp
beefun$Reference.doi <- "http://doi.org/10.5281/zenodo.3364037"
beefun$Local_ID <- beefun$Pollinator_id
beefun$Authors.to.give.credit <- "I. Bartomeus, C. Molina"
beefun$Country <- "Spain"
beefun$Genus <- word(beefun$Species, 1)
beefun$Species <- word(beefun$Species, 2)

#Now add missing vars and drop extra
beefun <- add_missing_variables(check, beefun)
beefun <- drop_variables(check, beefun)

#Finally add uid
beefun$uid <-  paste("17_Bartomeus_etal_", 1:nrow(beefun), sep = "")

#Save data
write.table(x = beefun, file = 'Data/Processed_raw_data/17_Bartomeus_etal.csv', 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)



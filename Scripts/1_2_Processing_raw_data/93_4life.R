source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template


library(here)
library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(lubridate)

newdat <- read.csv(here("Data/Rawdata/csvs/93_4life.csv"), sep = ",")

#Compare vars
compare_variables(check, newdat) #Many variables missing.

#Add missing variables
newdat <- add_missing_variables(check, newdat)

#rename columns of scientic names of plants and pollinators

names(newdat)

names(newdat)[5] <- "flowers_sp"
names(newdat)[7] <- "pollinators_sp"

#Filter only bees but first we need to assign functional group

bee <- c("Amegilla", "Andrena", "Anthidiellum", "Anthidium", "Anthophora",
  "Apis", "Apoidea", "Bombus", "Ceratina", "Chelostoma",
  "Coelioxys", "Colletes", "Dasypoda", "Dioxys", "Eoanthidium",
  "Eucera", "Habropoda", "Halictidae", "Halictinae", "Halictus",
  "Heriades", "Hoplitis", "Hylaeus", "Lasioglossum",
  "Megachile", "Megachilidae", "Megachilinae", "Melecta",
  "Nomada", "Nomioides", "Osmia", "Panurgus",
  "Pseudoanthidium", "Rhodanthidium", "Seladonia",
  "Stelis", "Thyreus", "Vestitohalictus", "Xylocopa")


newdat <- newdat %>%
  mutate(group_func = 
           case_when(grepl(paste(bee, collapse = "|"), pollinators_sp) ~ "Bee",
      TRUE ~ "Other"))

newdat<- newdat %>%
  filter(group_func %in% c("Bee"))


#separate genus and species

newdat$Genus <-  word(newdat$pollinators_sp, 1)
newdat$Species <-  word(newdat$pollinators_sp, 2)
#filter only the ones identified to level species 
newdat <- newdat %>%
  filter(!is.na(Species) & !Species %in% c("sp.", "cf."))

#fix country, province and locality

newdat$Country <- newdat$country
#filter only Spain
unique(newdat$Country)
newdat <- newdat %>%
  filter(Country %in% c("Spain", "Portugal"))


#newdat$Locality <- newdat$locality #no info in the paper about localities, only this code
#unique(newdat$verbatimLocality) #EXTRACT LOCALITY FROM NATURA 2000 IF NEEDED 


#fix latitude and longitude

newdat$Longitude <- newdat$decimalLongitude
newdat$Latitude <- newdat$decimalLatitude

#fix dates: The date indicates when the photograph was taken (YYYY-MM-DD).
#It assums that the date of observation was the same as the date of record submission.

unique(newdat$eventDate)

newdat$eventDate <- newdat$eventDate %>%
  str_remove("\\*$") %>%
  parse_date_time(orders = c("dmy", "ymd")) %>%
  format("%Y/%m/%d")

newdat <- newdat %>%
  separate(eventDate,
           into = c("Year", "Month", "Day"), sep = "/") 

#fix sexes

newdat$Female <- 0
newdat$Male <- 0
newdat$Worker <- 0

#Add "1" in Not.specified where all Female, Male, Not.specified are NAs.
newdat$Not.specified <- ifelse((newdat$Female == 0 & newdat$Male == 0),1,0)

#complete missing variables from the template 

newdat$Reference.doi <- "https://doi.org/10.26786/1920-7603(2025)872"
newdat$Flowers.visited <- newdat$flowers_sp
newdat$Authors.to.give.credit <- "Barberis, M.; 
Bitonto, F. F.; Costantino, R.; 
Bianco, L.; Birtele, D.; Bonifacino, M.; 
Cangelmi, G.; Cap?, M.; Chroni, A.; D'Agostino, M.;
Dal Cin, M.; Devalez, J.; Bortolotti, L.; Flaminio, S.; 
Giac?, A.; Lenzi, L.; Magagnoli, S.; Minici, A.; Nakas, G.; 
Navarro, L.; Samuele, G.; S?nchez, J. M.; Petanidou, T.; 
Quaranta, M.; Ranalli, R.; Rossini, M.; Ruzzier, E.; Sgolastra, F.; 
Traveset, A.; Zenga, E. L.; Galloni, M."

#include information about habitat here to not lose it. 
#The type of landscape surrounding the observation site. Options are "urban", 
#"periurban", "hills", "mountain", "lowland", "island", "archaeological site", 
#"seaside", "riverside", "lakeside", or a combination of multiple answers.
#This could either be entered by users or -when missing -deducted a posteriori
#by consulting a map

#this is the code used to join the three individual dataset provided in the paper. 

newdat$Notes.and.queries <- newdat$eventID

#Add unique identifier
newdat$uid <- paste("93_4life", 1:nrow(newdat), sep = "_")

#Drop variables
newdat <- drop_variables(check, newdat)

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/93_4life.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)




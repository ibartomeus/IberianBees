library(here)
library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(lubridate)

data <- read.csv(here("Data/Rawdata/csvs/93_4life.csv"), sep = ",")

#rename columns of scientic names of plants and pollinators

names(data)

names(data)[5] <- "flowers_sp"
names(data)[7] <- "pollinators_sp"

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


data <- data %>%
  mutate(group_func = 
           case_when(grepl(paste(bee, collapse = "|"), pollinators_sp) ~ "Bee",
      TRUE ~ "Other"))

data<- data %>%
  filter(group_func %in% c("Bee"))


#separate genus and species
data <- data %>%
  separate(
    pollinators_sp,
    into = c("Genus", "Species"),
    sep = " ",
    extra = "merge",
    fill = "right"
  )

data$Subgenus <- NA 
data$Subspecies <- NA 

#fix country, province and locality

data$Country <- data$country
data$Locality <- data$locality #no info in the paper about localities, only this code
data$Province <- NA

#fix latitude and longitude

data$Longitude <- as.numeric(data$decimalLongitude)
data$Latitude <- as.numeric(data$decimalLatitude)
data$Coordinate.precision <- NA

unique(data$verbatimLocality) #EXTRACT LOCALITY FROM NATURA 2000 IF NEEDED 

#fix dates: The date indicates when the photograph was taken (YYYY-MM-DD).
#It assums that the date of observation was the same as the date of record submission.

unique(data$eventDate)

data$eventDate <- data$eventDate %>%
  str_remove("\\*$") %>%
  parse_date_time(orders = c("dmy", "ymd")) %>%
  format("%Y/%m/%d")

data <- data %>%
  separate(eventDate,
           into = c("Year", "Month", "Day"), sep = "/") 


data$Start.date <- NA
data$End.date <- NA 

#fix sexes

data$Female <- 0
data$Male <- 0
data$Worker <- 0

#Add "1" in Not.specified where all Female, Male, Not.specified are NAs.
data$Not.specified <- ifelse((data$Female == 0 & data$Male == 0),1,0)

#complete missing variables from the template 

data$Collector <- NA
data$Determined.by <- NA 
data$Reference.doi <- "https://doi.org/10.26786/1920-7603(2025)872"
data$Flowers.visited <- data$flowers_sp
data$Local_ID <- NA 
data$Authors.to.give.credit <- "Barberis, M.; 
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

data$Any.other.additional.data <- data$habitat

#this is the code used to join the three individual dataset provided in the paper. 

data$Notes.and.queries <- data$eventID

#Select columns for final template csv

data <- data %>%
  select(Genus, Subgenus, Species, Subspecies, Country, Province, Locality, 
         Latitude, Longitude, Coordinate.precision, Year, Month, Day, 
         Start.date, End.date, Collector, Determined.by, Female, Male,
         Worker, Not.specified, Reference.doi, Flowers.visited, Local_ID, 
         Authors.to.give.credit, Any.other.additional.data, Notes.and.queries)

#Save data
write.table(x = data, file = "Data/Processed_raw_data/93_4life", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)




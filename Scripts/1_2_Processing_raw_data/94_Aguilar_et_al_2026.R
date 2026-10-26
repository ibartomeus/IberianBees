source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template


library(here)
library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(lubridate)

newdat <- read.csv(here("Data/Rawdata/csvs/94_Aguilar_et_al_2026.csv"), sep = ";")

#Compare vars
compare_variables(check, newdat) #Many variables missing.

#Add missing variables
newdat <- add_missing_variables(check, newdat)


#data <- data[1:833, ]
#add variables from template

newdat$Country <- "Spain"
newdat$Province <- "Barcelona"
newdat$Locality <- "Viladecans"
newdat$Collector <- newdat$Collected.by
newdat$Determined.by <- newdat$Identified.by

newdat$Reference.doi <- "10.17632/y2y4rpfpvr.1"
newdat$Local_ID <- "The Wildlife Ecology and Health Lab, UAB (https://weh.cat/)"
newdat$Authors.to.give.credit <- "Aguilar, M.; Carbonell, R.; Romero, J.L.; Batlle-Benaiges, J.; Coromina, J.; Peguero, G.; Hern?ndez-Castellano, C."
newdat$Any.other.additional.data <- newdat$Plot

#add subgenus to the different species 

newdat <- newdat %>%
  mutate(
    Subgenus = case_when(
      Species %in% c("Andrena aeneiventris ") ~ "Aenandrena",
      Species %in% c("Andrena colletiformis") ~ "Brachyandrena",
      Species %in% c("Andrena cinerea") ~ "Chlorandrena",
      Species %in% c("Andrena humilis") ~ "Chlorandrena",
      Species %in% c("Andrena nigroolivacea") ~ "Chlorandrena",
      Species %in% c("Andrena rhenana") ~ "Chlorandrena",
      Species %in% c("Andrena senecionis") ~ "Chlorandrena",
      Species %in% c("Andrena hesperia") ~ "Chrysandrena",
      Species %in% c("Andrena vulpecula") ~ "Euandrena",
      Species %in% c("Andrena flavipes") ~ "Melandrena", 
      Species %in% c("Andrena limata") ~ "Melandrena", 
      Species %in% c("Andrena nigroaenea") ~ "Melandrena", 
      Species %in% c("Andrena alfkenella") ~ "Micrandrena", 
      Species %in% c("Andrena djelfensis") ~ "Micrandrena", 
      Species %in% c("Andrena nana") ~ "Micrandrena", 
      Species %in% c("Andrena spreta") ~ "Micrandrena",      
      Species %in% c("Andrena tenuistriata") ~ "Micrandrena",
      Species %in% c("Andrena agilissima") ~ "Plastandrena", 
      Species %in% c("Andrena pilipes") ~ "Plastandrena",
      Species %in% c("Andrena orbitalis") ~ "Rufandrena",
      Species %in% c("Andrena propinqua") ~ "Simandrena",
      Species %in% c("Andrena afzeliella") ~ "Taeniandrena",
      Species %in% c("Panurgus dentipes") ~ "Panurgus",
      Species %in% c("Amegilla garrula") ~ "Amegilla",
      Species %in% c("Amegilla quadrifasciata") ~ "Amegilla",
      Species %in% c("Amegilla albigena") ~ "Zebramegilla",
      Species %in% c("Amegilla savignyi") ~ "Zebramegilla",
      Species %in% c("Amegilla talaris") ~ "Zebramegilla",
      Species %in% c("Anthophora crinipes") ~ "Anthophora",
      Species %in% c("Anthophora plumipes") ~ "Anthophora",
      Species %in% c("Anthophora pubescens") ~ "Caranthophora",
      Species %in% c("Anthophora bimaculata") ~ "Heliophila",
      Species %in% c("Anthophora crinipes") ~ "Paramegilla", 
      Species %in% c("Anthophora femorata") ~ "Anthophora",
      Species %in% c("Bombus terrestris") ~ "Bombus",
      Species %in% c("Bombus pascuorum") ~ "Thoracobombus",
      Species %in% c("Ceratina cucurbitina") ~ "Ceratina",
      Species %in% c("Ceratina parvula") ~ "Dalyatina",
      Species %in% c("Ceratina callosa") ~ "Euceratina",
      Species %in% c("Ceratina cyanea") ~ "Euceratina",
      Species %in% c("Ceratina dallatorreana") ~ "Euceratina",
      Species %in% c("Eucera colaris") ~ "Eucera",
      Species %in% c("Eucera longicornis") ~ "Eucera",
      Species %in% c("Eucera nigrescens") ~ "Eucera",
      Species %in% c("Eucera nigrilabris") ~ "Eucera",
      Species %in% c("Eucera numida") ~ "Eucera",
      Species %in% c("Eucera pollinosa") ~ "Eucera",
      Species %in% c("Nomada beaumonti") ~ "Collicula",
      Species %in% c("Nomada integra") ~ "Collicula",
      Species %in% c("Nomada panurgina") ~ "Gestamen",
      Species %in% c("Nomada bifasciata") ~ "Heminomada",
      Species %in% c("Nomada goodeniana") ~ "Heminomada",
      Species %in% c("Nomada succincta") ~ "Heminomada",
      Species %in% c("Nomada sheppardana") ~ "Mininomada",
      Species %in% c("Nomada piccioliana") ~ "Nomada",
      Species %in% c("Xylocopa valga") ~ "Xylocopa",
      Species %in% c("Hylaeus brevicorniss") ~ "Dentigera",
      Species %in% c("Hylaeus imparilis") ~ "Dentigera",
      Species %in% c("Hylaeus annularis") ~ "Lambdopsis",
      Species %in% c("Hylaeus dilatatus") ~ "Lambdopsis",
      Species %in% c("Hylaeus clypearis") ~ "Paraprosopis",
      Species %in% c("Hylaeus pictipes") ~ "Paraprosopis",
      Species %in% c("Hylaeus taeniolatus") ~ "Paraprosopis",
      Species %in% c("Hylaeus coriaceus") ~ "Prosopis",
      Species %in% c("Hylaeus gibbus") ~ "Prosopis",
      Species %in% c("Hylaeus pictus") ~ "Prosopis",
      Species %in% c("Hylaeus punctatus") ~ "Spatulariella",
      Species %in% c("Halictus brunnescens") ~ "Halictus",
      Species %in% c("Halictus fulvipes") ~ "Hexataenites",
      Species %in% c("Halictus scabiosae") ~ "Hexataenites",
      Species %in% c("Lasioglossum aureolum") ~ "Dialictus",
      Species %in% c("Lasioglossum morios") ~ "Dialictus",
      Species %in% c("Lasioglossum nitidulum") ~ "Dialictus",
      Species %in% c("Lasioglossum clypeare") ~ "Hemihalictus",
      Species %in% c("Lasioglossum griseolum") ~ "Hemihalictus",
      Species %in% c("Lasioglossum ibericum") ~ "Hemihalictus",
      Species %in% c("Lasioglossum limbellus") ~ "Hemihalictus",
      Species %in% c("Lasioglossum minutissimum") ~ "Hemihalictus",
      Species %in% c("Lasioglossum pauperatum") ~ "Hemihalictus",
      Species %in% c("Lasioglossum pseudoplanulum") ~ "Hemihalictus",
      Species %in% c("Lasioglossum punctatissimum") ~ "Hemihalictus",
      Species %in% c("Lasioglossum transitorium") ~ "Hemihalictus",
      Species %in% c("Lasioglossum truncaticolle") ~ "Hemihalictus",
      Species %in% c("Lasioglossum villosulum") ~ "Hemihalictus",
      Species %in% c("Lasioglossum callizonium") ~ "Leuchalictus",
      Species %in% c("Lasioglossum leucozonium") ~ "Leuchalictus",
      Species %in% c("Lasioglossum zonulus") ~ "Leuchalictus",
      Species %in% c("Lasioglossum glabriusculum") ~ "Pyghalictus",
      Species %in% c("Lasioglossum politum") ~ "Pyghalictus",
      Species %in% c("Lasioglossum algericolellum") ~ "Sphecodogastra",
      Species %in% c("Lasioglossum interruptum") ~ "Sphecodogastra",
      Species %in% c("Lasioglossum malachurum") ~ "Sphecodogastra",
      Species %in% c("Lasioglossum mediterraneum") ~ "Sphecodogastra",
      Species %in% c("Lasioglossum nigripes") ~ "Sphecodogastra",
      Species %in% c("Lasioglossum pauxillum") ~ "Sphecodogastra",
      Species %in% c("Seladonia pollinosa") ~ "Mucoreohalictus",
      Species %in% c("Seladonia gemmea") ~ "Seladonia",
      Species %in% c("Seladonia smaragdula") ~ "Seladonia",
      Species %in% c("Seladonia subaurata") ~ "Seladonia",
      Species %in% c("Anthidium cingulatum") ~ "Anthidium",
      Species %in% c("Anthidium florentinum") ~ "Anthidium",
      Species %in% c("Anthidium loti") ~ "Anthidium",
      Species %in% c("Anthidium manicatum") ~ "Anthidium",
      Species %in% c("Anthidium oblongatum") ~ "Proanthidium",
      Species %in% c("Pseudoanthidium scapulare") ~ "Pseudoanthidium",
      Species %in% c("Rhodanthidium septemdentatum") ~ "Rhodanthidium",
      Species %in% c("Stelis breviuscula") ~ "Stelis",
      Species %in% c("Stelis punctulatissima") ~ "Stelis",
      Species %in% c("Trachusa interrupta") ~ "Paraanthidium",
      Species %in% c("Coelioxys afer") ~ "Allocoelioxys",
      Species %in% c("Coelioxys argenteus") ~ "Allocoelioxys",
      Species %in% c("Coelioxys echinatus") ~ "Allocoelioxys",
      Species %in% c("Coelioxys aurolimbatus") ~ "Rozeniana",
      Species %in% c("Megachile sculpturalis") ~ "Callomegachile",
      Species %in% c("Megachile albisecta") ~ "Creightonella",
      Species %in% c("Megachile apicalis") ~ "Eutricharaea",
      Species %in% c("Megachile argentata") ~ "Eutricharaea",
      Species %in% c("Megachile leachella") ~ "Eutricharaea",
      Species %in% c("Megachile pusilla") ~ "Eutricharaea",
      Species %in% c("Megachile rotundata") ~ "Eutricharaea",
      Species %in% c("Megachile centuncularis") ~ "Megachile",
      Species %in% c("Megachile melanopyga") ~ "Megachile",
      Species %in% c("Megachile pilicrus") ~ "Megachile",
      Species %in% c("Megachile versicolor") ~ "Megachile",
      Species %in% c("Megachile ericetorum") ~ "Pseudomegachile",
      Species %in% c("Megachile willughbiella") ~ "Xanthosarus",
      Species %in% c("Heriades crenulata") ~ "Heriades",
      Species %in% c("Heriades rubicola") ~ "Heriades",
      Species %in% c("Hoplitis leucomelana") ~ "Alcidamea",
      Species %in% c("Hoplitis adunca") ~ "Hoplitis",
      Species %in% c("Hoplitis benoisti") ~ "Hoplitis",
      Species %in% c("Osmia rufohirta") ~ "Allosmia",
      Species %in% c("Osmia andrenoides") ~ "Erythrosmia",
      Species %in% c("Osmia aurulenta") ~ "Helicosmia",
      Species %in% c("Osmia caerulescens") ~ "Helicosmia",
      Species %in% c("Osmia dimidiata") ~ "Helicosmia",
      Species %in% c("Osmia latreillei") ~ "Helicosmia",
      Species %in% c("Osmia niveata") ~ "Helicosmia",
      Species %in% c("Osmia brevicornis") ~ "Metallinella",
      Species %in% c("Osmia bicornis") ~ "Osmia",
      Species %in% c("Osmia emarginata") ~ "Osmia",
      Species %in% c("Osmia submicans") ~ "Pyrosmia",
      Species %in% c("Protosmia capitata") ~ "Chelostomopsis",
      TRUE ~ NA_character_))


#separate genus and species 
newdat <- newdat %>%
  separate(Species, into = c("Genus", "Species"), sep = " ")

#fix sex columns

unique(newdat$Sex)
newdat <- newdat %>%
  mutate(
    Female = ifelse(Sex == "F", 1, 0),
    Male = ifelse(Sex == "M", 1, 0))

#Add "1" in Not.specified where all Female, Male, Not.specified are NAs.
newdat$Not.specified <- ifelse((newdat$Female == 0 & newdat$Male == 0),1,0)

#fix dates

newdat <- newdat %>%
  separate(Date,
           into = c("Day", "Month", "Year"),
           sep = "/")

#fix coordinates
newdat <- newdat %>%
  separate(Coordinates,
           into = c("Latitude", "Longitude"),
           sep = ",")
#correct whitespace
newdat <- newdat %>%
  mutate(Longitude = trimws(Longitude), 
         Latitude = trimws((Latitude)))

#Add unique identifier
newdat$uid <- paste("94_Aguilar_et_al_2026", 1:nrow(newdat), sep = "_")

#Drop variables
newdat <- drop_variables(check, newdat)


#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/94_Aguilar_et_al_2026.csv", 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)


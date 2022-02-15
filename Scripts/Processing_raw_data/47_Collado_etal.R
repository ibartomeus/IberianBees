source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 47_Collado_etal  ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = "Data/Rawdata/csvs/47_Collado_etal.csv", sep = ";")

#Check vars
compare_variables(check, newdat)
#Rename variables
colnames(newdat)[which(colnames(newdat) == 'Local_id')] <- 'Local_ID' 
colnames(newdat)[which(colnames(newdat) == 'collector')] <- 'Collector' 
colnames(newdat)[which(colnames(newdat) == 'taxonomist')] <- 'Determined.by' 
colnames(newdat)[which(colnames(newdat) == 'm_plant_species')] <- 'Flowers.visited' 
colnames(newdat)[which(colnames(newdat) == 'Location')] <- 'Locality' 

#Recover some more coordinates
#There are two types mgrs and utm
#mgrs seems straightforward
temp <- mgrs::mgrs_to_latlng(as.character(newdat$UTM))
#Now lets fill the missing values in lat/lon with these values
lat_d <- as.data.frame(temp$lat)
lon_d <- as.data.frame(temp$lng)
colnames(lat_d) <- "l" #New colname for simplicity
colnames(lon_d) <- "l" #New colname for simplicity
#store cols
lat_d$lat <- newdat$Latitude
lon_d$lon <- newdat$Longitude
#Workaround to fill missing lat  and lon (needs Tydiverse)
lat_d_1 <- data.frame(t(lat_d)) %>% 
  fill(., names(.)) %>%
  t() %>% as.data.frame()

lon_d_1 <- data.frame(t(lon_d)) %>% 
  fill(., names(.)) %>%
  t() %>% as.data.frame()
#Takes a bit of time
#Works well, add now the column back to the dataframe
newdat$Latitude <- lat_d_1$lat 
newdat$Longitude <- lon_d_1$lon 

#check now how to work with the UTM ones
library(stringr)
library(dplyr)
levels(factor(newdat$UTM))
temp <- newdat %>%filter(str_detect(UTM, 
                                    c("29S ","29T ", "30T ", "31S ", "31T ")))
#Just 2 records to fill... 
#I do it manually by record
#30T 	4656952 308856
#31T 4684106 431397
c_1 <- mgrs::utm_to_latlng(29, "N", 308856, 4656952)
c_2 <- mgrs::utm_to_latlng(29, "N", 431397, 4684106)
#Coordinate utm 1
newdat$Latitude[newdat$UTM=="30T 	4656952 308856"] <- c_1[1]
newdat$Longitude[newdat$UTM=="30T 	4656952 308856"] <- c_1[2]
#Coordinate utm 2
newdat$Latitude[newdat$UTM=="31T 4684106 431397"] <- c_2[1]
newdat$Longitude[newdat$UTM=="31T 4684106 431397"] <- c_2[2]

#Long / lat not in numeric :( 
unique(newdat$Latitude)
newdat$Latitude <- as.character(newdat$Latitude)
newdat$Latitude[which(newdat$Latitude %in% c("40.807867,"))] <- 40.807867
newdat$Latitude[which(newdat$Latitude %in% c(""))] <- NA
newdat$Latitude[which(newdat$Latitude %in% c("42.566667, 0.45"))] <- 42.566667
newdat$Latitude[which(newdat$Latitude %in% c("42.55, -0.55"))] <- 42.55
newdat$Longitude <- as.character(newdat$Longitude)
unique(newdat$Longitude)
newdat$Longitude[which(newdat$Longitude %in% c("42.566667, 0.45"))] <- 0.45
newdat$Longitude[which(newdat$Longitude %in% c(""))] <- NA
newdat$Longitude[which(newdat$Longitude %in% c("42.55, -0.55"))] <- -0.55
newdat$Latitude <- as.numeric(as.character(newdat$Latitude))
newdat$Longitude <- as.numeric(as.character(newdat$Longitude))

#Fix some impossible coordinates manually
newdat$Latitude[newdat$Latitude==41745.00000] <- 41.745 #Rabano de aliste
newdat$Latitude[newdat$Latitude==43517.00000] <- 43.517 #mondigo
newdat$Longitude[newdat$Longitude==-7133.0000000] <- -7.133 #mondigo
newdat$Latitude[newdat$Latitude==41499.00000] <- 41.499 #Teyà
newdat$Longitude[newdat$Longitude==2324.0000000] <- 2.324 
newdat$Latitude[newdat$Latitude==41393.00000] <- 41.393 
newdat$Latitude[newdat$Latitude==40568.00000] <- 40.568 
newdat$Longitude[newdat$Longitude==-5385.000000] <- -5.385 #Fuentelapeña

#Still two coordenates seem incorrect
#[1] "6.4550575"  (lagos)      "9.9949634" (huesca)
#Fix manually
levels(factor(newdat$Latitude))
newdat$Latitude[newdat$Latitude=="6.4550575"] <- "37.1028"
newdat$Longitude[newdat$Latitude=="37.1028"] <- "-8.67422"
newdat$Latitude[newdat$Latitude=="9.9949634"] <- "42.6287"
newdat$Longitude[newdat$Latitude=="42.6287"] <- "-0.1127"
#Now looks good to me

unique(newdat$Sex)
unique(newdat$Individuals) 
newdat$Male <- ifelse(newdat$Sex %in% c("M"), newdat$Individuals, 0)
newdat$Female <- ifelse(newdat$Sex %in% c("F", "Q"), newdat$Individuals, 0)
newdat$Worker <- ifelse(newdat$Sex %in% c("W"), newdat$Individuals, 0)
newdat$Not.specified <- ifelse(!newdat$Sex %in% c("W", "F", "Q", "M"), newdat$Individuals, 0)
compare_variables(check, newdat)
colnames(newdat)[which(colnames(newdat) == 'Published.by')] <- 'Authors.to.give.credit' 
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
(temp <- extract_pieces(newdat$Species, species = TRUE))
newdat$Species <- temp$piece1
#Subspecies also needs cleaning!
#subsepecies
temp <- strsplit(x = as.character(newdat$Subspecies), split = " ")
length(temp) == length(newdat$Subspecies)
newdat$Subspecies <- as.character(newdat$Subspecies)
newdat$Subspecies[which(newdat$Subspecies == "")] <- NA
for (i in which(!is.na(newdat$Subspecies))){
  newdat$Subspecies[i] <- temp[[i]][3]
}
head(newdat)
newdat$Authors.to.give.credit <- "Compiled by M.A. Collado"
newdat <- add_uid(newdat = newdat, '47_Collado_etal_')
summary(newdat)

#Check levels
levels(factor(newdat$Province))
newdat$Province[which(newdat$Province %in% c(""))] <- NA
newdat$Province[which(newdat$Province %in% c(" "))] <- NA

newdat$Province[newdat$Locality=="Espluga de Francoli"]<- "Tarragona"
newdat$Province[newdat$Locality=="Castellón de la Plana"]<- "Castellón"
newdat$Province[newdat$Locality=="Las Sabinas"]<- "Granada"
newdat$Province[newdat$Locality=="Borreguiles"]<- "Granada"
newdat$Province[newdat$Locality=="Valle Niza"]<- "Malaga"
newdat$Province[newdat$Locality=="Jimena"]<- "Jaén"
newdat$Province[newdat$Locality=="25km SW.Cartagena"]<- "Murcia"
newdat$Province[newdat$Province=="Avila"]<- "Ávila"
newdat$Province[newdat$Province=="Alava"]<- "Álava"
newdat$Province[newdat$Province=="A Coruña"]<- "La Coruña"
newdat$Province[newdat$Province=="Guipuzcua"]<- "Guipúzcoa"
newdat$Province[newdat$Province=="Guipuzcoa"]<- "Guipúzcoa"
newdat$Province[newdat$Province=="Guipúzcua"]<- "Guipúzcoa"
newdat$Province[newdat$Province=="Girona"]<- "Gerona"
newdat$Province[newdat$Province=="CÓRDOBA"]<- "Córdoba"
newdat$Province[newdat$Province=="Lleida"]<- "Lérida"
newdat$Province[newdat$Province=="Lerida"]<- "Lérida"
newdat$Province[newdat$Province=="Provincia de Huesca"]<- "Huesca"
newdat$Province[newdat$Province=="Gran canaria"]<- "Gran Canaria"

#Check levels
options(max.print=500)
levels(factor(newdat$Locality))
newdat$Locality[which(newdat$Locality %in% c(""))] <- NA

newdat$Locality[newdat$Locality=="A Coruña"]<- "La Coruña"
newdat$Locality[newdat$Locality=="Alcalá de henares"]<- "Alcalá de Henares"
newdat$Locality[newdat$Locality=="Alcuescar"]<- "Alcuéscar"
newdat$Locality[newdat$Locality=="Baides"]<- "Baídes"
newdat$Locality[newdat$Locality=="Baleña"]<- "Baleñá"
newdat$Locality[newdat$Locality=="Balsain"]<- "Balsaín"
newdat$Locality[newdat$Locality=="Balsain"]<- "Balsaín"
newdat$Locality[newdat$Locality=="Barbasto"]<- "Barbastro"
newdat$Locality[newdat$Locality=="Caldas de Maravella"]<- "Caldas de Malavella"
newdat$Locality[newdat$Locality=="Caldas de Montbouy"]<- "Caldas de Montbui"
newdat$Locality[newdat$Locality=="Caldas de Montbuy"]<- "Caldas de Montbui"
newdat$Locality[newdat$Locality=="Casas de D. Pedro."]<- "Casas de D. Pedro"
newdat$Locality[newdat$Locality=="Castelldefels"]<- "Castelldeféls"
newdat$Locality[newdat$Locality=="Cazorla"]<- "Sierra de Cazorla"
newdat$Locality[newdat$Locality=="Cazorla (Sa Cazorla)"]<- "Sierra de Cazorla"
newdat$Locality[newdat$Locality=="Colmenar viejo"]<- "Colmenar Viejo"
newdat$Locality[newdat$Locality=="Doñana"]<- "Parque Nacional de Doñana"
newdat$Locality[newdat$Locality=="Doñana National Park"]<- "Parque Nacional de Doñana"
newdat$Locality[newdat$Locality=="Estany de Mont cortes"]<- "Estany de Montcortès"
newdat$Locality[newdat$Locality=="Estany de Montcortes"]<- "Estany de Montcortès"
newdat$Locality[newdat$Locality=="Forníllos de Fermoselle"] <- "Fornillos de Fermoselle"
newdat$Locality[newdat$Locality=="Fuenterrabia"] <- "Fuenterrabía"
newdat$Locality[newdat$Locality=="Gerona"] <- "Girona"
newdat$Locality[newdat$Locality=="Gosol"] <- "Gósol"
newdat$Locality[newdat$Locality=="Hoya de la Guija"] <- "Hoyo de la Guija"
newdat$Locality[newdat$Locality=="La garganta"] <- "La Garganta"
newdat$Locality[newdat$Locality=="La garriga"] <- "La Garriga"
newdat$Locality[newdat$Locality=="Los molinos"] <- "Los Molinos"
newdat$Locality[newdat$Locality=="Los Moblinos"] <- "Los Molinos"
newdat$Locality[newdat$Locality=="Martolell"] <- "Martorell"
newdat$Locality[newdat$Locality=="Nuevo Batzan"] <- "Nuevo Batzán"
newdat$Locality[newdat$Locality=="Nuevo Baztan"] <- "Nuevo Batzán"
newdat$Locality[newdat$Locality=="Ormaitztegui"] <- "Ormaiztegi"
newdat$Locality[newdat$Locality=="Ormaíztegui"] <- "Ormaiztegi"
newdat$Locality[newdat$Locality=="Ormáiztegui"] <- "Ormaiztegi"
newdat$Locality[newdat$Locality=="Alcañices"] <- "Alcañices"
newdat$Locality[newdat$Locality=="Almacellas"] <- "Almacelles"
newdat$Locality[newdat$Locality=="Andavías"] <- "Andavías"
newdat$Locality[newdat$Locality=="Bobadilla del campo"] <- "Bobadilla del Campo"
newdat$Locality[newdat$Locality=="Bronchelas"] <- "Bronchales"
newdat$Locality[newdat$Locality=="Cabanas"] <- "Cabañas"
newdat$Locality[newdat$Locality=="Centellas"] <- "Centelles"
newdat$Locality[newdat$Locality=="Cerro colgado"] <- "Cerro Colgado"
newdat$Locality[newdat$Locality=="Yanguas de E[resma]"] <- "Yanguas de Eresma"
newdat$Locality[newdat$Locality=="Zaldivar"] <- "Zaldívar"
newdat$Locality[newdat$Locality=="Valdastilla"] <- "Valdastillas"
newdat$Locality[newdat$Locality=="Uña"] <- "Uña de Quintana" 
newdat$Locality[newdat$Locality=="Tabascan"] <- "Tabascán" 
newdat$Locality[newdat$Locality=="Soller"] <- "Sóller" 
newdat$Locality[newdat$Locality=="Sierra palomera"] <- "Sierra Palomera" 
newdat$Locality[newdat$Locality=="Sierra nevada"] <- "Sierra Nevada"  
newdat$Locality[newdat$Locality=="Sierra del Cadi"] <- "Sierra del Cadí"  
newdat$Locality[newdat$Locality=="Sierra de V iejas" ] <- "Sierra de Viejas"  
newdat$Locality[newdat$Locality=="Selva de Zurita" ] <- "Selva de Zuriza"  
newdat$Locality[newdat$Locality=="Santa Creu de Olorde" ] <- "Santa Cruz de Olorde"  
newdat$Locality[newdat$Locality=="Sant Joan de Abadesses" ] <- "Sant Joan de les Abadeses"  
newdat$Locality[newdat$Locality=="San Lorenzo de Morumys" ] <- "San Lorenzo de Morunys"  
newdat$Locality[newdat$Locality=="San Llorent del Munt" ] <- "San Llorent del Mont"  
newdat$Locality[newdat$Locality=="San Llorent de Mont" ] <- "San Llorent del Mont"  
newdat$Locality[newdat$Locality=="San Julian de la Cabrera" ] <- "San Julián de la Cabrera" 
newdat$Locality[newdat$Locality=="San Juán de la Peña"  ] <- "San Juan de la Peña"
newdat$Locality[newdat$Locality=="Rosinos de Vidríales"  ] <- "Rosinos de Vidrialea"
newdat$Locality[newdat$Locality=="Puebla de D. Fabriques"  ] <- "Puebla de Don Fadrique"
newdat$Locality[newdat$Locality=="Puebla de D. Fadrique"  ] <- "Puebla de Don Fadrique"
#Can be better but good for now...

#Now collector
levels(factor(newdat$Collector))
newdat$Collector[which(newdat$Collector %in% c(""))] <- NA
newdat$Collector[which(newdat$Collector %in% c("A. G. Velázquez"))] <- "A.G. Velázquez"
newdat$Collector[which(newdat$Collector %in% c("A. W. Ebmer"))] <- "A.W. Ebmer"
newdat$Collector[which(newdat$Collector %in% c("ANDRÉ"))] <- "André"
newdat$Collector[which(newdat$Collector %in% c("Castro, L."))] <- "L. Castro"
newdat$Collector[which(newdat$Collector %in% c("Castro, L., Herrera, C."))] <- "L. Castro, C. Herrera"
newdat$Collector[which(newdat$Collector %in% c("F. J. Ortiz-Sánchez"))] <- "F.J. Ortiz-Sánchez"
newdat$Collector[which(newdat$Collector %in% c("Gª Mercet"))] <- "G. Mercet"
newdat$Collector[which(newdat$Collector %in% c("García Mercet"))] <- "G. Mercet"
newdat$Collector[which(newdat$Collector %in% c("Herrera, C.t"))] <- "C. Herrera"
newdat$Collector[which(newdat$Collector %in% c("J. A. Acosta"))] <- "J.A. Acosta"
newdat$Collector[which(newdat$Collector %in% c("J. A. González"))] <- "J.A. González"
newdat$Collector[which(newdat$Collector %in% c("J. R. Obeso"))] <- "J.R. Obeso"
newdat$Collector[which(newdat$Collector %in% c("Jimenez, A."))] <- "A. Jimenez"
newdat$Collector[which(newdat$Collector %in% c("K. M. Guichard"))] <- "K.M. Guichard"
newdat$Collector[which(newdat$Collector %in% c("Madero, A."))] <- "A. Madero"
newdat$Collector[which(newdat$Collector %in% c("Nieves & Rey"))] <- "Nieves y Rey"
newdat$Collector[which(newdat$Collector %in% c("Ortiz-Sànchez, F.J."))] <- "F.J. Ortiz-Sánchez"
newdat$Collector[which(newdat$Collector %in% c("P. De la Rúa"))] <- "P. de la Rúa"
newdat$Collector[which(newdat$Collector %in% c("PÉREZ"))] <- "Pérez"
newdat$Collector[which(newdat$Collector %in% c("Pérez, F.J."))] <- "F.J. Pérez"
newdat$Collector[which(newdat$Collector %in% c("Rey del Castillo, C., Nieves-Aldrey, J.L."))] <- "C. Rey del Castillo, J.L. Nieves-Aldrey"
newdat$Collector[which(newdat$Collector %in% c("S. F-Gayubo"))] <- "S.F. Gayubo"
newdat$Collector[which(newdat$Collector %in% c("S. F. Gayubo"))] <- "S.F. Gayubo"
newdat$Collector[which(newdat$Collector %in% c("S. V. Peris"))] <- "S.V. Peris"
newdat$Collector[which(newdat$Collector %in% c("SCHMIEDEKN"))] <- "Schmiedekn"
newdat$Collector[which(newdat$Collector %in% c("Tinaut, A."))] <- "A. Tinaut"
newdat$Collector[which(newdat$Collector %in% c("V. Monsterrat"))] <- "V. Montserrat"
newdat$Collector[which(newdat$Collector %in% c("VACHAL"))] <- "Vachal"
newdat$Collector[which(newdat$Collector %in% c("C. Heras y S.F. Gayubo"))] <- "C. Heras, S.F. Gayubo"
newdat$Collector[which(newdat$Collector %in% c("Barranco, P."))] <- "P. Barranco"
newdat$Collector[which(newdat$Collector %in% c("Baena, M."))] <- "M. Baena"
newdat$Collector[which(newdat$Collector %in% c("Asensio & Parker"))] <- "Asensio, Parker"
newdat$Collector[which(newdat$Collector %in% c("´CE"))] <- "CE"

#Now determined by column
levels(factor(newdat$Determined.by))
newdat$Determined.by[which(newdat$Determined.by %in% c(""))] <- NA
newdat$Determined.by[which(newdat$Determined.by %in% c("Asensio, E."))] <- "E. Asensio"
newdat$Determined.by[which(newdat$Determined.by %in% c("Báez, J., Bowden, J."))] <- "J. Báez, J. Bowden"
newdat$Determined.by[which(newdat$Determined.by %in% c("C. Ornosa & M.D. Martínez"))] <- "C. Ornosa, M.D. Martínez"
newdat$Determined.by[which(newdat$Determined.by %in% c("C. Ornosa, F. Torres & F. J. Ortiz-Sánchez"))] <- "C. Ornosa, F. Torres, F.J. Ortiz-Sánchez"
newdat$Determined.by[which(newdat$Determined.by %in% c("Cobos, A."))] <- "A. Cobos"
newdat$Determined.by[which(newdat$Determined.by %in% c("Dathe, H. H., Kuhlmann, M."))] <- "H.H. Dathe, M. Kuhlmann"
newdat$Determined.by[grepl("Exp. In", newdat$Determined.by, ignore.case=FALSE)] <- "Expedición del Instituto Español de Entomología"
newdat$Determined.by[which(newdat$Determined.by %in% c("F. J. Ortiz-Sánchez"))] <- "F.J. Ortiz-Sánchez"
newdat$Determined.by[which(newdat$Determined.by %in% c("García Valera"))] <- "García Varela"
newdat$Determined.by[which(newdat$Determined.by %in% c("García y Varela"))] <- "García Varela"
newdat$Determined.by[which(newdat$Determined.by %in% c("Gayubo, S. F."))] <- "S.F. Gayubo"
newdat$Determined.by[which(newdat$Determined.by %in% c("Gil-Collado"))] <- "Gil Collado"
newdat$Determined.by[which(newdat$Determined.by %in% c("Gusenleitner, F."))] <- "F. Gusenleitner"
newdat$Determined.by[which(newdat$Determined.by %in% c("Herrera, C. M., Amat, C. M."))] <- "C.M. Herrera, C.M. Amat"
newdat$Determined.by[which(newdat$Determined.by %in% c("J. R. Obeso"))] <- "J.R. Obeso"
newdat$Determined.by[which(newdat$Determined.by %in% c("Marcos, M. A."))] <- "M.A. Marcos"
newdat$Determined.by[which(newdat$Determined.by %in% c("O Contreras"))] <- "O. Contreras"
newdat$Determined.by[which(newdat$Determined.by %in% c("Sag. y Nov."))] <- "Sagarra y Novellas"
newdat$Determined.by[which(newdat$Determined.by %in% c("Vives, A., Yela, J. L."))] <- "A. Vives, J.L. Yela"
newdat$Determined.by[which(newdat$Determined.by %in% c("Vila de Paz"))] <- "Vila de la Paz"
newdat$Determined.by[which(newdat$Determined.by %in% c("Martorell y Peña"))] <- "Martorell, Peña"
newdat$Determined.by[grepl("Esp. Inst. Esp. Ent.", newdat$Determined.by, ignore.case=FALSE)] <- "Expedición del Instituto Español de Entomología"
#Seems ok 

#Last column to edit Reference.doi
#There are few errors here too
levels(factor(newdat$Reference.doi))
newdat$Reference.doi[which(newdat$Reference.doi %in% c(""))] <- NA
#I have open this paper already, check for duplicate data?
newdat$Reference.doi[which(newdat$Reference.doi %in% c("10.1111/jeb.12609"))] <- "https://doi.org/10.1111/jeb.12609"
newdat$Reference.doi[grepl("10.14201/gredos", newdat$Reference.doi,ignore.case=F)] <- "https://doi.org/10.14201/gredos.135710"
newdat$Reference.doi[which(newdat$Reference.doi %in% c("10.2307/2260469"))] <- "https://doi.org/10.2307/2260469"
newdat$Reference.doi[grepl("10.3989/graellsia.2009", newdat$Reference.doi,ignore.case=F)] <- "https://doi.org/10.3989/graellsia.2009.v65.i2.145"
newdat$Reference.doi[grepl("https://doi.org/10.11646/", newdat$Reference.doi,ignore.case=F)] <- "https://doi.org/10.11646/zootaxa.4237.1.3"
newdat$Reference.doi[grepl("ISSN: 1134-61", newdat$Reference.doi,ignore.case=F)] <- "ISSN: 1134-6108"
#All dois work now

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

write.table(x = newdat, file = 'Data/Processed_raw_data/47_Collado_etal.csv', 
            quote = TRUE, sep = ',', col.names = TRUE,
            row.names = FALSE)

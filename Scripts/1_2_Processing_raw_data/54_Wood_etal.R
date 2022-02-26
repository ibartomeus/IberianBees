source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 54_Wood_etal  ----

#Read data
newdat <- read.csv(file = "Data/Rawdata/csvs/54_Wood_etal.csv", sep = ";")

#Check cols
colnames(newdat)
summary(newdat)
unique(newdat$Species)
newdat$Genus <- NA
newdat$Subgenus <- NA
newdat$Subspecies <- NA
newdat$Species <- as.character(newdat$Species)
temp <- unlist(gregexpr(pattern = " (", fixed = TRUE, text = newdat$Species))
temp2 <- unlist(gregexpr(pattern = ")", fixed = TRUE, text = newdat$Species))
for(i in which(temp > 0)){
  newdat$Subgenus[i] <- substr(newdat$Species[i], start = temp[i]+2, 
                               stop = temp2[i]-1)
  newdat$Species[i] <- paste(substr(newdat$Species[i], start = 1, 
                                    stop = temp[i]-1), 
                             substr(newdat$Species[i], start = temp2[i]+2, 
                                    stop = nchar(newdat$Species[i])))
}
temp <- strsplit(x = as.character(newdat$Species), split = " ")
#this is slow... 
for (i in 1:length(newdat$Species)){
  if(length(temp[[i]]) == 2){
    newdat$Genus[i] <- temp[[i]][1]
    newdat$Species[i] <- temp[[i]][2]
  }
  if(length(temp[[i]]) == 3){
    newdat$Genus[i] <- temp[[i]][1]
    newdat$Species[i] <- temp[[i]][2]
    newdat$Subspecies[i] <- temp[[i]][3]
  }
}
#clean subspecies withh #agg #s.l.
unique(newdat$Subspecies)
newdat$Species[which(newdat$Subspecies == "agg")] <- paste(newdat$Species[which(newdat$Subspecies == "agg")], 
                                                           "_agg", sep = "")


newdat$Subspecies[which(newdat$Subspecies == "agg")] <- NA
newdat$Species[which(newdat$Subspecies == "s.l.")] <- paste(newdat$Species[which(newdat$Subspecies == "s.l.")], 
                                                            "_s.l.", sep = "")
newdat$Species[which(newdat$Subspecies == "s.l.")] <- NA
#Now dates...
colnames(newdat)
levels(newdat$Start.date)[1:1000] #4/5/1983, 
levels(newdat$Start.date)[1001:2000] #4/5/1983, 
levels(newdat$Start.date)[2001:2800] #4/5/1983, + some errors
levels(newdat$Year.uncertainty) #move to notes?
newdat$Notes.and.queries <-newdat$Year.uncertainty 
levels(newdat$End.date.original)[1:1000] 
levels(newdat$End.date.original)[1001:2000] 
levels(newdat$End.date.original)[2001:3000] #Unitil here the End.date column is fixed manually...
levels(newdat$End.date.original)[3001:4000] 
levels(newdat$End.date.original)[4001:5000] 
levels(newdat$End.date.original)[5001:6000] 
levels(newdat$End.date.original)[6001:7000] 
levels(newdat$End.date.original)[7001:7500] 
#Festival: 12/31/1935, 12 - VI - 1970, 12 VIII 1968, 12 Febr. 1965
# 1-vii-1960, 18800614, 
#estrategia, separar los que tengan /, los que tengan letras, 
#los que sean solo numeros, etc...
newdat$End.date.original <- as.character(newdat$End.date.original)
numeric <- grep(pattern = "^[0-9]*$", x = newdat$End.date.original)
for(i in numeric){
  temp_year <- substr(newdat$End.date.original[i], start = 1,stop = 4)
  temp_month <- substr(newdat$End.date.original[i], start = 5,stop = 6)
  temp_day <- substr(newdat$End.date.original[i], start = 7,stop = 8)
  newdat$End.date.original[i] <- paste(temp_month, temp_day, temp_year, sep = "/")
}
newdat$End.date.original[numeric] #good, I recovered some...
temp <- as.POSIXlt(as.character(newdat$Start.date), format = "%m/%d/%Y") #extract month and day
newdat$month <- format(temp,"%m")
newdat$day <- format(temp,"%d")
colnames(newdat)
newdat$Authors.to.give.credit <- "Compiled by T. Wood"
#missing
#unique(newdat$Year.uncertainty) #few, maybe add to notes DONE
#unique(newdat$Source)  #Notes?
newdat$Notes.and.queries <- ifelse(is.na(newdat$Notes.and.queries), 
                                   newdat$Source, 
                                   paste(newdat$Notes.and.queries, newdat$Source, sep = "; "))
#unique(newdat$TRUSTED) #empty                                        
#unique(newdat$Link) #few, notes? 
newdat$Notes.and.queries <- ifelse(is.na(newdat$Notes.and.queries), 
                                   newdat$Link, 
                                   paste(newdat$Notes.and.queries, newdat$Link, sep = "; "))
unique(newdat$Identification.notes.and.queries)
newdat$Notes.and.queries <- ifelse(is.na(newdat$Notes.and.queries), 
                                   newdat$Identification.notes.and.queries, 
                                   paste(newdat$Notes.and.queries, newdat$Identification.notes.and.queries, sep = "; "))

newdat$uid <- NA

#unique(newdat$MONS) #ignore                                          
#unique(newdat$Authors) #empty
#unique(newdat$Pollen.collected) #cool, ignore for us.                               
#unique(newdat$Prey.host) #few
str(newdat)
newdat <- newdat[,c("Genus",
                    "Subgenus",
                    "Species",
                    "Subspecies",
                    "Country",
                    "Province",
                    "Locality",
                    "Latitude",
                    "Longitude",
                    "Coordinate.precision",
                    "Year",
                    "month",
                    "day",
                    "Start.date",
                    "End.date.original",
                    "Collector",
                    "Determiner",
                    "Female",
                    "Male",
                    "Worker",
                    "Not.specified",
                    "refbib", #?data_source
                    "Flowers.visited",
                    "Code",                 
                    "Authors.to.give.credit",
                    "Any.other.additional.data",
                    "Notes.and.queries",
                    "uid")]

#quick way to compare colnames
cbind(colnames(newdat), colnames(data)) #can be merged
#trouble
unique(newdat$Locality)

#Keep working from here

#newdat$Locality[12]
#gsub("[^[:alnum:]]", "_", newdat$Locality[12])
#newdat$Locality <- as.character(newdat$Locality)
#newdat$Locality <- gsub("[^[:alnum:]]", "", newdat$Locality)

#Compare vars
compare_variables(check, newdat)

#Delete empty genus
newdat <- newdat[!is.na(newdat$Genus),]


#Rename some columns
colnames(newdat)[which(colnames(newdat)=="month")] <- "Month"
colnames(newdat)[which(colnames(newdat)=="day")] <- "Day"
colnames(newdat)[which(colnames(newdat)=="End.date.original")] <- "End.date"
colnames(newdat)[which(colnames(newdat)=="Determiner")] <- "Determined.by"
colnames(newdat)[which(colnames(newdat)=="refbib")] <- "Reference.doi"
colnames(newdat)[which(colnames(newdat)=="Code")] <- "Local_ID"

#Delete leading and trailing spaces on genus and species cols
newdat$Genus <- trimws(newdat$Genus)
newdat$Species <- trimws(newdat$Species)
#Delete genus with just on (lotus cornicolatus)
newdat <- newdat %>% filter(Genus!="on")
#Some species levels has _agg, I gsub this for nothing 
newdat$Species <- gsub("_agg", "", newdat$Species)
#They seem ok now

#Check levels
levels(factor(newdat$Country))
#Rename countries
newdat$Country <- gsub("SPAIN", "Spain", newdat$Country)
newdat$Country[which(newdat$Country %in% c(""))] <- NA

#Rename provinces
newdat$Province[which(newdat$Province %in% c(""))] <- NA
newdat$Province[newdat$Province=="(Alic.)"] <- "Alicante"
newdat$Province[newdat$Province=="(Alic)"] <- "Alicante"
newdat$Province[newdat$Province=="(Ciudad-Real)"] <- "Ciudad Real"
newdat$Province[newdat$Province=="(Gran)"] <- "Granada"
newdat$Province[newdat$Province=="(Gren)"] <- "Granada"
newdat$Province[newdat$Province=="(Jaen)"] <- "Jaén"
newdat$Province[newdat$Province=="(Leon)"] <- "León"
newdat$Province[newdat$Province=="(N.)"] <- "Navarra"
newdat$Province[newdat$Province=="(Navarra)"] <- "Navarra"
newdat$Province[newdat$Province=="(SraDE GREDOS)"] <- "Ávila"
newdat$Province[newdat$Province=="(Viscaya)"] <- "Vizcaya"
newdat$Province[newdat$Province=="(Zaragosa)"] <- "Zaragoza"
newdat$Province[newdat$Province=="Alava"] <- "Álava"
newdat$Province[newdat$Province=="Ã\u0081lava"] <- "Álava"
newdat$Province[newdat$Province=="Algarva"] <- "Algarve"
newdat$Province[newdat$Province=="Algeciras, achterland van"] <- "Algeciras"
newdat$Province[newdat$Province=="Algeciras, province"] <- "Algeciras"
newdat$Province[newdat$Province=="Almeria"] <- "Almería"
newdat$Province[newdat$Province=="Andalucia"] <- "Andalucía"
newdat$Province[newdat$Province=="Andalusia"] <- "Andalucía"
newdat$Province[newdat$Province=="AragÃ³n, Huesca"] <- "Huesca"
newdat$Province[newdat$Province=="Aragon, Huesca"] <- "Huesca"
newdat$Province[newdat$Province=="Aragon, Teruel"] <- "Huesca"
newdat$Province[newdat$Province=="AZORÃ\u0089S Santa Maria"] <- "Isla Santa María (Azores)"
newdat$Province[newdat$Province=="Azoren, SÃ£o Miguel"] <- "Isla Sao Miguel (Azores)"
newdat$Province[newdat$Province=="Baleares, Menorca"] <- "Islas Baleares"
newdat$Province[newdat$Province=="Balearic Islands"] <- "Islas Baleares"
newdat$Province[newdat$Province=="Basses PyrÃ©nÃ©es"] <- "Huesca"
newdat$Province[newdat$Province=="Biscay"] <- "Vizcaya"
newdat$Province[newdat$Province=="Biskaje"] <- "Vizcaya"
newdat$Province[newdat$Province=="Burgos, Central Spain"] <- "Burgos"
newdat$Province[newdat$Province=="CÃ¡ceres"] <- "Cáceres"
newdat$Province[newdat$Province=="CÃ¡diz"] <- "Cádiz"
newdat$Province[newdat$Province=="Caceres"] <- "Cáceres"
newdat$Province[newdat$Province=="CadÃ­s"] <- "Cádiz"
newdat$Province[newdat$Province=="Cadia"] <- "Cádiz"
newdat$Province[newdat$Province=="Cadis"] <- "Cádiz"
newdat$Province[newdat$Province=="Cadiz"] <- "Cádiz"
newdat$Province[newdat$Province=="Canary Islands"] <- "Islas Canarias"
newdat$Province[newdat$Province=="capana.LeÃ³n"] <- "Zamora"
newdat$Province[newdat$Province=="Castile-la-Mancha"] <- "Castilla-La Mancha"
newdat$Province[newdat$Province=="CastiliÃ«-La Mancha"] <- "Castilla-La Mancha"
newdat$Province[newdat$Province=="Castilien"] <- "Cuenca"
newdat$Province[newdat$Province=="Castilla i LeÃ³n"] <- "Castilla y León"
newdat$Province[newdat$Province=="Castilla i Leon"] <- "Castilla y León"
newdat$Province[newdat$Province=="Castilla la Mancha"] <- "Castilla-La Mancha"
newdat$Province[newdat$Province=="Castilla-Leon"] <- "Castilla y León"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Prades"] <- "Tarragona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="10 km N of Lerida (Lleida)"] <- "Lérida"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="10 km E of Lerida (Lleida)"] <- "Lérida"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Lerida"] <- "Lérida"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Canet de mar"] <- "Barcelona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Martinet, 20 km SE of Andorra, Pyrenees (East)"] <- "Lérida"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Martinet20kmSEofAndorraPyreneesEast"] <- "Lérida"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Cerbi, 36 km NW of Andorra Esterri, 1600-2000 m"] <- "Lérida"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="18 km SW of Tortosa, Puertos de Beseit (Ports de Tortosa-Beseit)"] <- "Tarragona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Parc Natural del Garraf"] <- "Barcelona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Mont-roig del Camp, 8 km W of Cambrils"] <- "Tarragona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Barcelona"] <- "Barcelona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Pineda de Mar"] <- "Barcelona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="S. Pere de Vilamajor"] <- "Barcelona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Gerona"] <- "Gerona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Malgrat de Mar"] <- "Barcelona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Monserrat"] <- "Barcelona"
newdat$Province[newdat$Province=="Catalonia" & newdat$Locality=="Anglesola"] <- "Lérida"
newdat$Province[newdat$Province=="Catalonia, Barcelona" & newdat$Locality=="Monserrat"] <- "Barcelona"
newdat$Province[newdat$Province=="Catalonia, Barcelona" & newdat$Locality=="Monte Serrato"] <- "Barcelona"
newdat$Province[newdat$Province=="Catalonia, Barcelona" & newdat$Locality=="Montserrat"] <- "Barcelona"
newdat$Province[newdat$Locality=="Catalonia, Palamos"] <- "Gerona"
newdat$Province[newdat$Locality=="Catalonia, 40 km N Tortosa, riv. Ebre"] <- "Tarragona"
newdat$Province[newdat$Locality=="Catalonia, Lleida env."] <- "Lérida"
newdat$Province[newdat$Locality=="Catalonia - 8 km W of Cambrils, Mont-Roig del Camp"] <- "Tarragona"
newdat$Province[newdat$Province=="CataluÃ±a, Sierra del Cadi"] <- "Lérida"
newdat$Province[newdat$Province=="Cataluna"] <- "Gerona"
newdat$Province[newdat$Province=="Catalunia"] <- "Barcelona"
newdat$Province[newdat$Province=="Catalunia, Barcelona"] <- "Barcelona"
newdat$Province[newdat$Province=="Centr., Castile-La Mancha"] <- "Castilla-La Mancha"
newdat$Province[newdat$Province=="Centr., Cuenca"] <- "Cuenca"
newdat$Province[newdat$Province=="Centr., Montes Universales"] <- "Teruel"
newdat$Province[newdat$Province=="Centr., Seg."] <- "Segovia"
newdat$Province[newdat$Province=="Central Spain [Aragon]"] <- "Aragón"
newdat$Province[newdat$Province=="Central Spain [Cuenca]"] <- "Cuenca"
newdat$Province[newdat$Province=="Central Spain, Burgos"] <- "Burgos"
newdat$Province[newdat$Province=="Central Spain, Madrid"] <- "Madrid"
newdat$Province[newdat$Province=="Central Spain, Soria"] <- "Soria"
newdat$Province[newdat$Province=="Central Spain, Toledo"] <- "Toledo"
newdat$Province[newdat$Province=="Central-Spain, Toledo"] <- "Toledo"
newdat$Country[newdat$Province=="charente maritime"] <- "France"
newdat$Province[newdat$Province=="charente maritime"] <- "Charente maritime"
newdat$Province[newdat$Province=="Coruna"] <- "La Coruña"
newdat$Province[newdat$Province=="Cuenca, Castilien"] <- "Cuenca"
newdat$Province[newdat$Province=="E. Spain, prov. MÃ¡laga"] <- "Málaga"
newdat$Province[newdat$Province=="East Spain" & newdat$Locality=="Altea, 10 km N of Benidorm"] <- "Alicante"
newdat$Province[newdat$Province=="East Spain" & newdat$Locality=="Altea"] <- "Alicante"
newdat$Province[newdat$Province=="East Spain" & newdat$Locality=="Ferrandet, near Calpe"] <- "Alicante"
newdat$Province[newdat$Province=="East Spain, Albacete"] <- "Albacete"
newdat$Province[newdat$Province=="East Spain, Alicante"] <- "Alicante"
newdat$Province[newdat$Province=="East Spain, Tarragona"] <- "Tarragona"
newdat$Province[newdat$Province=="Extramadura" & newdat$Locality=="HervÃ¡s"] <- "Cáceres"
newdat$Province[newdat$Province=="Extramadura" & newdat$Locality=="HervÃ¡s"] <- "Cáceres"
newdat$Province[newdat$Province=="Fuertaventura"] <- "Islas Canarias"
newdat$Province[newdat$Province=="Fuertaventura, Canarias"] <- "Islas Canarias"
newdat$Province[newdat$Province=="Fuerteventura"] <- "Islas Canarias"
newdat$Province[newdat$Province=="Fuerto-ventura"] <- "Islas Canarias"
newdat$Province[newdat$Province=="G. v. Biscaje"] <- "Guipúzcoa"
newdat$Province[newdat$Province=="Galicia, Pontevedra"] <- "Pontevedra"
newdat$Province[newdat$Province=="Gipuzkoa"] <- "Guipúzcoa"
newdat$Province[newdat$Province=="Gran Canaria"] <- "Islas Canarias"
newdat$Province[newdat$Province=="Granada, Sierra Nevada"] <- "Granada"
newdat$Province[newdat$Province=="Avila"] <- "Ávila"
newdat$Province[newdat$Province=="Al."] <- "Alicante"
newdat$Province[newdat$Province=="Aragon"] <- "Aragón"
newdat$Province[newdat$Province=="Aragon, Centr."] <- "Aragón"
newdat$Province[newdat$Province=="Aragon, Hispania Centr."] <- "Aragón"
newdat$Province[newdat$Province=="Centr." & newdat$Locality=="Tragacete"] <- "Cuenca"
newdat$Province[newdat$Province=="GiupÃºzcoa"] <- "Guipúzcoa"
newdat$Province[newdat$Province=="GuipÃºzcoa"] <- "Guipúzcoa"
newdat$Province[newdat$Province=="GuipÃºzcoa / Basque Country"] <- "Guipúzcoa"
newdat$Province[newdat$Province=="Guipuzcoa"] <- "Guipúzcoa"
newdat$Province[newdat$Province=="Hisp. centr."] <- "Teruel"
newdat$Province[newdat$Province=="Hisp. centr."] <- "Teruel"
newdat$Province[newdat$Province=="Hispania Centr." & newdat$Locality=="C. Encantada, Cuenca"] <- "Cuenca"
newdat$Province[newdat$Province=="Hispania Centr." & newdat$Locality=="Cercedilla Dehesas"] <- "Madrid"
newdat$Province[newdat$Province=="Hispania Centr." & newdat$Locality=="Tragacete-Huelamos"] <- "Cuenca"
newdat$Province[newdat$Province=="Hispania Centr." & newdat$Locality=="Tragacete-Huelamo"] <- "Cuenca"
newdat$Province[newdat$Province=="Hispania Centr., Cuenca"] <- "Cuenca"
newdat$Province[newdat$Province=="Hispania Centr., Sierra de Albarracin"] <- "Teruel"
newdat$Province[newdat$Province=="Hispania Central" & newdat$Locality=="Tragacete-Huelamo"] <- "Cuenca"
newdat$Province[newdat$Province=="Hispania Central" & newdat$Locality=="Albarracin"] <- "Teruel"
newdat$Province[newdat$Province=="Hispania Central" & newdat$Locality=="Tragacete"] <- "Cuenca"
newdat$Province[newdat$Province=="Hispania Central" & newdat$Locality=="Sierra de Albarracin"] <- "Teruel"
newdat$Province[newdat$Province=="Hispania Central" & newdat$Locality=="Cercedilla Dehesas"] <- "Madrid"
newdat$Province[newdat$Province=="Hispania Central" & newdat$Locality=="Tragacete, Huelamo"] <- "Cuenca"
newdat$Province[newdat$Province=="Hispania Central" & newdat$Locality=="Pto. de Navacerrada"] <- "Madrid"
newdat$Province[newdat$Province=="Hispania Central" & newdat$Locality=="Puerto de Navacerrada"] <- "Madrid"
newdat$Province[newdat$Province=="Guad."] <- "Guadalajara"
newdat$Province[newdat$Province=="Hispania Central, Aragon"] <- "Aragón"
newdat$Province[newdat$Province=="Hispania Central, Cuenca"] <- "Cuenca"
newdat$Province[newdat$Province=="Hispania Central, Segovia"] <- "Segovia"
newdat$Province[newdat$Province=="Hispania Central, Sierra de Guadarrama"] <- "Madrid"
newdat$Province[newdat$Province=="Hispania Central, Teruel"] <- "Teruel"
newdat$Province[newdat$Province=="IBIZA (Bal.)"] <- "Islas Baleares"
newdat$Province[newdat$Province=="Is. Baleares MALLORCA"] <- "Islas Baleares"
newdat$Province[newdat$Province=="Is.Baleares"] <- "Islas Baleares"
newdat$Province[newdat$Province=="Islas Baleares, Mallorca"] <- "Islas Baleares (Mallorca)"
newdat$Province[newdat$Province=="Islas Canarias, La Palma"] <- "Islas Canarias (La Palma)"
newdat$Province[newdat$Province=="Islas Canarias, Tenerife"] <- "Islas Canarias (Tenerife)"
newdat$Province[newdat$Province=="JaÃ©n"] <- "Jaén"
newdat$Province[newdat$Province=="Jaen"] <- "Jaén"
newdat$Province[newdat$Province=="La Coruna"] <- "Jaén"
newdat$Province[newdat$Province=="La Palma"] <- "Islas Canarias (La Palma)"
newdat$Province[newdat$Province=="LeÃ³n"] <- "León"
newdat$Province[newdat$Province=="LeÃ³n, Montes de LeÃ³n"] <- "León"
newdat$Province[newdat$Province=="Leon"] <- "León"
newdat$Province[newdat$Province=="Lerida"] <- "Lérida"
newdat$Province[newdat$Province=="LlanÃ§Ã "] <- "Gerona"
newdat$Province[newdat$Province=="MÃ¡laga"] <- "Málaga"
newdat$Province[newdat$Province=="Malaga"] <- "Málaga"
newdat$Province[newdat$Province=="Mallorca"] <- "Islas Baleares (Mallorca)"
newdat$Province[newdat$Province=="Mallorca, East"] <- "Islas Baleares (Mallorca)"
newdat$Province[newdat$Province=="Merida"] <- "Mérida"
newdat$Province[newdat$Province=="Minorca"] <- "Islas Baleares (Menorca)"
newdat$Province[newdat$Province=="Montes de LÃ©on"] <- "Montes de León"
newdat$Province[newdat$Province=="Murcia, province"] <- "Murcia"
newdat$Province[newdat$Province=="N. Spain"] <- "Navarra"
newdat$Province[newdat$Province=="Nav."] <- "Navarra"
newdat$Province[newdat$Province=="Navarra, South Spain"] <- "Navarra"
newdat$Province[newdat$Province=="near MÃ laga"] <- "Málaga"
newdat$Province[newdat$Province=="Nordost"] <- "Barcelona"
newdat$Province[newdat$Province=="North Spain, prov. Burgos"] <- "Burgos"
newdat$Province[newdat$Province=="North Spain, prov. Navarra"] <- "Navarra"
newdat$Province[newdat$Province=="North West Spain" & newdat$Locality=="Viscaya, kust bij Somorrostro (tussen Bilbao en Castro Urdiales)"] <- "Vizcaya"
newdat$Province[newdat$Province=="North West Spain" & newdat$Locality=="Villajuan, S.W. of Villagarcia (Pontevedra)"] <- "Pontevedra"
newdat$Province[newdat$Province=="North West Spain, Coruna"] <- "La Coruña"
newdat$Province[newdat$Province=="North-East Spain" & newdat$Locality=="La Garriga"] <- "Barcelona"
newdat$Province[newdat$Province=="North-East Spain" & newdat$Locality=="Collsacabra"] <- "Barcelona"
newdat$Province[newdat$Province=="North-West Spain" & newdat$Locality=="Caldas de Reyes"] <- "Pontevedra"
newdat$Province[newdat$Province=="North-West Spain" & newdat$Locality=="Boiro, 3 km South-East of"] <- "La Coruña"
newdat$Province[newdat$Province=="North-West Spain" & newdat$Locality=="Boiro, 2 km. S.E. of"] <- "La Coruña"
newdat$Province[newdat$Province=="North-West Spain" & newdat$Locality=="Callas de Reyes"] <- "Pontevedra"
newdat$Province[newdat$Province=="North-West Spain, Pontevedra"] <- "Pontevedra"
newdat$Province[newdat$Province=="prov. Almeria"] <- "Almería"
newdat$Province[newdat$Province=="prov. Murcia"] <- "Murcia"
newdat$Province[newdat$Province=="prov. Navarra"] <- "Navarra"
newdat$Province[newdat$Province=="Provence"] <- "Barcelona"
newdat$Province[newdat$Province=="Province Burgos"] <- "Burgos"
newdat$Province[newdat$Province=="Province Murcia"] <- "Murcia"
newdat$Province[newdat$Province=="PyrÃ©nÃ©es Espagnol" & newdat$Locality=="Panticosa"] <- "Huesca"
newdat$Province[newdat$Province=="PyreneeÃ«n" & newdat$Locality=="Salau"] <- "Tarragona"
newdat$Province[newdat$Province=="PyreneeÃ«n" & newdat$Locality=="Alos de Isile"] <- "Lérida"
newdat$Province[newdat$Province=="PyreneeÃ«n, noordhelling" & newdat$Locality=="Col du Somport"] <- "Huesca"
newdat$Province[newdat$Province=="PyreneeÃ«n, noordhelling" & newdat$Locality=="Col de Somport Noord Helling PyreneeÃ«n"] <- "Huesca"
newdat$Province[newdat$Province=="PyreneeÃ«n, noordhelling"] <- "Ávila"
newdat$Province[newdat$Province=="S. E. Spain, prov. Murcia"] <- "Murcia"
newdat$Province[newdat$Province=="Sierra"] <- "Jaén"
newdat$Province[newdat$Province=="Sierra de Gredos"] <- "Ávila"
newdat$Province[newdat$Province=="Sierra de Guadarama"] <- "Madrid"
newdat$Province[newdat$Province=="Sierra de Guadarrama"] <- "Madrid"
newdat$Province[newdat$Province=="Sierra Nevada"] <- "Granada"
newdat$Province[newdat$Province=="Sierra Nevada, Granada"] <- "Granada"
newdat$Province[newdat$Province=="South Spain, Alicante"] <- "Alicante"
newdat$Province[newdat$Province=="South Spain, Cadiz"] <- "Cádiz"
newdat$Province[newdat$Province=="South Spain, MÃ¡laga"] <- "Málaga"
newdat$Province[newdat$Province=="South Spain, Navarra"] <- "Navarra"
newdat$Province[newdat$Province=="South Spain, prov. MÃ¡laga"] <- "Málaga"
newdat$Province[newdat$Province=="South-East Spain, dept. MÃ laga"] <- "Málaga"
newdat$Province[newdat$Province=="South-Spain, Malaga near"] <- "Málaga"
newdat$Province[newdat$Province=="South-West Spain, prov. Cadiz"] <- "Cádiz"
newdat$Province[newdat$Province=="South-West Spain, prov. Sevilla"] <- "Sevilla"
newdat$Province[newdat$Province=="Southeast Spain, MÃ£laga"] <- "Málaga"
newdat$Province[newdat$Province=="Southern Spain, Alicante"] <- "Alicante"
newdat$Province[newdat$Province=="Southern Spain, Granada"] <- "Granada"
newdat$Province[newdat$Province=="Southern Spain, Malaga, Sierra Bermeja"] <- "Málaga"
newdat$Province[newdat$Province=="Southern Spain, prov. CadÃ­z"] <- "Cádiz"
newdat$Province[newdat$Province=="Southern Spain, Teruel"] <- "Teruel"
newdat$Province[newdat$Province=="Spanische Pyrenaeen"] <- "Gerona"
newdat$Province[newdat$Province=="near MÃ laga"] <- "Málaga"
newdat$Province[newdat$Province=="S. de Gredos"] <- "Ávila"
newdat$Province[newdat$Province=="South-East Spain, dept. MÃ laga"] <- "Málaga"
newdat$Province[newdat$Province=="Tarrazona"] <- "Tarragona"
newdat$Province[newdat$Province=="Ternel"] <- "Teruel"
newdat$Province[newdat$Province=="Teruel, Hautes PyrÃ©nÃ©Ã©s"] <- "Teruel"
newdat$Province[newdat$Province=="Val de Ordesa"] <- "Huesca"
newdat$Province[newdat$Province=="Valentia"] <- "Valencia"
newdat$Province[newdat$Province=="Vizcaya, northwestern part of Spain"] <- "Vizcaya"
newdat$Province[newdat$Province=="West Mallorca"] <- "Islas Baleares (Mallorca)"
newdat$Province[newdat$Province=="West Spain, Badajoz"] <- "Badajoz"
newdat$Province[newdat$Province=="West Spain, prov. Caseres"] <- "Cáceres"
newdat$Province[newdat$Province=="West-Spain, prov. Caceres"] <- "Cáceres"
newdat$Province[newdat$Province=="Za"] <- "Zaragoza"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Gerez"] <- "Cádiz"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Villaricios"] <- "Almería"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Ronda"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Granada, Sierra de Almijara, 19 km N of Almunecar, 945 m"] <- "Granada"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Benidorm"] <- "Alicante"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Estepona"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Granada, Pantano de Cubillas"] <- "Granada"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Torremolinos (nr Malaga)"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="50 km N of Granada"] <- "Granada"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="AlmuÃ±Ã©car, Granada"] <- "Granada"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Almeria, Mojacar"] <- "Almería"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Alicante, Denia"] <- "Alicante"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Cadiz, Castellar de la Frontera"] <- "Cádiz"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, Arriate"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, 5 km S Ronda"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, Benalmadena"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, 5 km E Alhaurin el Grande"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, Torre del Mar"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, Rincon de la Victoria"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, San Julian"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, El Chorro"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, San Julian, 8 km SW of Malaga"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, Velez Malaga"] <- "Málaga"
newdat$Province[newdat$Province=="Andalucía" & newdat$Locality=="Malaga, Torre del Mar"] <- "Málaga"
newdat$Province[newdat$Province=="Vieja"] <- "Soria"
newdat$Province[newdat$Province=="South-East Spain, dept. MÃ laga"] <- "Málaga"
newdat$Province[newdat$Locality=="(Huesca) Toria, 1000 m."] <- "Huesca"
newdat$Province[grepl("Jaramiel", newdat$Locality)] <- "Palencia"
newdat$Province[grepl("Villanueva de Valdueza", newdat$Locality)] <- "León"
newdat$Province[grepl("Cuenca", newdat$Locality)] <- "Cuenca"
newdat$Province[grepl("Huelamo", newdat$Locality)] <- "Cuenca"
newdat$Locality[grepl("Goria", newdat$Locality)] <- "Coria"
newdat$Province[grepl("Coria", newdat$Locality)] <- "Cáceres"
newdat$Province[grepl("Vigo", newdat$Locality)] <- "Pontevedra"
newdat$Province[grepl("Padrones", newdat$Locality)] <- "Pontevedra"
newdat$Province[grepl("Galicia", newdat$Province)] <- NA
newdat$Province[grepl("San Pedro de Alcantara", newdat$Locality)] <- "Málaga"
newdat$Province[grepl("Moncayo", newdat$Locality)] <- NA
newdat$Province[grepl("Andalucía", newdat$Province)] <- NA
newdat$Province[grepl("Helechar", newdat$Province)] <- "Badajoz"

#Organize Portugal by districts (equivalent of provinces in Spain?)
#This is going to take ages and portugal is small, maybe something to do in the future
#I tried a bit...
#newdat$Province[newdat$Province=="(Minles-Portugal)"] <- "Porto"
#newdat$Province[newdat$Province=="Algarve"] <- "Faro"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Estremoz"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Elvas"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Évora"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Mitra, Évora"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Castelo de Vide"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Castelo de Vide"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Almendras"] <- "Guarda"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Ribeira de Valverde"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Almendres"] <- "Guarda"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Álamo"] <- "Guarda"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Castelo do Vide"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Vila Nova de São Bento"] <- "Beja"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Évora, Ribeira de Valverde "] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Montemor-o-novo"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Almandres"] <- "Guarda"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Serra Monfurado"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Serra do Monfurado"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Vila Visçosa"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Vila Visçosa"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Alandroal"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="BORBA"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Marvão, Castelo"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Portalegre"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Reguengo, Portalegre"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Montargil, Portalegre"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Montargil, Ponte de Sor, Portalegre"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Flor de Rosa"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Ponte de Sor"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Montemor-o-Novo"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Foros de Vale de Figueria, Montemor-o-novo"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Portalegre, Vaiamonte"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Vaiamonte, near Portalegre"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Vaiamonte"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Foros de Mora, Mora, Évora"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Évora, Mora"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Coruche, Couço"] <- "Santarém"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Mora, near Évora"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Albufeira de Montagil"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Barragem de Montargil, Portalegre"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Portalegre, Ribeira de Nisa"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Marvão, Santo Maria de Marvão, Portalegre"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Mértola, Alcaria river, Beja"] <- "Beja"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Mora, Cabecao, Gameiro"] <- "Beja"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Barrancos"] <- "Beja"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Mora, Cabeção"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Mora, Cabeção, Gameiro"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Montemor-o-Novo, Foros de Vale de Figeira"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Montemor-o-Novo,Foros de Vale da Figueira M2"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Montemor-o-Novo,Foros de Vale da Figueira A1"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Montemor-o-Novo,Foros de Vale da Figueira M1"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Montemor-o-Novo,Foros de Vale da Figueira M2 "] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Montemor-o-Novo,Foros de Vale da Figueira A1 "] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Montemor-o-Novo,Foros de Vale da Figueira dam "] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Montemor-o-Novo,Foros de Vale da Figueira "] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Evora, Montemor-o-Novo,Foros de Vale da Figueira A2"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Portalegre, PN Serra São Mamede"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Portalegre, PN Serra São Mamede, Barretos"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Portalegre, PN Serra São Mamede, Castelo de Vide"] <- "Portalegre"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Cerros, near to Restaurante Herdade do Esporão"] <- "Évora"
#newdat$Province[newdat$Province=="Alto Alentejo" & newdat$Locality=="Foros de Vale Figueira, Montemor-o-Novo"] <- "Évora"

#They look better now but still more work can be done here
levels(factor(newdat$Province))

#Check localities
levels(factor(newdat$Locality))
#Do a bit of cleaning (not something crazy)
newdat$Locality[newdat$Locality==" "] <- NA
newdat$Locality[newdat$Locality==""] <- NA
newdat$Locality[newdat$Locality=="@"] <- NA
newdat$Locality[newdat$Locality=="@@"] <- NA
newdat$Locality <- gsub("\\- Andalucia, ", "", newdat$Locality)
newdat$Locality[newdat$Locality=="#NAME?"] <- NA
newdat$Locality[newdat$Locality=="#NOM?"] <- NA

#This is going to be 4ever too so lets make string to title
#And check if its not too bad
newdat$Locality <- stringr::str_to_title(newdat$Locality)
newdat$Locality <- gsub("\\ De", " de", newdat$Locality)
newdat$Locality <- gsub("\\ Do", " do", newdat$Locality)
newdat$Locality <- gsub("\\ Of", " of", newdat$Locality)
newdat$Locality <- gsub("\\ El", " el", newdat$Locality)
newdat$Locality <- gsub("\\ La", " la", newdat$Locality)
newdat$Locality <- gsub("\\ Los", " los", newdat$Locality)

#Delete leading and trailing spaces
newdat$Locality <- trimws(newdat$Locality, "l")
newdat$Locality <- trimws(newdat$Locality, "r")


#Fix big mistakes
#Generally all related with accents and special characters
newdat$Locality[newdat$Locality=="Barcelona, Provincia de"] <- NA
newdat$Locality[newdat$Locality=="Córdoba, Provincia de"] <- NA
newdat$Locality[newdat$Locality=="- 23 Km S Cadiz,Chiclana de la Frontera"] <- "23 km S Cádiz, Chiclana de la Frontera"
newdat$Locality[newdat$Locality=="- 25 Km Sww Sevilla, Aznalcazar"] <- "25 km SW Sevilla, Aznalcazar"
newdat$Locality[newdat$Locality=="- 26 Km Sww Sevilla, Aznalcazar"] <- "26 km SW Sevilla, Aznalcazar"
newdat$Locality[newdat$Locality=="- 27 Km Sww Sevilla, Aznalcazar"] <- "27 km SW Sevilla, Aznalcazar"
newdat$Locality[newdat$Locality=="- 23 Km S Cadiz, Chiclana"] <- "23 km S Cadiz, Chiclana"
newdat$Locality[newdat$Locality=="- 28 Km Sww Sevilla, Aznalcazar"] <- "28 km SW Sevilla, Aznalcazar"
newdat$Locality[newdat$Locality=="- 65 Km Sw Sevilla, W Matalascanas"] <- "65 km SW Sevilla, W Matalascanas"
newdat$Locality[newdat$Locality=="(Madrid) Bij Camping Osuna Bij Madrid"] <- "Camping Osuna (Madrid)"
newdat$Locality[newdat$Locality=="20km Sw.murcie"] <- "20 km SW Murcia"
newdat$Locality[newdat$Locality=="20km W.montforte de Lemos"] <- "20 km W Montforte de Lemos"
newdat$Locality[newdat$Locality=="25 Km Sww Sevilla, Aznalcazar, E-Sev "] <- "25 km SW Sevilla, Aznalcazar"
newdat$Locality[newdat$Locality=="25 Km Sww Sevilla, Aznalcazar"] <- "25 km SW Sevilla, Aznalcazar"
newdat$Locality[newdat$Locality=="25km Sw.cartagena"] <- "25km SW Cartagena"
newdat$Locality[newdat$Locality=="10 Km Se Baza"] <- "10 km SE Baza"
newdat$Locality[newdat$Locality=="10 Km. W, Van Jaca"] <- "10 km W Van Jaca"
newdat$Locality[newdat$Locality=="10km N.albacete"] <- "10 km N Albacete"
newdat$Locality[newdat$Locality=="10km No.calatayud"] <- "10 km NO Calatayud"
newdat$Locality[newdat$Locality=="10km W.navalcan"] <- "10 km W Navalcan"
newdat$Locality[newdat$Locality=="15 Km.n.w. Van Tarifa"] <- "15 km NW Tarifa"
newdat$Locality[newdat$Locality=="15km E.marbella"] <- "15 km E Marbella"
newdat$Locality[newdat$Locality=="20km Sw.murcia"] <- "20 km SW Murcia"
newdat$Locality[newdat$Locality=="20km Sw.murcia"] <- "20 km SW Murcia"
newdat$Locality[newdat$Locality=="20km Sw.murcia"] <- "20 km SW Murcia"
newdat$Locality[newdat$Locality=="20km Sw.murcia"] <- "20 km SW Murcia"
newdat$Locality[newdat$Locality=="15km N.coimbra"] <- "15 km N Coimbra"
newdat$Locality[newdat$Locality=="3 Km Ne Quarteira, N 37º04'23\" W 08º04'05\""] <- "3 km NE Quarteira"
newdat$Locality[newdat$Locality=="3 Km Nw Monchique"] <- "3 km NW Monchique"
newdat$Locality[newdat$Locality=="30km E.cartagena"] <- "30 km E Cartagena"
newdat$Locality[newdat$Locality=="30km E.carthagena"] <- "30 km E Cartagena"
newdat$Locality[newdat$Locality=="30km Sw.almeria"] <- "30km SW Almería"
newdat$Locality[newdat$Locality=="30 Km Sw Almeria"] <- "30km SW Almería"
newdat$Locality[newdat$Locality=="5km Sw.ronda"] <- "5 km SW Ronda"
newdat$Locality[newdat$Locality=="8km Zw.malaga"] <- "8 km SW Málaga"
newdat$Locality[newdat$Locality=="10 Km W. Van Jaca"] <- "10 km W Van Jaca"
newdat$Locality[newdat$Locality=="20 Km Ne Ronda"] <- "20 Km NE Ronda"
newdat$Locality[newdat$Locality=="25 Km Sw Cartagena"] <- "25 km SW Cartagena"
newdat$Locality[newdat$Locality=="2km E.póvoa de Varzim"] <- "2 km E Póvoa de Varzim"
newdat$Locality[newdat$Locality=="35km Ne.plasencia"] <- "35 km NE Plasencia"
newdat$Locality[newdat$Locality=="Albufeira, Hapimag, N 37º04'33\" W 08º17'37\""] <- "Albufeira, Hapimag"
newdat$Locality[newdat$Locality=="Albufeira, Torre Velhas, N 37º04'38\" W 08º17'55\""] <- "Albufeira, Torre Velhas"
newdat$Locality[newdat$Locality=="Alcuzcuz, North of San Pedro de Alcã£Ntara"] <- "Alcuzcuz, North of San Pedro de Alcántara"
newdat$Locality[newdat$Locality=="Almuã±Ã©Car"] <- "Almuñécar"
newdat$Locality[newdat$Locality=="Almuã±Ã©Car, Beach"] <- "Almuñécar"
newdat$Locality[newdat$Locality=="Almuã±Ã©Car, Granada"] <- "Almuñécar"
newdat$Locality[newdat$Locality=="AlmunãCar"] <- "Almuñécar"
newdat$Locality[newdat$Locality=="Almunecar"] <- "Almuñécar"
newdat$Locality[newdat$Locality=="Brito, N 37º12'18\" W 08º12'16\""] <- "Brito"
newdat$Locality[newdat$Locality=="Brito, N 37º13'59\" W 08º09'50\""] <- "Brito"
newdat$Locality[newdat$Locality=="C´?¢Diz"] <- "Cádiz"
newdat$Locality[newdat$Locality=="Coto doñana: See Coto de doñana, Parque Nacional"] <- "Parque Nacional de Doñana"
newdat$Locality[newdat$Locality=="Coto donana"] <- "Parque Nacional de Doñana"
newdat$Locality[newdat$Locality=="Coto doñana"] <- "Parque Nacional de Doñana"
newdat$Locality[newdat$Locality=="Foz do laje, N 37º14'42\" W 08º30'27\""] <- "Foz do laje"
newdat$Locality[newdat$Locality=="Guö?¡A de Isora; Llano de la Santidad (Pn Teide)"] <- "Guía de Isora; Llano de la Santidad (PN del Teide)"
newdat$Locality[newdat$Locality=="Guö?¡A de Isora; Zanjones, los (Pn Teide)"] <- "Guía de Isora; Zanjones (PN del Teide)"
newdat$Locality[newdat$Locality=="Helechar (Bada Joz)"] <- "Helechar (Badajoz)"
newdat$Locality[newdat$Locality=="Helechar, Badajoz"] <- "Helechar (Badajoz)"
newdat$Locality[newdat$Locality=="Hervã¡S"] <- "Hervás"
newdat$Locality[newdat$Locality=="Hervas"] <- "Hervás"
newdat$Locality[newdat$Locality=="Hispania: See Spain, Kingdom of"] <- NA
newdat$Locality[newdat$Locality=="Hostalets de Baleny?Á"] <- "Balenyá"
newdat$Locality[newdat$Locality=="Jbiza (Also As 'Ibiza' Or ' Iviza'), Town of"] <- "Ibiza"
newdat$Locality[newdat$Locality=="Jerez de la Froutera"] <- "Jerez de la Frontera"
newdat$Locality[newdat$Locality=="Jerez: See Jerez de la Frontera"] <- "Jerez de la Frontera"
newdat$Locality[newdat$Locality=="Jimena: See Jimena de la Frontera"] <- "Jerez de la Frontera"
newdat$Locality[newdat$Locality=="La Coruña, Provincia de"] <- "La Coruña"
newdat$Locality[newdat$Locality=="Mazagã³N"] <- "Mazagón"
newdat$Locality[newdat$Locality=="Mazarron"] <- "Mazarrón"
newdat$Locality[newdat$Locality=="Sabinanigo, 42â°32'N-0â°23'W"] <- "Sabiñánigo"
newdat$Locality[newdat$Locality=="Sabinanigo"] <- "Sabiñánigo"
newdat$Province[newdat$Locality=="Sacromonte / Granada"] <- "Granada"
newdat$Locality[newdat$Locality=="Sacromonte / Granada"] <- "Sacromonte"
newdat$Locality[newdat$Locality=="Sallent 42 Â° 45' N- 0 Â° 20' W"] <- "Sallent de Gállego"
newdat$Locality[newdat$Locality=="Sallent de Gã¡Llego"] <- "Sallent de Gállego"
newdat$Locality[newdat$Locality=="Sallent de Gã¡Llego, 42â°45' N-0â°20' W"] <- "Sallent de Gállego"
newdat$Locality[newdat$Locality=="Sallent de Gallego"] <- "Sallent de Gállego"
newdat$Locality[newdat$Locality=="Valley of Ordesa [Ordesa Valley], Pyrenees"] <- "Valle de Ordesa"
newdat$Locality[newdat$Locality=="Velez Mã Lã Ga 7 Km N"] <- "Velez, 7 km N Málaga"
newdat$Locality[newdat$Locality=="Velez Mã¡Laga, 7 Km N."] <- "Velez, 7 km N Málaga"
newdat$Locality[newdat$Locality=="Vï¿½Lez de Benaudalla"] <- "Vélez de Benaudalla"
newdat$Locality[newdat$Locality=="Villabã¡Ã±Ez"] <- "Villabáñez"
newdat$Locality[newdat$Locality=="Villabanez"] <- "Villabáñez"
newdat$Locality[newdat$Locality=="Villab´?¢´?¢Ez"] <- "Villabáñez"
newdat$Locality[newdat$Locality=="?Übeda"] <- "Úbeda"
newdat$Locality[newdat$Locality=="?Sandosa"] <- "Sandosa"
newdat$Locality[newdat$Locality=="?Avoberal"] <- "Avoberal"
newdat$Locality[newdat$Locality=="??Vila Franca"] <- "Vila Franca"
newdat$Locality[newdat$Locality=="40 Km Sse of Zaragoza, Belchite"] <- "40 Km SE of Zaragoza, Belchite"
newdat$Locality[newdat$Locality=="40km N.tortosa"] <- "40km N Tortosa"
newdat$Locality[newdat$Locality=="4km S.betancuria"] <- "4km S Betancuria"
newdat$Locality[newdat$Locality=="5km O.alhaurin el Grande"] <- "5km O Alhaurin el Grande"
newdat$Locality[newdat$Locality=="60 Km Ne of Alicante, Vall de laguar, Fleix"] <- "60 km NE of Alicante, Vall de laguar, Fleix"
newdat$Locality[newdat$Locality=="8km Sw.orgiva"] <- "8 km SW Orgiva"
newdat$Locality[newdat$Locality=="ÃCjia"] <- "Écija"
newdat$Locality[newdat$Locality=="Albergue Universitario; G´?¢Ejar Sierra; Sierra N	2550	19940712	Ortiz, J	Gbif,2015	Ku"] <- "Albergue Universitario de Sierra Nevada - Güejar Sierra"
newdat$Locality[newdat$Locality=="Alarã³"] <- "Alaró"
newdat$Locality[newdat$Locality=="Albarracã­n 1200 M³"] <- "Albarracín"
newdat$Locality[newdat$Locality=="Albarracin"] <- "Albarracín"
newdat$Locality[newdat$Locality=="Albarracin (800m)"] <- "Albarracín"
newdat$Locality[newdat$Locality=="Albarracín, Sierra de"] <- "Albarracín"
newdat$Locality[newdat$Locality=="Albufeira de Montagil"] <- "Albufeira de Montargil"
newdat$Locality[newdat$Locality=="Albufeira de Montargil"] <- "Albufeira de Montargil"
newdat$Locality[newdat$Locality=="Albunol"] <- "Albuñol"
newdat$Locality[newdat$Locality=="Alcala de Henares"] <- "Alcalá de Henares"
newdat$Locality[newdat$Locality=="Alcalá de los Gázules"] <- "Alcalá de los Gazules"
newdat$Province[newdat$Locality=="Alcala: See Alcalá de Chivert"] <- "Castellón"
newdat$Locality[newdat$Locality=="Alcala: See Alcalá de Chivert"] <- "Alcalá de Xivert"
newdat$Locality[newdat$Locality=="7 Km Sw of Toro"] <- "7 km SW of Toro"
newdat$Locality[newdat$Locality=="Ado Pinto???, Near Santarem"] <- "Near Santarem"
newdat$Locality[newdat$Locality=="Aguirre, Barranco del"] <- "Barranco del Aguirre"
newdat$Locality[newdat$Locality=="Alba de los Cardaï¿½Os"] <- "Camino de la Binesa, Velilla del Río Carrión"
newdat$Locality[newdat$Locality=="Albaizin: See el Albaicín"] <- "Albaicín (Granada)"
newdat$Locality[newdat$Locality=="Alhama de Aragã³N"] <- "Alhama de Aragón"
newdat$Locality[newdat$Locality=="Alhama: See Alhama de Granada"] <- "Alhama de Granada"
newdat$Locality[newdat$Locality=="Alhama: See Alhama de Murcia"] <- "Alhama de Murcia"
newdat$Locality[newdat$Locality=="Alhamilla, Sierra de"] <- "Sierra Alhamilla"
newdat$Locality[newdat$Locality=="Alhaurin de la Torre"] <- "Alhaurín de la Torre"
newdat$Province[newdat$Locality=="Alicante, Provincia de"] <- "Alicante"
newdat$Locality[newdat$Locality=="Alicante, Provincia de"] <- NA
newdat$Province[newdat$Locality=="Almería, Provincia de"] <- "Alicante"
newdat$Locality[newdat$Locality=="Almería, Provincia de"] <- NA
newdat$Locality[newdat$Locality=="Andalucía [Spanish]; Andalusia [Conventional]"] <- "Andalucía"
newdat$Locality[newdat$Locality=="Andalusia: See Andalucía"] <- "Andalucía"
newdat$Locality[newdat$Locality=="Arandade Duero"] <- "Aranda de Duero"
newdat$Locality[newdat$Locality=="Arantzazu / 20567 Arantzazu, Gipuzkoa, Spain"] <- "Aránzazu"
newdat$Locality[newdat$Locality=="Arantzazu"] <- "Aránzazu"
newdat$Locality[newdat$Locality=="Arcos de la Frontera, Andalucía Prov."] <- "Arcos de la Frontera"
newdat$Locality[newdat$Locality=="Arenys, Riera de"] <- "Riera de Arenys"
newdat$Locality[newdat$Locality=="Artesa de Serge"] <- "Artesa de Segre"
newdat$Province[newdat$Locality=="Asturias: See Oviedo, Provincia de"] <- "Oviedo"
newdat$Locality[newdat$Locality=="Asturias: See Oviedo, Provincia de"] <- NA
newdat$Locality[newdat$Locality=="3km N.ojén"] <- "3 km N Ojén"
newdat$Locality[newdat$Locality=="ÃGueda"] <- "Águeda"
newdat$Locality[newdat$Locality=="Albac, Alcaraz"] <- "Albacete, Alcaraz"
newdat$Locality[newdat$Locality=="Albace, Alcaraz"] <- "Albacete, Alcaraz"
newdat$Locality[newdat$Locality=="Aldea del Rio Bij Guarramã¡N"] <- "Aldea los Ríos (Guarromán)"
newdat$Locality[newdat$Locality=="Aldea del Rio Bij Guarramã¡N 400 M"] <- "Aldea los Ríos (Guarromán)"
newdat$Locality[newdat$Locality=="Alg?"] <- NA
newdat$Locality[newdat$Locality=="Alg@"] <- NA
newdat$Locality[newdat$Locality=="Amã©Lie Les Bains Montbolo 500-700m"] <- "Amélie les Bains-Montbolo"
newdat$Locality[newdat$Locality=="Ameira (?Aldeia)"] <- "Ameira (Aldeia)"
newdat$Locality[newdat$Locality=="Ba´?¢Os de Benasque"] <- "Baños de Benasque"
newdat$Locality[newdat$Locality=="Baleares"] <- "Islas Baleares"
newdat$Locality[newdat$Locality=="Baléares, Iles: See Baleares, Islas"] <- "Islas Baleares"
newdat$Locality[newdat$Locality=="Baleares, Islas [Spanish]; Balearic Islands [Conve"] <- "Islas Baleares"
newdat$Locality[newdat$Locality=="Balearic Islands: See Baleares, Islas"] <- "Islas Baleares"
newdat$Province[newdat$Locality=="Islas Baleares"] <- "Islas Baleares"
newdat$Locality[newdat$Locality=="Islas Baleares"] <- NA
newdat$Locality[newdat$Locality=="Banolas"] <- "Bañolas"
newdat$Locality[newdat$Locality=="Banos"] <- "Baños"
newdat$Locality[newdat$Locality=="Banos de Montemayor"] <- "Baños de Montemayor"
newdat$Locality[newdat$Locality=="Banos de Panticosa"] <- "Baños de Panticosa"
newdat$Locality[newdat$Locality=="Barranco de la Verruga;G´?¢Rgal; Sierra de los Fi	1780	19910920	Ortiz, F	Gbif,2015	Ku"] <- "Barranco de la Verruga"
newdat$Locality[newdat$Locality=="Barranco de la Verruga;G´?¢Rgal; Sierra de los Fi	1780	19910920	Ortiz, F	Gbif,2015	Ku"]  <- "Benalmádena"
newdat$Locality[newdat$Locality=="Benalmadena"]  <- "Benalmádena"
newdat$Locality[newdat$Locality=="Benasque, Valle de"]  <- "Valle de Benasque"
newdat$Locality[newdat$Locality=="Beniarda, 44 Km Ne of Alicante"]  <- "Beniarda (near Alicante)"
newdat$Locality[newdat$Locality=="Beniarda"]  <- "Beniarda (near Alicante)"
newdat$Locality[newdat$Locality=="Betlem, Es Cal??"]  <- "Betlem-Es Caló"
newdat$Locality[newdat$Locality=="Beznar"]  <- "Béznar"
newdat$Locality[newdat$Locality=="Bï¿½Znar"]  <- "Béznar"
newdat$Locality[newdat$Locality=="Bilbao, Ondarroa"]  <- "Ondarroa"
newdat$Locality[newdat$Locality=="Binies"]  <- "Biniés"
newdat$Province[newdat$Locality=="Boiro, 2 Km. S.e. of"]  <- "La Coruña"
newdat$Locality[newdat$Locality=="Boiro, 2 Km. S.e. of"]  <- "Boiro"
newdat$Province[newdat$Locality=="Boiro, 3 Km South-East of"]  <- "La Coruña"
newdat$Locality[newdat$Locality=="Boiro, 3 Km South-East of"]  <- "Boiro"
newdat$Province[newdat$Locality=="Burgos S MillãN de Juarros"]  <- "Burgos"
newdat$Locality[newdat$Locality=="Burgos S MillãN de Juarros"]  <- "San Millán de Juarros"
newdat$Locality[newdat$Locality=="Burgos S MillãN de Juarros"]  <- "San Millán de Juarros"
newdat$Province[newdat$Locality=="Ca??Ada de la Estrella"]  <- "Valencia"
newdat$Province[newdat$Locality=="Ca??Ada de la Estrella"]  <- "Olocau"
newdat$Province[newdat$Locality=="Cádiz [Spanish]; Cadiz [Conventional]"]  <- "Cádiz"
newdat$Locality[newdat$Locality=="Cádiz [Spanish]; Cadiz [Conventional]"]  <- NA
newdat$Province[newdat$Locality=="Cádiz"]  <- "Cádiz"
newdat$Locality[newdat$Locality=="Cádiz"]  <- NA
newdat$Province[newdat$Locality=="Cadiz"]  <- "Cádiz"
newdat$Locality[newdat$Locality=="Cadiz"]  <- NA
newdat$Province[newdat$Locality=="Cadix"]  <- "Cádiz"
newdat$Locality[newdat$Locality=="Cadix"]  <- NA
newdat$Locality[newdat$Locality=="?Wis"]  <- NA
newdat$Province[newdat$Locality=="@Ambel"]  <- "Zaragoza"
newdat$Locality[newdat$Locality=="@Ambel"]  <- "Ambel"
newdat$Province[newdat$Locality=="Cadaquã©S"]  <- "Gerona"
newdat$Locality[newdat$Locality=="Cadaquã©S"]  <- "Cadaqués"
newdat$Locality[newdat$Locality=="Cadaques"]  <- "Cadaqués"
newdat$Locality[newdat$Locality=="Cahas, 42â°52'50\" N-2 4420 W of Paris"]  <- "Cahas (W of Paris)"
newdat$Locality[newdat$Locality=="Camprodã³N"]  <- "Camprodón"
newdat$Locality[newdat$Locality=="Camprodã³N"]  <- "Camprodón"
newdat$Locality[newdat$Locality=="Camprodon"]  <- "Camprodón"
newdat$Locality[newdat$Locality=="Can Pastilla, Palma de Majorca"]  <- "Can Pastilla, Palma de Mallorca"
newdat$Locality[newdat$Locality=="Canary Islands: See Canarias, Islas"]  <- NA
newdat$Locality[newdat$Locality=="Candelario, Sierra de"]  <- "Sierra de Candelario"
newdat$Locality[newdat$Locality=="Canet de Mar"]  <- "Cañet de Mar"
newdat$Locality[newdat$Locality=="Canet de Mar."]  <- "Cañet de Mar"
newdat$Locality[newdat$Locality=="Canete"]  <- "Cañete"
newdat$Locality[newdat$Locality=="Cartaya En Gibraleã³N, Tussen"]  <- "Cartaya (Huelva)"
newdat$Locality[newdat$Locality=="Cazorla, Sierra de"]  <- "Sierra de Cazorla"
newdat$Locality[newdat$Locality=="Cazorla"]  <- "Sierra de Cazorla"
newdat$Province[newdat$Locality=="Chiclana: See Chiclana de la Frontera"]  <- "Cádiz"
newdat$Locality[newdat$Locality=="Chiclana: See Chiclana de la Frontera"]  <- "Chiclana de la Frontera"
newdat$Locality[newdat$Locality=="Cohceicã¢O de Tavira"]  <- "Tavira (Portugal)"
newdat$Locality[newdat$Locality=="Col de Sollã©R"]  <- "Coll de Sóller" 
newdat$Locality[newdat$Locality=="Col Du Pourtalet, 42â°49' 20\"N 2 43 40 W of Paris"]  <- "Col Du Pourtalet" 
newdat$Locality[newdat$Locality=="Corona, Monte"]  <- "Monte Corona" 
newdat$Locality[newdat$Locality=="Europa, Picos de"]  <- "Picos de Europa" 
newdat$Province[newdat$Locality=="Fr´?¢As de Albarrac´?¢N"]  <- "Teruel" 
newdat$Locality[newdat$Locality=="Fr´?¢As de Albarrac´?¢N"]  <- "Frías de Albarracín" 
newdat$Locality[newdat$Locality=="Fuengirola, lage Crucif [?]"]  <- "Fuengirola" 
newdat$Province[newdat$Locality=="Fuentidueï¿½A, 66 Km N of Segovia"]  <- "Segovia" 
newdat$Locality[newdat$Locality=="Fuentidueï¿½A, 66 Km N of Segovia"]  <- "Fuentidueña" 
newdat$Locality[newdat$Locality=="Gador, Sierra"]  <- "Sierra de Gádor" 
newdat$Locality[newdat$Locality=="Gador, Sierra de"]  <- "Sierra de Gádor" 
newdat$Locality[newdat$Locality=="Gata, Cabo de"]  <- "Cabo de Gata" 
newdat$Locality[newdat$Locality=="Gijã³N"]  <- "Gijón" 
newdat$Locality[newdat$Locality=="Gijon"]  <- "Gijón" 
newdat$Locality[newdat$Locality=="Gra@, Sierra Nevada"]  <- "Sierra Nevada" 
newdat$Province[newdat$Locality=="Granada, Provincia de"]  <- "Granada" 
newdat$Locality[newdat$Locality=="Granada, Provincia de"]  <- NA 
newdat$Locality[newdat$Locality=="Gredos, Sierra de"]  <- "Sierra de Gredos" 
newdat$Locality[newdat$Locality=="Gredos: See Gredos, Sierra de"]  <- "Sierra de Gredos" 
newdat$Locality[newdat$Locality=="Gumiel de Hizan"]  <- "Gumiel de Hizán" 
newdat$Locality[newdat$Locality=="Hierro [Spanish]; Ferro [Conventional]"]  <- "El Hierro" 
newdat$Locality[newdat$Locality=="Jerte"]  <- "Valle del Jerte" 
newdat$Locality[newdat$Locality=="Jerte, Cã¡Ceres"]  <- "Valle del Jerte" 
newdat$Locality[newdat$Locality=="La Gomera, Isla de"]  <- "La Gomera" 
newdat$Locality[newdat$Locality=="La Gomera, Isla de la"]  <- "La Gomera" 
newdat$Province[newdat$Locality=="Logroño, Provincia de"]  <- "Logroño" 
newdat$Locality[newdat$Locality=="Maci´?¢N, V´?¢Lez-Blanco"]  <- "Vélez-Blanco" 
newdat$Locality[newdat$Locality=="Mahã³N"]  <- "Mahón" 
newdat$Locality[newdat$Locality=="Mahon"]  <- "Mahón" 
newdat$Locality[newdat$Locality=="Majorca Island: See Mallorca, Isla de"]  <- "Isla de Mallorca" 
newdat$Locality[newdat$Locality=="Malaga"]  <- "Málaga" 
newdat$Locality[newdat$Locality=="Mallorca, Isla de"]  <- "Isla de Mallorca" 
newdat$Locality[newdat$Locality=="Mallorca, Isla de [Spanish]; Majorca Island [Conve"]  <- "Isla de Mallorca" 
newdat$Locality[newdat$Locality=="Marisma 10 Km. N.v Sanlãºear de Barrameda"]  <- "Marisma, 10 km N Sanlucar de Barrameda" 
newdat$Locality[newdat$Locality=="Marisma, 10 Km. N. V Sanlucar de Barrameda"]  <- "Marisma, 10 km N Sanlucar de Barrameda" 
newdat$Locality[newdat$Locality=="Navacerrada, Puerto de"]  <- "Puerto de Navacerrada" 
newdat$Locality[newdat$Locality=="Pina [Pina de Ebro]"]  <- "Pina de Ebro" 
newdat$Locality[newdat$Locality=="Pina: See Pina de Ebro"]  <- "Pina de Ebro" 
newdat$Locality[newdat$Locality=="Pinet,Salinas del"]  <- "Salinas del Pinet" 
newdat$Locality[newdat$Locality=="Playa Blanca / lanzarote"]  <- "Playa Blanca (Lanzarote)" 
newdat$Locality[newdat$Locality=="Playa Blanca"]  <- "Playa Blanca (Lanzarote)" 
newdat$Locality[newdat$Locality=="Pol?¡Gono Alqueria de la Mina"]  <- "Polígono Alquería de la Mina" 
newdat$Locality[newdat$Locality=="Pol?¡Gono Alqueria de la Mina"]  <- "Polígono Alquería de la Mina" 
newdat$Locality[newdat$Locality=="Ponta do Castelo, N 37º04'28\" W 08º17'25\""]  <- "Ponta do Castelo" 
newdat$Province[newdat$Locality=="Pontevedra, Provincia de"]  <- "Pontevedra" 
newdat$Province[newdat$Locality=="Pontevedra, Provincia de"]  <- NA 
newdat$Locality[newdat$Locality=="Pozo Alcã³N, Rio Turrillo"]  <- "Pozo Alcón, Río Turrillo" 
newdat$Locality[newdat$Locality=="Puebla de don Fabrique"]  <- "Puebla de don Fadrique" 
newdat$Locality[newdat$Locality=="Puentecillas, Río de las"]  <- "Río de las Puentecillas" 
newdat$Locality[newdat$Locality=="Puerto de Sollã©R"]  <- "Puerto de Sóller" 
newdat$Locality[newdat$Locality=="Puerto de Soller"]  <- "Puerto de Sóller" 
newdat$Locality[newdat$Locality=="Pyrenees [Conventional, *****Cci]; Pirineos [Spain"]  <- "Pirineos (Pyrenees)" 
newdat$Locality[newdat$Locality=="Quarteira, Trafal, N 37º03'56\" W 08º04'26\""]  <- "Trafal (Quarteira)" 
newdat$Locality[newdat$Locality=="R?¡O Arriba"]  <- "Río Arriba" 
newdat$Locality[newdat$Locality=="4R?¡O Regajo"]  <- "Río Regajo" 
newdat$Locality[newdat$Locality=="Ramalhosa"]  <- "Ramallosa (Bayona)" 
newdat$Locality[newdat$Locality=="Ramallosa"]  <- "Ramallosa (Bayona)" 
newdat$Locality[newdat$Locality=="Rasmalho, N 37º13'10\" W 08º32'46\""]  <- "Rasmalho" 
newdat$Locality[newdat$Locality=="Rincon de la Victoria"]  <- "Rincón de la Victoria" 
newdat$Locality[newdat$Locality=="Rincon de la Victoria"]  <- "Rincón de la Victoria" 
newdat$Locality[grepl("San Juan de la Rambla; Monta", newdat$Locality)] <- "San Juan de la Rambla, Montaña negra"
newdat$Locality[grepl("San Juan de la Rambla; Riscos", newdat$Locality)] <- "San Juan de la Rambla, Riscos de la Fortaleza"
newdat$Locality[newdat$Locality=="Santander, Playa Cã³Breces"]  <- "Playa de Cóbreces" 
newdat$Province[newdat$Locality=="Santander, Provincia de"]  <- "Santander" 
newdat$Province[newdat$Locality=="Santander, Provincia de"]  <- NA 
newdat$Locality[newdat$Locality=="Santillana del Mar: See Santillana"]  <- "Santillana del Mar"
newdat$Locality[newdat$Locality=="Sepulveda"]  <- "Sepúlveda"
newdat$Locality[newdat$Locality=="Zumaya G V Biscaje"]  <- "Zumaya"
newdat$Locality[newdat$Locality=="Zarauz, Ensenada de"]  <- "Ensenada de Zarauz"
newdat$Province[newdat$Locality=="Zaragoza, Provincia de"]  <- "Zaragoza"
newdat$Locality[newdat$Locality=="Zaragoza, Provincia de"]  <- NA
newdat$Locality[newdat$Locality=="Zaragoza, Alag??N"]  <- "Alagón (Zaragoza)"
newdat$Province[newdat$Locality=="Zamora, Provincia de"]  <- "Zaragoza"
newdat$Locality[newdat$Locality=="Zamora, Provincia de"]  <- NA
newdat$Province[newdat$Locality=="Zamora"]  <- "Zamora"
newdat$Locality[newdat$Locality=="Zamora"]  <- NA
newdat$Province[newdat$Locality=="Vizcaya, Provincia de"]  <- "Vizcaya"
newdat$Locality[newdat$Locality=="Vizcaya, Provincia de"]  <- NA
newdat$Locality[newdat$Locality=="Viscaya, Kust Bij Somorrostro (Tussen Bilbao En Castro Urdiales)"]  <- "San Juan de Musques"
newdat$Locality[newdat$Locality=="Villaviciosa, Apeadero de"]  <- "Apeadero de Villaviciosa"
newdat$Locality[newdat$Locality=="Villarta de S.juan"]  <- "Villarta de San Juan"
newdat$Locality[newdat$Locality=="Villar, Arroyo del"]  <- "Arroyo del Villar"
newdat$Locality[newdat$Locality=="Villanueva: See Villanueva del Rey"]  <- "Villanueva del Rey"
newdat$Locality[newdat$Locality=="Villanueva de Valdueza, In de Montes de Leã³N"]  <- "Villanueva de Valdueza"
newdat$Locality[newdat$Locality=="Villanueva de Valdueza, In de Monte de Leã³N"]  <- "Villanueva de Valdueza"
newdat$Locality[newdat$Locality=="Villajuan, S.w. of Villagarcia (Pontevedra)"]  <- "Villajuan South West of Villagarcia"
newdat$Locality[newdat$Locality=="Villajoyosa/Vila Joi"]  <- "Villajoyosa"
newdat$Locality[newdat$Locality=="Villaflor: See Vilaflor"]  <- "Villaflor"
newdat$Locality[newdat$Locality=="Velilla, Almu´?¢´?¢Car"]  <- "Velilla (Almuñecar)"
newdat$Locality[newdat$Locality=="Veleze Mã Lã Ga 7 Km. N."]  <- "Vélez-Málaga"
newdat$Locality[newdat$Locality=="Velez, 7 km N Málaga"]  <- "Vélez-Málaga"
newdat$Locality[newdat$Locality=="Velez Malaga"]  <- "Vélez-Málaga"
newdat$Locality[newdat$Locality=="Velez Mã¡Laga, 7km N.a"]  <- "Vélez-Málaga"
newdat$Locality[newdat$Locality=="Velez Mã¡Laga, 7km N"]  <- "Vélez-Málaga"
newdat$Locality[newdat$Locality=="Velez Mã¡Laga, 7 Km N"]  <- "Vélez-Málaga"
newdat$Locality[newdat$Locality=="Velez Mã Lã Ga 7 Km N"]  <- "Vélez-Málaga"
newdat$Province[newdat$Locality=="Valladolid, Provincia de"]  <- "Valladolid"
newdat$Locality[newdat$Locality=="Valladolid, Provincia de"]  <- NA
newdat$Province[newdat$Locality=="Valladolid"]  <- "Valladolid"
newdat$Locality[newdat$Locality=="Valladolid"]  <- NA
newdat$Locality[newdat$Locality=="Torre de Peã±Afiel"]  <- "Torre de Peñafiel"
newdat$Locality[newdat$Locality=="Tornavacas, Puerto de"]  <- "Puerto de Tornavacas"
newdat$Province[newdat$Locality=="Toledo, Toledo"]  <- "Toledo"
newdat$Locality[newdat$Locality=="Toledo, Toledo"]  <- NA
newdat$Province[newdat$Locality=="Toledo, Provincia de"]  <- "Toledo"
newdat$Locality[newdat$Locality=="Toledo, Provincia de"]  <- NA
newdat$Province[newdat$Locality=="Toledo"]  <- "Toledo"
newdat$Locality[newdat$Locality=="Toledo"]  <- NA
newdat$Locality[newdat$Locality=="Tirajana, Barranco de"]  <- "Barranco de Tiranaja"
newdat$Locality[newdat$Locality=="Tibidabo, Monte del"]  <- "Tibidabo"
newdat$Locality[newdat$Locality=="Tibidabo, Barcelona"]  <- "Tibidabo"
newdat$Locality[newdat$Locality=="Teyde, Pico de: See Teide, Pico de"]  <- "Teide (Tenerife)"
newdat$Locality[newdat$Locality=="Teyde, Pico de"]  <- "Teide (Tenerife)"
newdat$Province[newdat$Locality=="Teruel, Provincia de"]  <- "Teide (Tenerife)"
newdat$Locality[newdat$Locality=="Teruel, Provincia de"]  <- NA
newdat$Province[newdat$Locality=="Teruel"]  <- "Teruel"
newdat$Locality[newdat$Locality=="Teruel"]  <- NA
newdat$Locality[newdat$Locality=="Teide, Pico de"]  <- "Teide (Tenerife)"
newdat$Province[newdat$Locality=="Tarragona"]  <- "Tarragona"
newdat$Locality[newdat$Locality=="Tarragona"]  <- NA
newdat$Locality[newdat$Locality=="Spain: See Spain, Kingdom of"]  <- NA
newdat$Locality[newdat$Locality=="Spain"]  <- NA
newdat$Province[newdat$Locality=="Soria"]  <- "Soria"
newdat$Locality[newdat$Locality=="Soria"]  <- NA
newdat$Province[newdat$Locality=="Sierra"]  <- "Granada"
newdat$Locality[newdat$Locality=="Sierra"]  <- NA
newdat$Locality[newdat$Locality=="Sier"]  <- NA
newdat$Province[newdat$Locality=="Sevilla, Provincia de"]  <- "Sevilla"
newdat$Locality[newdat$Locality=="Sevilla, Provincia de"]  <- NA
newdat$Province[newdat$Locality=="Sevilla"]  <- "Sevilla"
newdat$Locality[newdat$Locality=="Sevilla"]  <- NA
newdat$Province[newdat$Locality=="Segovia"]  <- "Segovia"
newdat$Locality[newdat$Locality=="Segovia"]  <- NA

#Dataframe to check unique cases of localities
#l <- as.data.frame(unique(newdat$Locality))
#It looks better now
#More work can be done here 

#Quick scroll of coordinates, they seem ok at first glance
#d <- as.data.frame(levels(factor(newdat$Latitude)))
#d <- as.data.frame(levels(factor(newdat$Longitude)))
#One Longitude val. to fix
newdat$Longitude[newdat$Longitude=="-4006"] <- "-4.006"
newdat$Latitude <- as.numeric(newdat$Latitude)
newdat$Latitude[newdat$Latitude>1000] <- NA
#Years also look good
#levels(factor(newdat$Year))
#Months look good too
#levels(factor(newdat$Month))
#Days also look fine
#levels(factor(newdat$Day))

#Check
#Fixing one NA with space in start date
newdat$Start.date[newdat$Start.date==" NA"] <- NA

#Some dates seem wrong, the "all to 1900s" in start date and then
#their End.date too (they are from 2010 or more ans seems they are from 1970's)
#Converting to NA for now
#First the end date ones
newdat$End.date[newdat$Start.date=="all to 1900s"] <- NA
#Now the start date ones
newdat$Start.date[newdat$Start.date=="all to 1900s"] <- NA

newdat$Start.date[newdat$Start.date=="3/00/1957"] <- "3/01/1957"
newdat$Start.date[newdat$Start.date=="5/00/1927"] <- "5/01/1927"

#Convert Start.date to day/month/year
library(anytime)  
#This library is awesome and can stand 
#leading zeros and without zeros
newdat$Start.date <- anydate(newdat$Start.date)
#Now is in YEAR/MONTH/DAY
#Convert to standard format of the database
newdat$Start.date <- as.Date(newdat$Start.date,format = "%y/%d/%m")
newdat$Start.date<- format(newdat$Start.date, "%d/%m/%Y")



#Now fix levels
d <- as.data.frame(levels(factor(newdat$End.date))) #check levels
#This needs quite a bit of work
#Wrong dates with just the date in the reference field will be assigned
#that year

#Important some are day/month and others month/day which
#makes me think that this info may be not very reliable
#and just yeat would be th accurate field


#The ref is Lindberg H. (1933)
newdat$Year[newdat$End.date=="____0408"] <- "1933"
newdat$End.date[newdat$End.date=="____0408"] <- NA
#No date for these ones
newdat$End.date[newdat$End.date=="____0623"] <- NA
newdat$End.date[newdat$End.date=="____0627"] <- NA
# //0 and Ornosa Gallego, 1984
newdat$Year[newdat$End.date=="//0" & 
              newdat$Reference.doi=="Ornosa Gallego, 1984"] <- "1984"
newdat$End.date[newdat$End.date=="//0" & 
                  newdat$Reference.doi=="Ornosa Gallego, 1984"] <- NA
# //0 and Warncke,1983
newdat$Year[newdat$End.date=="//0" & 
              newdat$Reference.doi=="Warncke,1983"] <- "1983"
newdat$End.date[newdat$End.date=="//0" & 
                  newdat$Reference.doi=="Warncke,1983"] <- NA
# //0 and RASMONT 1988
newdat$Year[newdat$End.date=="//0" & 
              newdat$Reference.doi=="RASMONT 1988"] <- "1988"
newdat$End.date[newdat$End.date=="//0" & 
                  newdat$Reference.doi=="RASMONT 1988"] <- NA
# //0 and Ornosa, UICN
newdat$End.date[newdat$End.date=="//0" & 
                  newdat$Reference.doi=="Ornosa, UICN"] <- NA
# //0 and Reinig 1939
newdat$Year[newdat$End.date=="//0" & 
              newdat$Reference.doi=="Reinig 1939"] <- "1939"
newdat$End.date[newdat$End.date=="//0" & 
                  newdat$Reference.doi=="Reinig 1939"] <- NA
# //0 and TKALCU 1962
newdat$Year[newdat$End.date=="//0" & 
              newdat$Reference.doi=="TKALCU 1962"] <- "1962"
newdat$End.date[newdat$End.date=="//0" & 
                  newdat$Reference.doi=="TKALCU 1962"] <- NA
# //0 and Lieftinck,1980
newdat$Year[newdat$End.date=="//0" & 
              newdat$Reference.doi=="Lieftinck,1980"] <- "1980"
newdat$End.date[newdat$End.date=="//0" & 
                  newdat$Reference.doi=="Lieftinck,1980"] <- NA
# //0 and Lieftinck,1968 
newdat$Year[newdat$End.date=="//0" & 
              newdat$Reference.doi=="Lieftinck,1968 "] <- "1968"
newdat$End.date[newdat$End.date=="//0" & 
                  newdat$Reference.doi=="Lieftinck,1968 "] <- NA
# //0 and Ornosa, 1991
newdat$Year[newdat$End.date=="//0" & 
              newdat$Reference.doi=="Ornosa, 1991"] <- "1991"
newdat$End.date[newdat$End.date=="//0" & 
                  newdat$Reference.doi=="Ornosa, 1991"] <- NA
# //0 and ""
newdat$End.date[newdat$End.date=="//0" & 
                  newdat$Reference.doi==""] <- NA
# //0 and "GBIF,2015"
newdat$Year[newdat$End.date=="//0" & 
              newdat$Reference.doi=="GBIF,2015"] <- "2015"
newdat$End.date[newdat$End.date=="//0" & 
                  newdat$Reference.doi=="GBIF,2015"] <- NA
# // and "PEREZ 1902"
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="PEREZ 1902"] <- 1902
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="PEREZ 1902"] <- NA
# // and "GBIF,2015"
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="GBIF,2015"] <- 2015
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="GBIF,2015"] <- NA
# // and ROBERTI,FRILLI 1965
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="ROBERTI,FRILLI 1965"] <- 1965
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="ROBERTI,FRILLI 1965"] <- NA
# // and COCKERELL 1925
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="COCKERELL 1925"] <- 1925
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="COCKERELL 1925"] <- NA
# // and ROBERTI & AL. 1965
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="ROBERTI & AL. 1965"] <- 1965
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="ROBERTI & AL. 1965"] <- NA
# // and DUSMET 1908
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="DUSMET 1908"] <- 1908
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="DUSMET 1908"] <- NA
# // and ALFKEN 1927
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="ALFKEN 1927"] <- 1927
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="ALFKEN 1927"] <- NA
# // and FRIESE 1896
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="FRIESE 1896"] <- 1896
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="FRIESE 1896"] <- NA
# // and RASMONT 1988
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="RASMONT 1988"] <- 1988
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="RASMONT 1988"] <- NA
# // and TKALCU 1962
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="TKALCU 1962"] <- 1962
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="TKALCU 1962"] <- NA
# // and ""
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi==" "] <- NA
# // and DUSMET 1935
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="DUSMET 1935"] <- 1935
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="DUSMET 1935"] <- NA
# // and QUILIS-PEREZ 1927
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="QUILIS-PEREZ 1927"] <- 1927
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="QUILIS-PEREZ 1927"] <- NA
# // and DALY 1983
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="DALY 1983"] <- 1983
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="DALY 1983"] <- NA
# // and DUSMET Y ALONSO 1923
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="DUSMET Y ALONSO 1923"] <- 1983
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="DUSMET Y ALONSO 1923"] <- NA
# // and Ebmer 1984
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 1984"] <- 1984
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 1984"] <- NA
# // and SAUNDERS 1901
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="SAUNDERS 1901"] <- 1901
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="SAUNDERS 1901"] <- NA
# // and Ebmer 1993
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 1993"] <- 1993
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 1993"] <- NA
# // and Ebmer 1989
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 1989"] <- 1989
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 1989"] <- NA
# // and SAUNDERS 1901
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="SAUNDERS 1901"] <- 1901
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="SAUNDERS 1901"] <- NA
# // and Ebmer 1999
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 1999"] <- 1999
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 1999"] <- NA
# // and DINIZ 1961
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="DINIZ 1961"] <- 1961
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="DINIZ 1961"] <- NA
# // and Blüthgen 1937
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Blüthgen 1937"] <- 1937
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Blüthgen 1937"] <- NA
# // and Blüthgen 1924
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Blüthgen 1924"] <- 1924
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Blüthgen 1924"] <- NA
# // and Saunders 1904
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Saunders 1904"] <- 1904
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Saunders 1904"] <- NA
# // and BLUTHGEN 1924
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="BLUTHGEN 1924"] <- 1924
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="BLUTHGEN 1924"] <- NA
# // and Ebmer 1979
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 1979"] <- 1979
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 1979"] <- NA
# // and Blüthgen 1936
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Blüthgen 1936"] <- 1936
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Blüthgen 1936"] <- NA
# // and D. Baldock MS
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="D. Baldock MS"] <- NA
# // and BLUT 1923
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="BLUT 1923"] <- 1923
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="BLUT 1923"] <- NA
# // and BLUTGEN 1924
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="BLUTGEN 1924"] <- 1924
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="BLUTGEN 1924"] <- NA
# // and Blüthgen 1936
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Blüthgen 1936"] <- 1936
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Blüthgen 1936"] <- NA
# // and Baldock list vs 2016
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Baldock list vs 2016"] <- 2016
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Baldock list vs 2016"] <- NA
# // and EBMER 1976
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="EBMER 1976"] <- 1976
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="EBMER 1976"] <- NA
# // and Ebmer 1985
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 1985"] <- 1985
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 1985"] <- NA
# // and CAVRO 1950
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="CAVRO 1950"] <- 1950
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="CAVRO 1950"] <- NA
# // and Ebmer 1976
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 1976"] <- 1976
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 1976"] <- NA
# // and BLUTHGEN
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="BLUTHGEN "] <- NA
# // and Ebmer 1988
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 1988"] <- 1988
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 1988"] <- NA
# // and Bluthgen 1924
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Bluthgen 1924"] <- 1924
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Bluthgen 1924"] <- NA
# // and Ebmer 1988
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 1988"] <- 1988
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 1988"] <- NA
# // and Saundrs 1954
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Saundrs 1954"] <- 1954
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Saundrs 1954"] <- NA
# // and SCHULZ 1906
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="SCHULZ 1906"] <- 1906
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="SCHULZ 1906"] <- NA
# // and Ebmer 1975
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 1975"] <- 1975
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 1975"] <- NA
# // and BLUT 1924
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="BLUT 1924"] <- 1924
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="BLUT 1924"] <- NA
# // and Ebmer 1987:343
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 1987:343"] <- 1987
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 1987:343"] <- NA
# // and Ebmer 1987
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 1987"] <- 1987
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 1987"] <- NA
# // and Blüthgen 1923
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Blüthgen 1923"] <- 1923
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Blüthgen 1923"] <- NA
# // and Warncke 1975
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Warncke 1975"] <- 1975
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Warncke 1975"] <- NA
# // and Ebmer 2014
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 2014"] <- 2014
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 2014"] <- NA
# // and Ebmer in Westrich
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer in Westrich"] <- NA
# // and Ebmer in Westrich
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="BLUTHGEN 1935"] <- 1935
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="BLUTHGEN 1935"] <- NA
# // and Blüthgen 1935
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Blüthgen 1935"] <- 1935
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Blüthgen 1935"] <- NA
# // and EOBELLI 1905
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="EOBELLI 1905"] <- 1905
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="EOBELLI 1905"] <- NA
# // and Ortiz & Pauly 2016
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ortiz & Pauly 2016"] <- 2016
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ortiz & Pauly 2016"] <- NA
# // and Blüthgen 1924: 378
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Blüthgen 1924: 378"] <- 1924
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Blüthgen 1924: 378"] <- NA
# // and EBMER 1972
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="EBMER 1972"] <- 1972
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="EBMER 1972"] <- NA
# // and Ortiz et Pauly 2016
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ortiz et Pauly 2016"] <- 2016
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ortiz et Pauly 2016"] <- NA
# // and Ebmer 2000:417.
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 2000:417."] <- 2000
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 2000:417."] <- NA
# // and EOBELLI 1905
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="EOBELLI 1905"] <- 1905
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="EOBELLI 1905"] <- NA
# // and BLUTHEN 1924
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="BLUTHEN 1924"] <- 1924
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="BLUTHEN 1924"] <- NA
# // and Ebmer 1973
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 1973"] <- 1973
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 1973"] <- NA
# // and Ebmer 2000
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 2000"] <- 2000
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 2000"] <- NA
# // and Ebmer 1972
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 1972"] <- 1972
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 1972"] <- NA
# // and Ebmer 2000
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 2000"] <- 2000
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 2000"] <- NA
# // and Ebmer 1997
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 1997"] <- 1997
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 1997"] <- NA
# // and Ebmer 1995
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 1995"] <- 1995
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 1995"] <- NA
# // and BLTHGEN 1924
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="BLTHGEN 1924"] <- 1924
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="BLTHGEN 1924"] <- NA
# // and BLUTHGEN 1944
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="BLUTHGEN 1944"] <- 1944
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="BLUTHGEN 1944"] <- NA
# // and PEREZ 1895
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="PEREZ 1895"] <- 1895
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="PEREZ 1895"] <- NA
# // and Ebmer 1986
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 1986"] <- 1986
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 1986"] <- NA
# // and Cockerell 1922
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Cockerell 1922"] <- 1922
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Cockerell 1922"] <- NA
# // and LIEFTINCK 1969
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="LIEFTINCK 1969"] <- 1969
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="LIEFTINCK 1969"] <- NA
# // and Ebmer 1986
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 1986"] <- 1986
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 1986"] <- NA
# // and DUSMET 1905
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="DUSMET 1905"] <- 1905
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="DUSMET 1905"] <- NA
# // and LIEFTINCK 
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="LIEFTINCK "] <- NA
# // and Warncke 1973
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Warncke 1973"] <- 1973
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Warncke 1973"] <- NA
# // and Ebmer 2005:329
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Ebmer 2005:329"] <- 2005
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Ebmer 2005:329"] <- NA
# // and Warncke 1976
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Warncke 1976"] <- 1976
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Warncke 1976"] <- NA
# // and Lieftinck,1968 
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="Lieftinck,1968 "] <- 1968
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="Lieftinck,1968 "] <- NA
# // and PEREZ 1905
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="PEREZ 1905"] <- 1905
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="PEREZ 1905"] <- NA
# // and DUSMET, J. 1923
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="DUSMET, J. 1923"] <- 1923
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="DUSMET, J. 1923"] <- NA
# // and PEREZ, J. 1901
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="PEREZ, J. 1901"] <- 1901
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="PEREZ, J. 1901"] <- NA
# // and DUSMET 1915
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="DUSMET 1915"] <- 1915
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="DUSMET 1915"] <- NA
# // and DUSMET 1923
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="DUSMET 1923"] <- 1923
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="DUSMET 1923"] <- NA
# // and STRAND 1915
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="STRAND 1915"] <- 1915
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="STRAND 1915"] <- NA
# // and LINDBERG 1933
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="LINDBERG 1933"] <- 1933
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="LINDBERG 1933"] <- NA
# // and DUSMET 1927
newdat$Year[newdat$End.date=="//" & 
              newdat$Reference.doi=="DUSMET 1927"] <- 1927
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi=="DUSMET 1927"] <- NA
# // and ""
newdat$End.date[newdat$End.date=="//" & 
                  newdat$Reference.doi==""] <- NA
# //189 and ""
newdat$End.date[newdat$End.date=="//189" & 
                  newdat$Reference.doi==""] <- NA
# //1896 and ""
newdat$End.date[newdat$End.date=="//1896" & 
                  newdat$Reference.doi==""] <- NA
# //1899 and ""
newdat$End.date[newdat$End.date=="//1899" & 
                  newdat$Reference.doi==""] <- NA
# //1905 and ""
newdat$End.date[newdat$End.date=="//1905" & 
                  newdat$Reference.doi==""] <- NA
# //1958 and ""
newdat$End.date[newdat$End.date=="//1958" & 
                  newdat$Reference.doi==""] <- NA
# //500 and ""
newdat$End.date[newdat$End.date=="//500" & 
                  newdat$Reference.doi==" "] <- NA
# //520 and Warncke,1983
newdat$Year[newdat$End.date=="//520" & 
              newdat$Reference.doi=="Warncke,1983"] <- 1983
newdat$End.date[newdat$End.date=="//520" & 
                  newdat$Reference.doi=="Warncke,1983"] <- NA
# //600" and ""
newdat$End.date[newdat$End.date=="//600" & 
                  newdat$Reference.doi==" "] <- NA
# //623 and ""
newdat$End.date[newdat$End.date=="//623" & 
                  newdat$Reference.doi==""] <- NA
# //7 and ""
newdat$End.date[newdat$End.date=="//7" & 
                  newdat$Reference.doi==""] <- NA
# // and Warncke,1983
newdat$Year[newdat$End.date=="//715" & 
              newdat$Reference.doi=="Warncke,1983"] <- 1983
newdat$End.date[newdat$End.date=="//715" & 
                  newdat$Reference.doi=="Warncke,1983"] <- NA
# //715and PEREZ 1905
newdat$Year[newdat$End.date=="//715" & 
              newdat$Reference.doi=="PEREZ 1905"] <- 1905
newdat$End.date[newdat$End.date=="//715" & 
                  newdat$Reference.doi=="PEREZ 1905"] <- NA
# //716 and Warncke,1983
newdat$Year[newdat$End.date=="//716" & 
              newdat$Reference.doi=="Warncke,1983"] <- 1983
newdat$End.date[newdat$End.date=="//716" & 
                  newdat$Reference.doi=="Warncke,1983"] <- NA
# //717 and ""
newdat$End.date[newdat$End.date=="//717" & 
                  newdat$Reference.doi==" "] <- NA
# //723 and DALY 1983
newdat$Year[newdat$End.date=="//723" & 
              newdat$Reference.doi=="DALY 1983"] <- 1983
newdat$End.date[newdat$End.date=="//723" & 
                  newdat$Reference.doi=="DALY 1983"] <- NA
# //724 and ""
newdat$End.date[newdat$End.date=="//724" & 
                  newdat$Reference.doi==" "] <- NA
# //823 and ""
newdat$End.date[newdat$End.date=="//823" & 
                  newdat$Reference.doi==" "] <- NA
# 00/0/1989
newdat$Year[newdat$End.date=="00/0/1989"] <- "1989"
newdat$End.date[newdat$End.date=="00/0/1989"] <- NA

# 00/00/1853
newdat$Year[newdat$End.date=="00/00/1853"] <- "1853"
newdat$End.date[newdat$End.date=="00/00/1853"] <- NA

# 00/00/1890
newdat$Year[newdat$End.date=="00/00/1890"] <- "1890"
newdat$End.date[newdat$End.date=="00/00/1890"] <- NA

#Maybe better to lose some dates 
#instead of being here all my life
newdat$End.date[grepl("00/00", newdat$End.date)] <- NA
newdat$End.date[grepl("00/", newdat$End.date)] <- NA
newdat$End.date[grepl("/00", newdat$End.date)] <- NA

# 1 - VIII - 1968
newdat$End.date[newdat$End.date=="1 - VIII - 1968"] <- "01/08/1968"
# 1 IX 1969
newdat$End.date[newdat$End.date=="1 IX 1969"] <- "01/09/1969"
# 1 IX 1969
newdat$End.date[newdat$End.date=="1 June 1967"] <- "01/06/1967"
# 1 VII 1960
newdat$End.date[newdat$End.date=="1 VII 1960"] <- "01/07/1960"
# 1-11.4 1985
newdat$End.date[newdat$End.date=="1-11.4.1985"] <- NA
newdat$Start.date[newdat$Start.date=="01/04/1985"] <- NA
# 1-15 - 7 - 1953
newdat$End.date[newdat$End.date=="1-15 - 7 - 1953"] <- NA
newdat$Start.date[newdat$Start.date=="01/07/1953"] <- NA
# 1-15 - 7 1953
newdat$End.date[newdat$End.date=="1-15 - 7 1953"] <- NA
newdat$Start.date[newdat$Start.date=="01/07/1953"] <- NA
# 1-11.4 1985
newdat$End.date[newdat$End.date=="1-11.4 1985"] <- NA
newdat$Start.date[newdat$Start.date=="01/04/1985"] <- NA
# 1-15-7-1953
newdat$End.date[newdat$End.date=="1-15-7-1953"] <- NA
newdat$Start.date[newdat$Start.date=="01/07/1953"] <- NA
# 1-24 VI 1954
newdat$End.date[newdat$End.date=="1-24 VI 1954"] <- NA
newdat$Start.date[newdat$Start.date=="01/06/1954"] <- NA
# 1-7-7@
newdat$End.date[newdat$End.date=="1-7-7@"] <- NA
# 1-mrt-23
newdat$End.date[newdat$End.date=="1-mrt-23"] <- NA
# 1-V-1960
newdat$End.date[newdat$End.date=="1-V-1960"] <- "01/05/1960"
# 1-vi-1962
newdat$End.date[newdat$End.date=="1-vi-1962"] <- "01/06/1962"
# 1-vi-1970
newdat$End.date[newdat$End.date=="1-vi-1970"] <- "01/06/1970"
# 1-VII-19
newdat$End.date[newdat$End.date=="1-VII-19"] <- NA
# 1-VII-1960
newdat$End.date[newdat$End.date=="1-VII-1960"] <- "01/07/1960"
# 1-vii-1960
newdat$End.date[newdat$End.date=="1-vii-1960"] <- "01/07/1960"
# 1-VII-1968
newdat$End.date[newdat$End.date=="1-VII-1968"] <- "01/07/1968"
# 1-VIII-1952
newdat$End.date[newdat$End.date=="1-VIII-1952"] <- "01/08/1952"
# 1-viii-1968
newdat$End.date[newdat$End.date=="1-viii-1968"] <- "01/08/1968"
# 1-viii-1968
newdat$End.date[newdat$End.date=="1-viii-1968"] <- "01/08/1968"
# 1.-11.4.1985
newdat$End.date[newdat$End.date=="1.-11.4.1985"] <- NA
newdat$Start.date[newdat$Start.date=="1.-11.4.1985"] <- NA
# 1.IX.1969
newdat$End.date[newdat$End.date=="1.IX.1969"] <- "01/09/1969"
# 1.V.1993
newdat$End.date[newdat$End.date=="1.V.1993"] <- "01/05/1993"
# 1.vi.1970
newdat$End.date[newdat$End.date=="1.vi.1970"] <- "01/06/1970"
# 1.VIII.1970
newdat$End.date[newdat$End.date=="1.VIII.1970"] <- "01/08/1970"
# 1/10-4/10-1977
newdat$End.date[newdat$End.date=="1/10-4/10-1977"] <- NA
newdat$Start.date[newdat$Start.date=="01/10/1977"] <- NA

newdat$End.date <- gsub("-", "/", newdat$End.date,fixed = TRUE)
newdat$End.date <- gsub(".", "/", newdat$End.date,fixed = TRUE)
newdat$End.date <- gsub(" ", "/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/V/", "/05/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/v/", "/05/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/VI/", "/06/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/VII/", "/07/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/vii/", "/07/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/vi/", "/07/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/VIII/", "/08/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/viii/", "/08/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/iv/", "/04/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/IV/", "/04/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/IX/", "/09/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/ix/", "/09/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/X/", "/10/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/x/", "/10/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/III/", "/03/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/iii/", "/03/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/Aug/", "/08/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/Feb/", "/02/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/June/", "/06/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/May/", "/05/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/Jul/", "/07/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/Febr/", "/02/", newdat$End.date,fixed = TRUE)
newdat$End.date <- sub("/July/", "/07/", newdat$End.date,fixed = TRUE)


# ////////
newdat$End.date[newdat$End.date=="////////"] <- NA
newdat$End.date[newdat$End.date=="////////"] <- NA

#10/08/924
newdat$End.date[newdat$End.date=="10/08/924"] <- NA
#10/5/1974/
newdat$End.date[newdat$End.date=="10/5/1974/"] <- "10/5/1974"
#11/06/37
newdat$End.date[newdat$End.date=="11/06/37"] <- "11/06/1937"
#11/07/84
newdat$End.date[newdat$End.date=="11/07/84"] <- "11/07/1984"
#12///06///1970
newdat$End.date[newdat$End.date=="12///06///1970"] <- "12/06/1970"
#12///07///1972
newdat$End.date[newdat$End.date=="12///07///1972"] <- "12/07/1972"
#12/07/924
newdat$End.date[newdat$End.date=="12/07/924"] <- "12/07/1924"
#12/08/924
newdat$End.date[newdat$End.date=="12/08/924"] <- "12/08/1924"
#12/15/05/1960
newdat$End.date[newdat$End.date=="12/15/05/1960"] <- NA
#12/15/V1960
newdat$End.date[newdat$End.date=="12/15/V1960"] <- "12/15/1960"
#10/07/60
newdat$End.date[newdat$End.date=="10/07/60"] <- "10/07/1960"
#11/11/05/49
newdat$End.date[newdat$End.date=="11/11/05/49"] <- NA
#13/9/'67
newdat$End.date[newdat$End.date=="13/9/'67"] <- NA
#14/05/58
newdat$End.date[newdat$End.date=="14/05/58"] <- NA
#14/15/V1959
newdat$End.date[newdat$End.date=="14/15/V1959"] <- NA
#14/May
newdat$Day[newdat$End.date=="14/May"] <- "14"
newdat$Month[newdat$End.date=="14/May"] <- "05"
newdat$End.date[newdat$End.date=="14/May"] <- NA
#11/22//6/1951
newdat$End.date[newdat$End.date=="11/22//6/1951"] <- NA
#15//08/1968
newdat$End.date[newdat$End.date=="15//08/1968"] <- "08/15/1968"
#15/04/87
newdat$End.date[newdat$End.date=="15/04/87"] <- "04/15/1987"
#25/5/@
newdat$End.date[newdat$End.date=="25/5/@"] <- NA
#25/06/1985/ERROR
newdat$End.date[newdat$End.date=="25/06/1985/ERROR"] <- "06/25/1985"
#25/05/58
newdat$End.date[newdat$End.date=="25/05/58"] <- "05/25/1958"
#24/vii/1969
newdat$End.date[newdat$End.date=="24/vii/1969"] <-NA
#24/May
newdat$Day[newdat$End.date=="24/May"] <- "24"
newdat$Month[newdat$End.date=="24/May"] <- "05"
newdat$End.date[newdat$End.date=="24/May"] <- NA
#24/Jun/81
newdat$End.date[newdat$End.date=="24/06/1981"] <-NA
#24/7/69
newdat$End.date[newdat$End.date=="24/7/69"] <-"07/24/1969"
#15//08/1968
newdat$End.date[newdat$End.date=="15//08/1968"] <-"08/15/1968"
#15/04/87
newdat$End.date[newdat$End.date=="15/04/87"] <-"04/15/1987"
#15/5/'67
newdat$End.date[newdat$End.date=="15/5/'67"] <-NA
#15/6/19/
newdat$End.date[newdat$End.date=="15/6/19/"] <-NA
#15/Jul
newdat$End.date[newdat$End.date=="15/Jul"] <-NA
#15/V
newdat$End.date[newdat$End.date=="15/V"] <-NA
#15/vii/1970
newdat$End.date[newdat$End.date=="15/vii/1970"] <-NA
#16/03/70
newdat$End.date[newdat$End.date=="16/03/70"] <- "03/16/1970"
#16/05/58
newdat$End.date[newdat$End.date=="16/05/58"] <-NA
#16/V
newdat$End.date[newdat$End.date=="16/V"] <-NA
#17/04/87
newdat$End.date[newdat$End.date=="17/04/87"] <- "04/17/1987"
#17/05/47
newdat$End.date[newdat$End.date=="17/05/47"] <- "05/17/1947"
#17/7/86
newdat$End.date[newdat$End.date=="17/7/86"] <- "07/17/1986"
#17/7/90
newdat$End.date[newdat$End.date=="17/7/90"] <- "07/17/1990"
#17/V
newdat$End.date[newdat$End.date=="17/V"] <- NA
#18/04/08
newdat$End.date[newdat$End.date=="18/04/08"] <- "04/18/1908"
#18/05/58
newdat$End.date[newdat$End.date=="18/05/58"] <- "05/18/1958"
#18/4
newdat$End.date[newdat$End.date=="18/4"] <- "04/18/1908"
#18/4/08
newdat$End.date[newdat$End.date=="18/4/08"] <- "04/18/1908"
#18/8/'78
newdat$End.date[newdat$End.date=="18/8/\'78"] <- "08/18/1978"
#18/8/78
newdat$End.date[newdat$End.date=="18/8/78"] <- "08/18/1978"
#18/MÃ¤rz/24
newdat$End.date[newdat$End.date=="18/MÃ¤rz/24"] <- "03/18/1924"
#18/V
newdat$End.date[newdat$End.date=="18/V"] <- NA
#18/vii/1950
newdat$End.date[newdat$End.date=="18/vii/1950"] <- "07/18/1950"
#18/vii/1950
newdat$End.date[newdat$End.date=="189?"] <- NA
#19/8/'52
newdat$End.date[newdat$End.date=="19/8/'52"] <- "08/19/1952"
#2/05/08
newdat$End.date[newdat$End.date=="2/05/08"] <- "02/05/1908"
#2/05/58
newdat$End.date[newdat$End.date=="2/05/08"] <- "02/05/1908"
#2/9/79
newdat$End.date[newdat$End.date=="2/9/79"] <- "02/09/1979"

#The following dates are day/month/year
#This could be for more but these are the only ones above 12 that are
#outstanding out from the others

#20/03/1980
newdat$End.date[newdat$End.date=="20/03/1980"] <- "03/20/1980"
#20/04/1984
newdat$End.date[newdat$End.date=="20/04/1984"] <- "04/20/1984"
#20/05/1960
newdat$End.date[newdat$End.date=="20/05/1960"] <- "05/20/1960"
#20/06/1955
newdat$End.date[newdat$End.date=="20/06/1955"] <- "06/20/1955"
#20/06/1961
newdat$End.date[newdat$End.date=="20/06/1961"] <- "06/20/1961"
#20/06/1967
newdat$End.date[newdat$End.date=="20/06/1967"] <- "06/20/1967"
#20/06/2016
newdat$End.date[newdat$End.date=="20/06/2016"] <- "06/20/2016"
#20/07/1972
newdat$End.date[newdat$End.date=="20/07/1972"] <- "07/20/1972"
#20/08/1966
newdat$End.date[newdat$End.date=="20/08/1966"] <- "08/20/1966"
#20/21/mei
newdat$End.date[newdat$End.date=="20/21/mei"] <- NA
#20/6/1978
newdat$End.date[newdat$End.date=="20/6/1978"] <- "06/20/1978"
#20/7/1988
newdat$End.date[newdat$End.date=="20/7/1988"] <- "07/20/1988"
#20/7/86
newdat$End.date[newdat$End.date=="20/7/86"] <- "07/20/1986"
#21/03/1968
newdat$End.date[newdat$End.date=="21/03/1968"] <- "03/21/1968"
#21/03/1980
newdat$End.date[newdat$End.date=="21/03/1980"] <- "03/21/1980"
#21/05/1955
newdat$End.date[newdat$End.date=="21/05/1955"] <- "05/21/1955"
#21/05/1958
newdat$End.date[newdat$End.date=="21/05/1958"] <- "05/21/1958"
#21/05/1959
newdat$End.date[newdat$End.date=="21/05/1959"] <- "05/21/1959"
#21/06/07
newdat$End.date[newdat$End.date=="21/06/07"] <- "06/21/1907"
#21/06/1961
newdat$End.date[newdat$End.date=="21/06/1961"] <- "06/21/1961"
#21/06/2016
newdat$End.date[newdat$End.date=="21/06/2016"] <- "06/21/2016"
#21/07/1950
newdat$End.date[newdat$End.date=="21/07/1950"] <- "07/21/1950"
#21/07/1953
newdat$End.date[newdat$End.date=="21/07/1953"] <- "07/21/1953"
#21/07/1970
newdat$End.date[newdat$End.date=="21/07/1970"] <- "07/21/1970"
#21/07/1972
newdat$End.date[newdat$End.date=="21/07/1972"] <- "07/21/1972"
#21/07/1984
newdat$End.date[newdat$End.date=="21/07/1984"] <- "07/21/1984"
#21/08/1969
newdat$End.date[newdat$End.date=="21/08/1969"] <- "08/21/1969"
#21/09/1973
newdat$End.date[newdat$End.date=="21/09/1973"] <- "09/21/1973"
#21/09/1975
newdat$End.date[newdat$End.date=="21/09/1975"] <- "09/21/1975"
#21/6/1890
newdat$End.date[newdat$End.date=="21/6/1890"] <- "06/21/1890"
#21/6/52
newdat$End.date[newdat$End.date=="21/6/52"] <- "06/21/1952"
#21/7/'52
newdat$End.date[newdat$End.date=="21/7/'52"] <- "07/21/1952"
#21/8/1978
newdat$End.date[newdat$End.date=="21/8/1978"] <- "08/21/1978"
#21/8/78
newdat$End.date[newdat$End.date=="21/8/78"] <- "08/21/1978"
#22/03/1947
newdat$End.date[newdat$End.date=="22/03/1947"] <- "03/22/1947"
#22/04/08
newdat$End.date[newdat$End.date=="22/04/08"] <- "04/22/1908"
#22/04/1878
newdat$End.date[newdat$End.date=="22/04/1878"] <- "04/22/1878"
#22/04/1947
newdat$End.date[newdat$End.date=="22/04/1947"] <- "04/22/1947"
#22/04/1978
newdat$End.date[newdat$End.date=="22/04/1978"] <- "04/22/1978"
#22/04/1982
newdat$End.date[newdat$End.date=="22/04/1982"] <- "04/22/1982"
#22/04/2016
newdat$End.date[newdat$End.date=="22/04/2016"] <- "04/22/2016"
#22/05/1960
newdat$End.date[newdat$End.date=="22/05/1960"] <- "05/22/1960"
#22/05/1967
newdat$End.date[newdat$End.date=="22/05/1967"] <- "05/22/1967"
#22/06/1961
newdat$End.date[newdat$End.date=="22/06/1961"] <- "06/22/1961"
#22/06/1977
newdat$End.date[newdat$End.date=="22/06/1977"] <- "06/22/1977"
#22/07/1950
newdat$End.date[newdat$End.date=="22/07/1950"] <- "06/22/1950"
#22/07/1953
newdat$End.date[newdat$End.date=="22/07/1953"] <- "07/22/1953"
#22/07/1969
newdat$End.date[newdat$End.date=="22/07/1969"] <- "07/22/1969"
#22/07/1970
newdat$End.date[newdat$End.date=="22/07/1970"] <- "07/22/1970"
#22/07/1984
newdat$End.date[newdat$End.date=="22/07/1984"] <- "07/22/1984"
#22/08/1969
newdat$End.date[newdat$End.date=="22/08/1969"] <- "08/22/1969"
#22/09/1952
newdat$End.date[newdat$End.date=="22/09/1952"] <- "09/22/1952"
#22/09/1963
newdat$End.date[newdat$End.date=="22/09/1963"] <- "09/22/1963"
#22/5/1913
newdat$End.date[newdat$End.date=="22/5/1913"] <- "05/22/1913"
#22/5/1958
newdat$End.date[newdat$End.date=="22/5/1958"] <- "05/22/1958"
#22/7/82
newdat$End.date[newdat$End.date=="22/7/82"] <- "07/22/1982"
#22/8/'84
newdat$End.date[newdat$End.date=="22/8/'84"] <- "08/22/1984"
#23/03/1980
newdat$End.date[newdat$End.date=="23/03/1980"] <- "03/23/1980"
#23/03/1986
newdat$End.date[newdat$End.date=="23/03/1986"] <- "03/23/1986"
#23/04/1894
newdat$End.date[newdat$End.date=="23/04/1894"] <- "04/23/1894"
#23/04/1947
newdat$End.date[newdat$End.date=="23/04/1947"] <- "04/23/1947"
#23/04/1994
newdat$End.date[newdat$End.date=="23/04/1994"] <- "04/23/1994"
#23/05/1959
newdat$End.date[newdat$End.date=="23/05/1959"] <- "05/23/1959"
#23/06/1958
newdat$End.date[newdat$End.date=="23/06/1958"] <- "06/23/1958"
#23/06/1961
newdat$End.date[newdat$End.date=="23/06/1961"] <- "06/23/1961"
#23/07/1969
newdat$End.date[newdat$End.date=="23/07/1969"] <- "07/23/1969"
#23/08/1966
newdat$End.date[newdat$End.date=="23/08/1966"] <- "08/23/1966"
#23/08/1969
newdat$End.date[newdat$End.date=="23/08/1969"] <- "08/23/1969"
#23/09/1963
newdat$End.date[newdat$End.date=="23/09/1963"] <- "09/23/1963"
#23/25/mei
newdat$End.date[newdat$End.date=="23/25/mei"] <- NA
#23/8/'78
newdat$End.date[newdat$End.date=="23/8/'78"] <- "08/23/1978"
#23/8/1978
newdat$End.date[newdat$End.date=="23/8/1978"] <- "08/23/1978"
#24/03/1980
newdat$End.date[newdat$End.date=="24/03/1980"] <- "03/24/1980"
#24/03/1986
newdat$End.date[newdat$End.date=="24/03/1986"] <- "03/24/1986"
#24/04/1982
newdat$End.date[newdat$End.date=="24/04/1982"] <- "04/24/1982"
#24/04/1993
newdat$End.date[newdat$End.date=="24/04/1982"] <- "04/24/1982"
#24/04/1994
newdat$End.date[newdat$End.date=="24/04/1994"] <- "04/24/1994"
#24/04/87
newdat$End.date[newdat$End.date=="24/04/87"] <- "04/24/1987"
#24/05/1950
newdat$End.date[newdat$End.date=="24/05/1950"] <- "05/24/1950"
#24/05/1953
newdat$End.date[newdat$End.date=="24/05/1953"] <- "05/24/1953"
#24/05/1960
newdat$End.date[newdat$End.date=="24/05/1960"] <- "05/24/1960"
#24/05/58
newdat$End.date[newdat$End.date=="24/05/1958"] <- "05/24/1958"
#24/06/1977
newdat$End.date[newdat$End.date=="24/06/1977"] <- "06/24/1977"
#24/07/1924
newdat$End.date[newdat$End.date=="24/07/1924"] <- "07/24/1924"
#24/07/1969
newdat$End.date[newdat$End.date=="24/07/1969"] <- "07/24/1969"
#24/07/1970
newdat$End.date[newdat$End.date=="24/07/1970"] <- "07/24/1970"
#24/08/18
newdat$End.date[newdat$End.date=="24/08/18"] <- "08/24/1918"
#24/08/1966
newdat$End.date[newdat$End.date=="24/08/1966"] <- "08/24/1966"
#24/08/1969
newdat$End.date[newdat$End.date=="24/08/1969"] <- "08/24/1969"
#24/09/1963
newdat$End.date[newdat$End.date=="24/09/1963"] <- "09/24/1963"
#24/5/1953
newdat$End.date[newdat$End.date=="24/5/1953"] <- "05/24/1953"
#24/7/1956
newdat$End.date[newdat$End.date=="24/7/1956"] <- "07/24/1956"
#24/Jun/81
newdat$End.date[newdat$End.date=="24/Jun/81"] <- "06/24/1981"
#25/03/1947
newdat$End.date[newdat$End.date=="25/03/1947"] <- "03/25/1947"
#25/03/1967
newdat$End.date[newdat$End.date=="25/03/1967"] <- "03/25/1967"
#25/03/1980
newdat$End.date[newdat$End.date=="25/03/1980"] <- "03/25/1980"
#25/03/1986
newdat$End.date[newdat$End.date=="25/03/1986"] <- "03/25/1986"
#25/04/1947
newdat$End.date[newdat$End.date=="25/04/1947"] <- "04/25/1947"
#25/04/1971
newdat$End.date[newdat$End.date=="25/04/1971"] <- "04/25/1971"
#25/05/2016
newdat$End.date[newdat$End.date=="25/04/2016"] <- "04/25/2016"
#25/06/1961
newdat$End.date[newdat$End.date=="25/06/1961"] <- "06/25/1961"
#25/07/1970
newdat$End.date[newdat$End.date=="25/07/1970"] <- "07/25/1970"
#25/07/1978
newdat$End.date[newdat$End.date=="25/07/1978"] <- "07/25/1978"
#25/08/1966
newdat$End.date[newdat$End.date=="25/08/1966"] <- "08/25/1966"
#25/4/78
newdat$End.date[newdat$End.date=="25/4/78"] <- "04/25/1978"
#25/5/1975
newdat$End.date[newdat$End.date=="25/5/1975"] <- "04/25/1975"
#25/5/1998
newdat$End.date[newdat$End.date=="25/5/1998"] <- "05/25/1998"
#26/03/1980
newdat$End.date[newdat$End.date=="26/03/1980"] <- "03/26/1980"
#26/03/1986
newdat$End.date[newdat$End.date=="26/03/1986"] <- "03/26/1986"
#26/03/87
newdat$End.date[newdat$End.date=="26/03/87"] <- "03/26/1987"
#26/05/1958
newdat$End.date[newdat$End.date=="26/05/1958"] <- "05/26/1958"
#26/05/1960
newdat$End.date[newdat$End.date=="26/05/1960"] <- "05/26/1960"
#26/06/1977
newdat$End.date[newdat$End.date=="26/06/1977"] <- "06/26/1977"
#26/08/1966
newdat$End.date[newdat$End.date=="26/08/1966"] <- "08/26/1966"
#26/08/1969
newdat$End.date[newdat$End.date=="26/08/1969"] <- "08/26/1969"
#26/08/84
newdat$End.date[newdat$End.date=="26/08/84"] <- "08/26/1984"
#26/09/1952
newdat$End.date[newdat$End.date=="26/09/1952"] <- "09/26/1952"
#26/09/1963
newdat$End.date[newdat$End.date=="26/09/1963"] <- "09/26/1963"
#26/09/1973
newdat$End.date[newdat$End.date=="26/09/1973"] <- "09/26/1973"
#26/5/1975
newdat$End.date[newdat$End.date=="26/5/1975"] <- "04/26/1975"
#26/8/''78
newdat$End.date[newdat$End.date=="26/8/''78"] <- "08/26/1978"
#27/04/1978
newdat$End.date[newdat$End.date=="27/04/1978"] <- "04/27/1978"
#27/04/1993
newdat$End.date[newdat$End.date=="27/04/1993"] <- "04/27/1993"
#27/05/1959
newdat$End.date[newdat$End.date=="27/05/1959"] <- "05/27/1959"
#27/05/1962
newdat$End.date[newdat$End.date=="27/05/1962"] <- "05/27/1962"
#27/06/1967
newdat$End.date[newdat$End.date=="27/06/1967"] <- "06/27/1967"
#27/07/1968
newdat$End.date[newdat$End.date=="27/07/1968"] <- "07/27/1968"
#27/07/1978
newdat$End.date[newdat$End.date=="27/07/1978"] <- "07/27/1978"
#27/07/1984
newdat$End.date[newdat$End.date=="27/07/1984"] <- "07/27/1984"
#27/08/1968
newdat$End.date[newdat$End.date=="27/08/1968"] <- "08/27/1968"
#27/09/1952
newdat$End.date[newdat$End.date=="27/09/1952"] <- "09/27/1952"
#27/5/1975
newdat$End.date[newdat$End.date=="27/5/1975"] <- "05/27/1975"

#27/8/1978
newdat$End.date[newdat$End.date=="27/8/1978"] <- "08/27/1978"
#28/03/1968
newdat$End.date[newdat$End.date=="28/03/1968"] <- "03/28/1968"
#28/03/1986
newdat$End.date[newdat$End.date=="28/03/1986"] <- "03/28/1986"
#28/04/08
newdat$End.date[newdat$End.date=="28/04/08"] <- "04/28/1908"
#28/05/1959
newdat$End.date[newdat$End.date=="28/05/1959"] <- "05/28/1959"
#28/05/1960
newdat$End.date[newdat$End.date=="28/05/1960"] <- "05/28/1960"
#28/07/1924
newdat$End.date[newdat$End.date=="28/07/1924"] <- "07/28/1924"
#28/07/1967
newdat$End.date[newdat$End.date=="28/07/1967"] <- "07/28/1967"
#28/07/1968
newdat$End.date[newdat$End.date=="28/07/1968"] <- "07/28/1968"
#28/07/1970
newdat$End.date[newdat$End.date=="28/07/1970"] <- "07/28/1970"
#28/07/1984
newdat$End.date[newdat$End.date=="28/07/1984"] <- "07/28/1984"
#28/07/24
newdat$End.date[newdat$End.date=="28/07/24"] <- "07/28/1924"
#28/08/1970
newdat$End.date[newdat$End.date=="28/08/1970"] <- "08/28/1970"
#28/5/1983
newdat$End.date[newdat$End.date=="28/5/1983"] <- "05/28/1983"
#28/7/1950
newdat$End.date[newdat$End.date=="28/7/1950"] <- "07/28/1950"
#28/8/'78
newdat$End.date[newdat$End.date=="28/8/'78"] <- "08/28/1978"
#28/8/1978
newdat$End.date[newdat$End.date=="28/8/1978"] <- "08/28/1978"
#28/8/48
newdat$End.date[newdat$End.date=="28/8/48"] <- "08/28/1948"
#29/04/1960
newdat$End.date[newdat$End.date=="29/04/1960"] <- "04/29/1960"
#29/04/1993
newdat$End.date[newdat$End.date=="29/04/1993"] <- "04/29/1993"
#29/04/2016
newdat$End.date[newdat$End.date=="29/04/2016"] <- "04/25/2016"
#29/05/1962
newdat$End.date[newdat$End.date=="29/05/1962"] <- "05/29/1962"
#29/05/1967
newdat$End.date[newdat$End.date=="29/05/1967"] <- "05/29/1967"
#29/05/1998
newdat$End.date[newdat$End.date=="29/05/1998"] <- "05/29/1998"
#29/06/1970
newdat$End.date[newdat$End.date=="29/06/1970"] <- "06/29/1970"
#29/07/1924
newdat$End.date[newdat$End.date=="29/07/1924"] <- "07/29/1924"
#29/07/1929
newdat$End.date[newdat$End.date=="29/07/1929"] <- "07/29/1929"
#29/07/1960
newdat$End.date[newdat$End.date=="29/07/1960"] <- "07/29/1960"
#29/07/1968
newdat$End.date[newdat$End.date=="29/07/1968"] <- "07/29/1968"
#29/07/1978
newdat$End.date[newdat$End.date=="29/07/1978"] <- "07/29/1978"
#29/07/29
newdat$End.date[newdat$End.date=="29/07/29"] <- "07/29/1929"
#29/08/33
newdat$End.date[newdat$End.date=="29/08/33"] <- "08/25/1933"
#29/7/1950
newdat$End.date[newdat$End.date=="29/7/1950"] <- "07/29/1950"
#Apr//1927
newdat$End.date[newdat$End.date=="Apr//1927"] <- NA
#Apr//1928
newdat$End.date[newdat$End.date=="Apr//1928"] <- NA
#Aug//25
newdat$End.date[newdat$End.date=="Aug//25"] <- NA
#Augt//25
newdat$End.date[newdat$End.date=="Augt//25"] <- NA
#ca,20/5/24
newdat$End.date[newdat$End.date=="ca,20/5/24"] <- NA
#febr//1923
newdat$End.date[newdat$End.date=="febr//1923"] <- NA
#I/07/'68
newdat$End.date[newdat$End.date=="I/07/'68"] <- NA
#IV//08
newdat$End.date[newdat$End.date=="IV//08"] <- NA
#Juli//25
newdat$End.date[newdat$End.date=="Juli//25"] <- NA
#V//02
newdat$End.date[newdat$End.date=="V//02"] <- NA
#V//04
newdat$End.date[newdat$End.date=="V//04"] <- NA
#13/05/1960
newdat$End.date[newdat$End.date=="13/05/1960"] <- "05/13/1960"
#13/06/1961
newdat$End.date[newdat$End.date=="13/06/1961"] <- "06/13/1961"
#13/08/1968
newdat$End.date[newdat$End.date=="13/08/1968"] <- "08/13/1968"
#13/08/1969
newdat$End.date[newdat$End.date=="13/08/1969"] <- "08/13/1969"
#13/09/1960
newdat$End.date[newdat$End.date=="13/09/1960"] <- "09/13/1960"
#13/3/1987
newdat$End.date[newdat$End.date=="13/3/1987"] <- "03/13/1987"
#13/6/1978
newdat$End.date[newdat$End.date=="13/6/1978"] <- "06/13/1978"
#14/03/1947
newdat$End.date[newdat$End.date=="14/03/1947"] <- "03/14/1947"
#14/04/1972
newdat$End.date[newdat$End.date=="14/04/1972"] <- "04/14/1972"
#14/04/1982
newdat$End.date[newdat$End.date=="14/04/1982"] <- "04/14/1982"
#14/05/1967
newdat$End.date[newdat$End.date=="14/05/1967"] <- "05/14/1967"
#14/06/1955
newdat$End.date[newdat$End.date=="14/06/1955"] <- "06/14/1955"
#14/06/1961
newdat$End.date[newdat$End.date=="14/06/1961"] <- "06/14/1961"
#14/06/1967
newdat$End.date[newdat$End.date=="14/06/1967"] <- "06/14/1967"
#14/07/1953
newdat$End.date[newdat$End.date=="14/07/1953"] <- "07/14/1953"
#14/07/1963
newdat$End.date[newdat$End.date=="14/07/1963"] <- "07/14/1963"
#14/08/1968
newdat$End.date[newdat$End.date=="14/08/1968"] <- "08/14/1968"
#14/10/1952
newdat$End.date[newdat$End.date=="14/10/1952"] <- "10/14/1952"
#14/5/1967
newdat$End.date[newdat$End.date=="14/5/1967"] <-  "05/14/1967"
#14/6/1981
newdat$End.date[newdat$End.date=="14/6/1981"] <- "06/14/1981"
#15/03/1986
newdat$End.date[newdat$End.date=="15/03/1986"] <- "03/15/1986"
#15/04/1982
newdat$End.date[newdat$End.date=="15/04/1982"] <- "04/15/1982"
#15/05/1967
newdat$End.date[newdat$End.date=="15/05/1967"] <- "05/15/1967"
#15/06/1961
newdat$End.date[newdat$End.date=="15/06/1961"] <- "06/15/1961"
#15/06/1969
newdat$End.date[newdat$End.date=="15/06/1969"] <- "06/15/1969"
#15/07/1953
newdat$End.date[newdat$End.date=="15/07/1953"] <- "07/15/1953"
#15/07/1970
newdat$End.date[newdat$End.date=="15/07/1970"] <- "07/15/1970"
#15/08/1968
newdat$End.date[newdat$End.date=="15/08/1968"] <- "08/15/1968"
#15/09/1952
newdat$End.date[newdat$End.date=="15/09/1952"] <- "09/15/1952"
#15/5/1967
newdat$End.date[newdat$End.date=="15/5/1967"] <- "05/15/1967"
#15/6/1978
newdat$End.date[newdat$End.date=="15/6/1978"] <- "06/15/1978"
#16/03/1986
newdat$End.date[newdat$End.date=="16/03/1986"] <- "03/16/1986"
#16/04/1978
newdat$End.date[newdat$End.date=="16/04/1978"] <- "04/16/1978"
#16/04/1982
newdat$End.date[newdat$End.date=="16/04/1982"] <- "04/16/1982"
#16/05/1958
newdat$End.date[newdat$End.date=="16/05/1958"] <- "05/16/1958"
#16/05/1959
newdat$End.date[newdat$End.date=="16/05/1959"] <- "05/16/1959"
#16/05/2016
newdat$End.date[newdat$End.date=="16/05/2016"] <- "05/16/2016"
#16/06/1961
newdat$End.date[newdat$End.date=="16/06/1961"] <- "06/16/2016"
#16/06/2016
newdat$End.date[newdat$End.date=="16/06/2016"] <- "06/16/2016"
#16/08/1969
newdat$End.date[newdat$End.date=="16/08/1969"] <- "08/16/1969"
#16/09/1952
newdat$End.date[newdat$End.date=="16/09/1952"] <- "09/16/1952"
#16/5/1958
newdat$End.date[newdat$End.date=="16/5/1958"] <- "05/16/1958"
#16/8/924
newdat$End.date[newdat$End.date=="16/8/924"] <- "08/16/1924"
#17/03/1947
newdat$End.date[newdat$End.date=="17/03/1947"] <- "03/17/1947"
#17/03/1980
newdat$End.date[newdat$End.date=="17/03/1980"] <- "03/17/1980"
#17/03/1986
newdat$End.date[newdat$End.date=="17/03/1986"] <- "03/17/1986"
#17/04/1978
newdat$End.date[newdat$End.date=="17/04/1978"] <- "04/17/1978"
#17/04/1982
newdat$End.date[newdat$End.date=="17/04/1982"] <- "04/17/1982"
#17/04/1983
newdat$End.date[newdat$End.date=="17/04/1983"] <- "04/17/1983"
#17/05/1958
newdat$End.date[newdat$End.date=="17/05/1958"] <- "05/17/1958"
#17/05/1960
newdat$End.date[newdat$End.date=="17/05/1960"] <- "05/17/1960"
#17/05/1969
newdat$End.date[newdat$End.date=="17/05/1969"] <- "05/17/1969"
#17/06/1961
newdat$End.date[newdat$End.date=="17/06/1961"] <-  "06/17/1961"
#17/06/1983
newdat$End.date[newdat$End.date=="17/06/1983"] <- "06/17/1983"
#17/06/2016
newdat$End.date[newdat$End.date=="17/06/2016"] <- "06/17/2016"
#17/07/1970
newdat$End.date[newdat$End.date=="17/07/1970"] <- "07/17/1970"
#17/08/1968
newdat$End.date[newdat$End.date=="17/08/1968"] <- "08/17/1968"
#17/08/1969
newdat$End.date[newdat$End.date=="17/08/1969"] <- "08/17/1969"
#17/09/1963
newdat$End.date[newdat$End.date=="17/09/1963"] <- "09/17/1963"
#17/09/1973
newdat$End.date[newdat$End.date=="17/09/1973"] <- "09/17/1973"
#17/5/1958
newdat$End.date[newdat$End.date=="17/5/1958"] <- "05/17/1958"
#18/03/1968
newdat$End.date[newdat$End.date=="18/03/1968"] <- "03/18/1968"
#18/03/1980
newdat$End.date[newdat$End.date=="18/03/1980"] <- "03/18/1980"
#18/03/1986
newdat$End.date[newdat$End.date=="18/03/1986"] <- "03/18/1986"
#18/04/1983
newdat$End.date[newdat$End.date=="18/04/1983"] <- "04/18/1983"
#18/04/1984
newdat$End.date[newdat$End.date=="18/04/1984"] <- "04/18/1984"
#18/05/1958
newdat$End.date[newdat$End.date=="18/05/1958"] <- "05/18/1958"
#18/06/1955
newdat$End.date[newdat$End.date=="18/06/1955"] <- "06/18/1955"
#18/07/1950
newdat$End.date[newdat$End.date=="18/07/1950"] <- "07/18/1950"
#18/09/1963
newdat$End.date[newdat$End.date=="18/09/1963"] <- "09/18/1963"
#18/10/1952
newdat$End.date[newdat$End.date=="18/10/1952"] <- "10/18/1952"
#18/10/1987
newdat$End.date[newdat$End.date=="18/10/1987"] <- "10/18/1987"
#18/5/1958
newdat$End.date[newdat$End.date=="18/5/1958"] <- "05/18/1958"
#18/7/1950
newdat$End.date[newdat$End.date=="18/7/1950"] <- "07/18/1950"
#19/03/1947
newdat$End.date[newdat$End.date=="19/03/1947"] <- "03/19/1947"
#19/03/1980
newdat$End.date[newdat$End.date=="19/03/1980"] <- "03/19/1980"
#19/03/1986
newdat$End.date[newdat$End.date=="19/03/1986"] <- "03/19/1986"
#19/03/1995
newdat$End.date[newdat$End.date=="19/03/1995"] <-  "03/19/1995"
#19/05/1967
newdat$End.date[newdat$End.date=="19/05/1967"] <- "05/19/1967"
#19/05/2016
newdat$End.date[newdat$End.date=="19/05/2016"] <- "05/19/2016"
#19/06/1970
newdat$End.date[newdat$End.date=="19/06/1970"] <- "06/19/1970"
#19/06/1975
newdat$End.date[newdat$End.date=="19/06/1975"] <- "06/19/1975"
#19/07/1970
newdat$End.date[newdat$End.date=="19/07/1970"] <- "07/19/1970"
#19/07/1978
newdat$End.date[newdat$End.date=="19/07/1978"] <- "07/19/1978"
#19/08/1996
newdat$End.date[newdat$End.date=="19/08/1996"] <- "08/19/1996"
#19/09/1963
newdat$End.date[newdat$End.date=="19/09/1963"] <- "08/19/1963"
#19/09/1975
newdat$End.date[newdat$End.date=="19/09/1975"] <- "08/19/1975"
#19/10/924
newdat$End.date[newdat$End.date=="19/10/924"] <- "10/19/1924"
#19/6/1973
newdat$End.date[newdat$End.date=="19/6/1973"] <- "06/19/1973"
#19/8/1949
newdat$End.date[newdat$End.date=="19/8/1949"] <- "08/19/1949"
#18/07/1953
newdat$End.date[newdat$End.date=="18/07/1953"] <- "07/18/1953"
#18/08/1968
newdat$End.date[newdat$End.date=="18/08/1968"] <- "08/18/1968"
#18/09/1952
newdat$End.date[newdat$End.date=="18/09/1952"] <- "09/18/1952"
#18/6/1978
newdat$End.date[newdat$End.date=="18/6/1978"] <- "06/18/1978"
#20/04/1994
newdat$End.date[newdat$End.date=="20/04/1994"] <- "04/20/1994"
#24/04/1993
newdat$End.date[newdat$End.date=="24/04/1993"] <- "04/24/1993"
#24/05/58
newdat$End.date[newdat$End.date=="24/05/58"] <- "05/24/1958"
#24/07/924
newdat$End.date[newdat$End.date=="24/07/924"] <- "07/24/1924"
#25/05/2016
newdat$End.date[newdat$End.date=="25/05/2016"] <- "05/25/2016"
#29/07/924
newdat$End.date[newdat$End.date=="29/07/924"] <- "07/29/1924"
#3/04/70
newdat$End.date[newdat$End.date=="3/04/70"] <- "03/04/1970"
#3/05/58
newdat$End.date[newdat$End.date=="3/05/58"] <- "03/05/1958"
#30/04/1993
newdat$End.date[newdat$End.date=="30/04/1993"] <- "04/30/1993"
#30/05/1959
newdat$End.date[newdat$End.date=="30/05/1959"] <- "05/30/1959"
#30/05/1962
newdat$End.date[newdat$End.date=="30/05/1962"] <- "05/30/1962"
#30/05/1967
newdat$End.date[newdat$End.date=="30/05/1967"] <- "05/30/1967"
#30/06/1969
newdat$End.date[newdat$End.date=="30/06/1969"] <- "06/30/1969"
#30/06/1970
newdat$End.date[newdat$End.date=="30/06/1970"] <- "06/30/1970"
#30/06/1977
newdat$End.date[newdat$End.date=="30/06/1977"] <- "06/30/1977"
#30/07/1960
newdat$End.date[newdat$End.date=="30/07/1960"] <- "07/30/1960"
#30/07/1968
newdat$End.date[newdat$End.date=="30/07/1968"] <- "07/30/1968"
#30/07/1969
newdat$End.date[newdat$End.date=="30/07/1969"] <- "07/30/1969"
#30/07/1970
newdat$End.date[newdat$End.date=="30/07/1970"] <- "07/30/1970"
#30/08/1969
newdat$End.date[newdat$End.date=="30/08/1969"] <- "08/30/1969"
#30/6/90
newdat$End.date[newdat$End.date=="30/6/90"] <- "06/30/1990"
#30/8/1972
newdat$End.date[newdat$End.date=="30/8/1972"] <- "08/30/1972"
#31/05/1955
newdat$End.date[newdat$End.date=="31/05/1955"] <- "05/31/1955"
#31/05/2016
newdat$End.date[newdat$End.date=="31/05/2016"] <- "05/31/2016"
#31/05/2016
newdat$End.date[newdat$End.date=="31/05/2016"] <- "05/31/2016"
#31/07/1968
newdat$End.date[newdat$End.date=="31/07/1968"] <- "07/31/1968"
#31/07/1970
newdat$End.date[newdat$End.date=="31/07/1970"] <- "07/31/1970"
#31/08/1969
newdat$End.date[newdat$End.date=="31/08/1969"] <- "08/31/1969"
#31/09/2013
newdat$End.date[newdat$End.date=="31/09/2013"] <- "09/31/2013"
#31/12/1896
newdat$End.date[newdat$End.date=="31/12/1896"] <- "12/31/1896"
#31/12/1904
newdat$End.date[newdat$End.date=="31/12/1904"] <- "12/31/1904"
#31/21/1959
newdat$End.date[newdat$End.date=="31/21/1959"] <- "12/31/1959"
#31/21/1992
newdat$End.date[newdat$End.date=="31/21/1992"] <- "12/31/1992"
#5/24/
newdat$End.date[newdat$End.date=="5/24/"] <- NA

#Delete dates with more than 2 or less forward slashes 
is.na(newdat$End.date) <- nchar(newdat$End.date) - nchar(gsub("/", "", newdat$End.date, fixed = TRUE)) > 2
is.na(newdat$End.date) <- nchar(newdat$End.date) - nchar(gsub("/", "", newdat$End.date, fixed = TRUE)) < 2

#newdat$End.date <- gsub("924", "1924", newdat$End.date,fixed = TRUE)
#newdat$End.date <- gsub("11924", "1924", newdat$End.date,fixed = TRUE)

#leading zeros and without zeros
newdat$End.date <- anydate(newdat$End.date)
#Now is in YEAR/MONTH/DAY
#Convert to standard format of the database
newdat$End.date <- as.Date(newdat$End.date,format = "%y/%d/%m")
newdat$End.date<- format(newdat$End.date, "%d/%m/%Y")
#d <- as.data.frame(levels(factor(newdat$End.date))) #check levels

#Now looks much better!

#Check next column
#Collector
newdat$Collector[newdat$Collector=="-1082328577"] <- NA
newdat$Collector[newdat$Collector=="-1510526472"] <- NA
newdat$Collector[newdat$Collector=="-1692779921"] <- NA
newdat$Collector[newdat$Collector=="-2075801121"] <- NA
newdat$Collector[newdat$Collector=="-264761682"] <- NA
newdat$Collector[newdat$Collector=="@@"] <- NA
newdat$Collector[newdat$Collector=="1139381203"] <- NA
newdat$Collector[newdat$Collector=="1159555953"] <- NA
newdat$Collector[newdat$Collector=="1315648783"] <- NA
newdat$Collector[newdat$Collector=="1647598034"] <- NA
newdat$Collector[newdat$Collector=="341725260"] <- NA
newdat$Collector[newdat$Collector=="531632058"] <- NA
newdat$Collector[newdat$Collector=="881932368"] <- NA
newdat$Collector[newdat$Collector==""] <- NA

#Add space after dot
newdat$Collector <- gsub("\\.(?=[A-Za-z])", ". ", newdat$Collector, perl = TRUE)
#String to title
newdat$Collector <- stringr::str_to_title(newdat$Collector)
#Remove numbers from string
newdat$Collector <- gsub('[0-9]+', '', newdat$Collector)
#delete leading trailing space
newdat$Collector <- trimws(newdat$Collector, which = c("both"), whitespace = "[ \t\r\n]")
#change separator
newdat$Collector <- gsub(" &", ",", newdat$Collector)

#Fix just big typos
newdat$Collector[newdat$Collector=="Agull?? Villaronga,"] <- "Agustí Villalonga"
newdat$Collector[grepl("Bã", newdat$Collector, ignore.case=FALSE)] <- "Bür Blote De Jong De Osse"
newdat$Collector[newdat$Collector=="C. A. W. Jeek@"] <- "C. A. W. Jeekel"
newdat$Collector[newdat$Collector=="C. V. Achterberg Rmnh '"] <- "C. V. Achterberg"
newdat$Collector[newdat$Collector=="Equip Gesti?? Artr??"] <- "Equipo Gestión Artrópodos"
newdat$Collector[newdat$Collector=="Equip Gesti?? Artr??"] <- "Equipo Gestión Artrópodos"
newdat$Collector[newdat$Collector=="Escol?Á Boada, Olegu"] <- "Escolá Boada, Olegu"
newdat$Collector[newdat$Collector=="Gonz?Ílez, I."] <- "González, I."
newdat$Collector[newdat$Collector=="Gonz?Ílez, I."] <- "González, I."
newdat$Collector[newdat$Collector=="S. Bogya, I. Sebesyã©N"] <- "S. Bogya, I. Sebesyén"
newdat$Collector[newdat$Collector=="Puerto [?]"] <- "Puerto"
newdat$Collector[newdat$Collector=="P"] <- NA
newdat$Collector[newdat$Collector=="K."] <- NA
newdat$Collector[newdat$Collector=="J. Briedã©"] <- "J. Briedé"
#d <- as.data.frame(levels(factor(newdat$Collector))) #check levels



#Now Determined.by col
newdat$Determined.by[newdat$Determined.by==""] <- NA

newdat$Determined.by <- gsub("Det. ", "", newdat$Determined.by)
newdat$Determined.by <- gsub("Det ", "", newdat$Determined.by)
newdat$Determined.by <- gsub("Det.", "", newdat$Determined.by)
newdat$Determined.by <- gsub("Det.", "", newdat$Determined.by)
newdat$Determined.by[newdat$Determined.by=="@"] <- NA

#Add space after dot
newdat$Determined.by <- gsub("\\.(?=[A-Za-z])", ". ", newdat$Determined.by, perl = TRUE)
#String to title
newdat$Determined.by <- stringr::str_to_title(newdat$Determined.by)
#Remove numbers from string
newdat$Determined.by <- gsub('[0-9]+', '', newdat$Determined.by)
#delete leading trailing space
newdat$Determined.by <- trimws(newdat$Determined.by, which = c("both"), whitespace = "[ \t\r\n]")
#change formard slash by comma and space
newdat$Determined.by <- gsub("/", ", ", newdat$Determined.by)

#Fix some big errors
newdat$Determined.by[newdat$Determined.by=="Blã¼Thgen"] <- "Blüthgen P"
newdat$Determined.by[newdat$Determined.by=="Blã¼Thgen Det."] <- "Blüthgen P"
newdat$Determined.by[newdat$Determined.by=="G. Mas??"] <- "G. Mas"
newdat$Determined.by[newdat$Determined.by=="K.-H. K.-H. Schwammberger"] <- "K. H. Schwammberger"
newdat$Determined.by[newdat$Determined.by=="K.-H. Schwammberger"] <- "K. H. Schwammberger"
newdat$Determined.by[newdat$Determined.by=="K.-H. Schwammberger"] <- "K. H. Schwammberger"
newdat$Determined.by[newdat$Determined.by=="Pã©Rã©Z"] <- "Pérez"
#d <- as.data.frame(levels(factor(newdat$Determined.by))) #check levels
#it looks better now


#Check male/female cols
#LOOK AT IT!

#Check Reference.doi
newdat$Reference.doi[newdat$Reference.doi==""] <- NA
newdat$Reference.doi[newdat$Reference.doi==" "] <- NA
newdat$Reference.doi[newdat$Reference.doi=="Ceballos & &Al (1956)"] <- "Ceballos & Al 1956"
newdat$Reference.doi[newdat$Reference.doi=="Ceballos & Al (1956)"] <- "Ceballos & Al 1956"
newdat$Reference.doi[newdat$Reference.doi=="Erlndsson (1979)"] <- "Erlandsson 1979"
#String to title
newdat$Reference.doi <- stringr::str_to_title(newdat$Reference.doi)
#Delete parenthesis
newdat$Reference.doi <- gsub("(", "", newdat$Reference.doi, fixed=TRUE)
newdat$Reference.doi <- gsub(")", "", newdat$Reference.doi, fixed=TRUE)
#d <- as.data.frame(levels(factor(newdat$Reference.doi))) #check levels
#it looks decent now

#Now flowers_visited col
newdat$Flowers.visited[newdat$Flowers.visited==""] <- NA
newdat$Flowers.visited[newdat$Flowers.visited=="(dennenbos)"] <- "Dennenbos"
newdat$Flowers.visited[newdat$Flowers.visited=="(weitjes)"] <- "Weitjes"
newdat$Flowers.visited[newdat$Flowers.visited=="1000 m., op Lavandula stoechas"] <- "Lavandula stoechas"
newdat$Flowers.visited[newdat$Flowers.visited=="1600 m., on Echium"] <- "Echium sp."
newdat$Flowers.visited[grepl("Galactites to", newdat$Flowers.visited, ignore.case=FALSE)] <- "Galactites tomentosa"
newdat$Flowers.visited[newdat$Flowers.visited=="725 m, Scabiosa maritima L."] <- "Scabiosa maritima"
newdat$Flowers.visited[newdat$Flowers.visited=="725 m, Scrophularia auriculata L."] <- "Scrophularia auriculata"
newdat$Flowers.visited[newdat$Flowers.visited=="900 m, Echium"] <- "Echium"
newdat$Flowers.visited[newdat$Flowers.visited=="ca 500 m"] <- NA
newdat$Flowers.visited[newdat$Flowers.visited=="ca. 800 M"] <- NA
newdat$Flowers.visited[newdat$Flowers.visited=="ca. 800 m."] <- NA
newdat$Flowers.visited <- gsub("on ", "", newdat$Flowers.visited, fixed=TRUE)
newdat$Flowers.visited[newdat$Flowers.visited=="1600 m., Echium"] <-"Echium sp."
newdat$Flowers.visited[newdat$Flowers.visited=="600 m, Rubus"] <-"Rubus sp."
newdat$Flowers.visited[newdat$Flowers.visited=="600 m, Rubus"] <-"Rubus sp."
newdat$Flowers.visited[newdat$Flowers.visited=="725 m, Rubus"] <-"Rubus sp."
newdat$Flowers.visited[newdat$Flowers.visited=="Echium no. 78"] <-"Echium sp."
newdat$Flowers.visited[grepl("Lotus uligin", newdat$Flowers.visited, ignore.case=FALSE)] <- "Lotus uliginosus"
newdat$Flowers.visited <- gsub("op ", "", newdat$Flowers.visited, fixed=TRUE)
newdat$Flowers.visited[grepl("Tolpis ba", newdat$Flowers.visited, ignore.case=FALSE)] <- "Tolpis barbata"
newdat$Flowers.visited[grepl("Thymus ma", newdat$Flowers.visited, ignore.case=FALSE)] <- "Thymus mastichina"
newdat$Flowers.visited[grepl("1", newdat$Flowers.visited, ignore.case=FALSE)] <- NA
newdat$Flowers.visited[grepl("00", newdat$Flowers.visited, ignore.case=FALSE)] <- NA
newdat$Flowers.visited[grepl("2", newdat$Flowers.visited, ignore.case=FALSE)] <- NA
newdat$Flowers.visited <- stringr::str_to_sentence(newdat$Flowers.visited)
#d <- as.data.frame(levels(factor(newdat$Flowers.visited))) #check levels
#Now it looks better could be a bit more edited

#Convert space to NA in Local_Id
newdat$Local_ID[newdat$Local_ID==""] <- NA

#Convert space to NA in Any.other.additional.data
newdat$Any.other.additional.data[newdat$Any.other.additional.data==""] <- NA
newdat$Any.other.additional.data[newdat$Any.other.additional.data==" "] <- NA
#Convert first element of the string to cap letter
newdat$Any.other.additional.data <- str_to_title(newdat$Any.other.additional.data)

#Notes.and.queries, semicolon here is a big issue, fix it
newdat$Notes.and.queries <- gsub( ";", "", as.character(newdat$Notes.and.queries))
#Semicolon is out, now delete leading and trailing spaces
newdat$Notes.and.queries <- trimws(newdat$Notes.and.queries)
#Convert space to NA
newdat$Notes.and.queries[newdat$Notes.and.queries==""] <- NA
#More work can be done but seems ok 

#Convert space to NA in Any.other.additional.data
df <- as.data.frame(unique(levels(factor(newdat$Species))))

#Fix special characters that give issues when merging all
newdat$Subspecies[newdat$Subspecies=="dest.\""] <- NA
newdat$Subspecies[newdat$Subspecies=="L.\""] <- NA
newdat$Locality[newdat$Locality=="Panticosa, 42â°43' 30\"N 2 38 30 W of Paris"] <- "Panticosa"
newdat$Any.other.additional.data[newdat$Any.other.additional.data=="Flying Over \"Humilis\" Holes"] <- "Flying Over Humilis Holes"

#Fix species names
newdat$Species[newdat$Species=="schultessi"] <- "schulthessii" #Source https://www.discoverlife.org/
newdat$Species[newdat$Species=="schultessii"] <- "schulthessii" #Source https://www.discoverlife.org/
#Filter non bee species
newdat <- newdat %>% filter(!Species=="bellidifolium")

#add finally uid
newdat$uid <- paste("54_Wood_etal_", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/54_Wood_etal.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 1_Ornosa_etal ----

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/1_Ornosa_etal.csv', sep = ";")
head(newdat)
#Compare vars
compare_variables(check, newdat)
#Fix dates
temp <- extract_date(newdat$Date, format_ = "%d-%m-%Y")
newdat$Day <- temp$day
newdat$Month <- temp$month
newdat$Year <- temp$year
newdat$Year <- ifelse(temp$date_var == "00-00-2011", 2011, newdat$Year)
newdat$Year <- ifelse(temp$date_var == "00-00-2010", 2010, newdat$Year)
newdat$Year <- ifelse(temp$date_var == "00-00-2012", 2012, newdat$Year)
#We can recover some dates are imposible e.g. 31 november.

#Fix genus 
newdat$Genus <- newdat$ï..Genus

#Add "1" in Not.specified where all Female, Male, Not.specified are NAs.
newdat$Not.specified <- ifelse((newdat$Female == 0 & newdat$Male == 0),1,0)

#add missing variables
newdat <- add_missing_variables(check, newdat)

#Remove row with all NA's (just one) Has a 0 in the female column
#so cannot delete it easily by row
newdat <- newdat[-59,] #not elegant but is the easiest
#add identifier
#Add unique identifier
newdat$uid <- paste("1_Ornosa_etal", 1:nrow(newdat), sep = "_")
newdat$Authors.to.give.credit <- "C. Ornosa"

#Fix provinces and localities localities
newdat$Province <- stri_encode(newdat$Province, from = "UTF-8", to = "UTF-8")
unique(newdat$Province)
#Add two missing provinces
library(stringi)
newdat$Locality <- stri_encode(newdat$Locality, from = "UTF-8", to = "UTF-8")
unique(newdat$Locality)
newdat$Province[newdat$Locality==
                  "Jaén. Sierra de Cazorla. Nacimiento del Guadalquivir"] <-"Jaén"
newdat$Province[newdat$Locality==
                  "Imlil"] <-"Al Haouz"


#Rename this cell to just the locality
newdat$Locality <- gsub("JaÃ©n. Sierra de Cazorla. Nacimiento del Guadalquivir", 
                        "Sierra de Cazorla. Nacimiento del Guadalquivir", newdat$Locality)

#Rewrite countries in English
levels(factor(newdat$Country))
newdat$Country <- gsub("EspaÃ±a", 
                       "Spain", newdat$Country, fixed=T)
newdat$Country <- gsub("Marruecos", 
                       "Morocco", newdat$Country, fixed=T)

#Fix collect. names. 
levels(factor(newdat$Collector)) 
# IML to IM Liberal
newdat$Collector <- gsub("IML", 
                         "I.M. Liberal", newdat$Collector)
#JL Blanco to J.L. Blanco
newdat$Collector <- gsub("JL Blanco", 
                         "J.L. Blanco", newdat$Collector)
#P Vargas to P. Vargas
newdat$Collector <- gsub("P Vargas", 
                         "P. Vargas", newdat$Collector)

#Fix identificator names. 
levels(factor(newdat$Determined.by))
#Replace front slash by a comma and a space
newdat$Determined.by <- gsub("JL Blanco/C. Ornosa", 
                             "JL Blanco, C. Ornosa", newdat$Determined.by)
newdat$Determined.by <- gsub("C. Onosa", 
                             "C. Ornosa", newdat$Determined.by)
#Fix species name
newdat$Species[newdat$Species=="pacuorum"] <- "pascuorum"
#Fix blanck space
newdat$Species <- trimws(newdat$Species)

unique(newdat$Species)

#drop variables
newdat <- drop_variables(check, newdat)


#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/1_Ornosa_etal.csv', quote = TRUE, sep = ',', 
            col.names = TRUE, row.names = FALSE)
View(newdat)

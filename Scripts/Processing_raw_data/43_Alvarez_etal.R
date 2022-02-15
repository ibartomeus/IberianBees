source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 43_Alvarez_etal  ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/43_Alvarez_etal.csv', sep = ";")

#Check vars
compare_variables(check, newdat)
newdat$Local_ID <- paste(newdat$Id, newdat$CodigoColeccion, newdat$nNoCatalogo, sep = "_")
#unique(newdat$UTM) #poca cosa
unique(newdat$Sex) #miedito el descontrol que hay
newdat$Female <- ifelse(newdat$Sex %in% c("hembra", "Hembra"), 1, 0)
newdat$Male <- ifelse(newdat$Sex %in% c("macho", "Macho"), 1, 0)
newdat$Worker <- ifelse(newdat$Sex %in% c("obrera"), 1, 0)
newdat$Not.specified <- ifelse(!newdat$Sex %in% c("obrera", "macho", "Macho", "hembra", "Hembra"), 1, 0)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat) 
unique(newdat$Month) 

#Rename country
newdat$Country <- gsub("España", "Spain", newdat$Country)
#Fill quickly provinces
#na_check <- newdat[is.na(newdat$Province),]
newdat$Province[newdat$Locality=="Sierra de Guadarrama"] <- "Madrid"
newdat$Province[newdat$Locality=="Sierra de Guadarram"] <- "Madrid"
newdat$Province[newdat$Locality=="Alberche"] <- "Ávila"
newdat$Province[newdat$Locality=="Sierra Nevada"] <- "Granada"

#Fix some dates
newdat$Year <- gsub("129i", "1921", newdat$Year)
newdat$Year <- gsub("192i[sic]", "1921", newdat$Year, fixed = T)
newdat$Year <- gsub("1279[sic]", "1927", newdat$Year, fixed = T)

#Add leading 0 to month
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Unify some collector names
levels(factor(newdat$Collector))
newdat$Collector <- gsub("\\[", "", newdat$Collector)
newdat$Collector <- gsub("\\]", "", newdat$Collector)
newdat$Collector <- gsub("A. H. Hamm.", "A.H. Hamm", newdat$Collector)
newdat$Collector <- gsub("A.H. Hamm.", "A.H. Hamm", newdat$Collector)
newdat$Collector <- gsub("A. H. Hamm", "A.H. Hamm", newdat$Collector)
newdat$Collector <- gsub("Á. Schmidt", "A. Schmidt", newdat$Collector)
newdat$Collector <- sub("C. Bol.", "C. Bolívar", newdat$Collector, ignore.case = TRUE)
newdat$Collector <- sub("C. Bolívarvar", "C. Bolívar", newdat$Collector, ignore.case = TRUE)
newdat$Collector <- sub("Bolivar", "C. Bolívar", newdat$Collector, ignore.case = TRUE)
newdat$Collector <- sub("Bolívar", "C. Bolívar", newdat$Collector, ignore.case = TRUE)
newdat$Collector <- sub("C. C. Bolívar", "C. Bolívar", newdat$Collector, ignore.case = TRUE)
newdat$Collector <- sub("AntiAntiga", "Antiga", newdat$Collector, ignore.case = TRUE)
newdat$Collector <- sub("Andreu", "Andréu", newdat$Collector, ignore.case = TRUE)
newdat$Collector <- sub("Nieves&Rey", "Nieves & Rey", newdat$Collector, ignore.case = TRUE)

#Messy but works
newdat$Collector <- gsub("Antiga d? J. Pérez", "Antiga d. J. Pérez", newdat$Collector, fixed=T)
newdat$Collector <- gsub("Antiga d. J. Perez", "Antiga d. J. Pérez", newdat$Collector, fixed=T)
newdat$Collector <- gsub("Antiga dº J. Perez", "Antiga d. J. Pérez", newdat$Collector, fixed=T)
newdat$Collector <- gsub("Antiga do J. Pérez", "Antiga d. J. Pérez", newdat$Collector, fixed=T)
newdat$Collector <- gsub("Antiga d. Pérez", "Antiga d. J. Pérez", newdat$Collector, fixed=T)
newdat$Collector <- gsub("Antiga Pérez d.", "Antiga d. J. Pérez", newdat$Collector, fixed=T)
newdat$Collector[grepl("Exp. De", newdat$Collector, ignore.case=FALSE)] <- "Exp. del Museo"
newdat$Collector <- gsub("Exp. Museo", "Exp. del Museo", newdat$Collector, fixed=T)
newdat$Collector[grepl("Exp. Ins", newdat$Collector, ignore.case=FALSE)] <- "Exp. Inst. de Entomología"
newdat$Collector[grepl("Exp. Ins", newdat$Collector, ignore.case=FALSE)] <- "Exp. Inst. de Entomología"
newdat$Collector <- gsub("Fermin Z. Cervera", "Fermín Z. Cervera", newdat$Collector, fixed=T)
newdat$Collector <- gsub("F. Escalera", "F.M. Escalera", newdat$Collector, fixed=T)
newdat$Collector <- gsub("F. M. Escalera", "F.M. Escalera", newdat$Collector, fixed=T)
newdat$Collector <- gsub("F. M.Escalera", "F.M. Escalera", newdat$Collector, fixed=T)
newdat$Collector[grepl("Giner", newdat$Collector, ignore.case=FALSE)] <- "Giner Marí"
newdat$Collector <- gsub("Gª. Varela", "G. Varela", newdat$Collector, fixed=T)
newdat$Collector <- gsub("Gª Mercet", "G. Mercet", newdat$Collector, fixed=T)
newdat$Collector <- gsub(". Alvarez", "J. Álvarez", newdat$Collector, fixed=T)
newdat$Collector <- gsub("J. Mª de la Fuente", "J. M. de la Fuente", newdat$Collector, fixed=T)
newdat$Collector <- gsub("JJ. Álvarez", "J. Álvarez", newdat$Collector, fixed=T)
newdat$Collector <- gsub("R. P. L Navás", "R.P.L. Navás", newdat$Collector, fixed=T)
newdat$Collector <- gsub("R.P.L. Navas", "R.P.L. Navás", newdat$Collector, fixed=T)
newdat$Collector <- gsub("F. Z. Cervera", "F.Z. Cervera", newdat$Collector, fixed=T)
newdat$Collector <- gsub("H. H. Hamm.", "H.H. Hamm", newdat$Collector)
newdat$Collector <- gsub("J. B. de Quiros", "J.B. de Quiros", newdat$Collector)
newdat$Collector <- gsub("J. M. Benedito", "J.M. Benedito", newdat$Collector)
newdat$Collector <- gsub("J. M. de la Fuente", "J.M. de la Fuente", newdat$Collector)
newdat$Collector <- gsub("J. M. Dusmet", "J.M. Dusmet", newdat$Collector)

#A bit cleaner now
newdat$Determined.by <- gsub("\\[", "", newdat$Determined.by)
newdat$Determined.by <- gsub("\\]", "", newdat$Determined.by)

#Now determined by. column
levels(factor(newdat$Determined.by))
newdat$Determined.by <- gsub("C. Oenosa",  "C. Ornosa", newdat$Determined.by)
newdat$Determined.by <- gsub("C. ornosa",  "C. Ornosa", newdat$Determined.by)
newdat$Determined.by <- gsub("Luís Oscar Aguado",  "L.O. Aguado", newdat$Determined.by)
newdat$Determined.by <- gsub("Luís Oscar Aguado",  "L.O. Aguado", newdat$Determined.by)
newdat$Determined.by <- gsub("F. J. Ortíz",  "F. J. Ortiz Sánchez", newdat$Determined.by)
newdat$Determined.by <- gsub("F. J. Ortiz Sánchez",  "F.J. Ortiz Sánchez", newdat$Determined.by)
newdat$Determined.by <- gsub("H. H. Dathe",  "H.H. Dathe", newdat$Determined.by)

#Work on dates (e.g.,months>12)
newdat$Month[newdat$Start.date=="13-08-1944"] <- "08"
newdat$Month[newdat$Start.date=="13-07-1985"] <- "07"
newdat$Month[newdat$Month=="18"] <- "07"

newdat$Authors.to.give.credit <- "P. Alvarez, M. Paris"

#Add unique identifier
newdat <- add_uid(newdat = newdat, '43_Alvarez_etal_')

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/43_Alvarez_etal.csv', 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

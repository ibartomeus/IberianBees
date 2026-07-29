library(here)
library(readxl)
library(dplyr)

data <- read.csv(here("Data/Rawdata/csvs/92_Nuñez_Carvajal_Galicia_2026.csv"), sep = ";")

#fix sexes

#Add "1" in Not.specified where all Female, Male, Not.specified are NAs.
data$Not.specified <- ifelse((data$Female == 0 & data$Male == 0),1,0)


#fix collector and determined by 

unique(data$Collector)

data <- data %>%
  mutate(
    Collector = recode(Collector, 
                     "DBT,YJR" = "Diego Benito Teno, Yamil Jimenez Rodríguez", 
                     "MSG" = "Maria Jose Servia Garcia", 
                     "MDB, SBP" = "Monica Doblas Bajo, Saul Bernat Ponce", 
                     "MDB, CFA" = "Monica Doblas Bajo, Carlos Fernandez Alvarez", 
                     "LPN, MDB" = "Luis de Pedro Noriega, Monica Doblas Bajo", 
                     "YRL, MSG" = "Yamil Jimenez Rodríguez, Maria Jose Servia Garcia", 
                     "YRL, LTB" = "Yamil Jimenez Rodríguez, Laura Torrado Blanco", 
                     "GMC, SBP" = "Guillermo Mora Collado, Saul Bernat Ponce", 
                     "MCV, EPT, SRP" = "Manuel Cernadas Villar, Elia Pérez Taboada, Sonia Ramos Pena",
                     "IJF, PAF" = "Ines Jimenez Fernandez, Piluca Alvarez Fidalgo", 
                     "MDB, ANC" = "Monica Doblas Bajo, Alejandro Núñez Carbajal", 
                     "GMC,JGV" = "Guillermo Mora Collado, Javier García Velasco", 
                     "EPT, MCV" = "Elia Pérez Taboada, Manuel Cernadas Villar", 
                     "LPN, GCT" = "Luis de Pedro Noriega, Guillermo Cabezas Torrero", 
                     "LTB, YRL" = "Laura Torrado Blanco, Yamil Jimenez Rodríguez", 
                     "PAF" = "Piluca Alvarez Fidalgo", 
                     "GMC, JGV" = "Guillermo Mora Collado, Javier García Velasco", 
                     "LPN, CCF" = "Luis de Pedro Noriega, Celia Cantalejo Fuentenebro", 
                     "DBT, LPN" = "Diego Benito Teno, Luis de Pedro Noriega", 
                     "EAG, BDA" = "Emilio Alonso Gómez, Begoña Dávila Alvite", 
                     "DBT, GBD, YJR" = "Diego Benito Teno, Guillermo Bañares de Dios, Yamil Jimenez Rodríguez"))

unique(data$Determined.by)

data <- data %>%
  mutate(
    Determined.by = recode(Determined.by, 
                       "ANC, PAF" = "Alejandro Nuñez Carbajal, Piluca Alvarez Fidalgo", 
                       "MGF" = "Mario Gonzalez Ferreiro", 
                       "PAF" = "Piluca Alvarez Fidalgo", 
                       "GCT, PAF" = "Guillermo Cabezas Torrero, Piluca Alvarez Fidalgo", 
                       "ANC" = "Alejandro Nuñez Carbajal", 
                       "MGF, AAG, IJF" = "Mario Gonzalez Ferreiro, Alvaro Asenjo Guerra, Ines Jimenez Fernandez", 
                       "AAG" = "Alvaro Asenjo Guerra", 
                       "MGF, PAF" = "Mario Gonzalez Ferreiro, Piluca Alvarez Fidalgo", 
                       "CFA" = "Carlos Fernandez Alvarez",
                       "YJR" = "Yamil Jimenez Rodríguez", 
                       "LPN, MDB" = "Luis de Pedro Noriega, Monica Doblas Bajo", 
                       "AAG, PAF" = "Alvaro Asenjo Guerra, Piluca Alvarez Fidalgo", 
                       "IJF, AAG" = "Ines Jimenez Fernandez, Alvaro Asenjo Guerra", 
                       "GCT" = "Guillermo Cabezas Torrero", 
                       "IJF" = "Ines Jimenez Fernandez", 
                       "MGF, PAF, AAG" = "Mario Gonzalez Ferreiro, Piluca Alvarez Fidalgo, Alvaro Asenjo Guerra ", 
                       "MDB, CFA" = "Monica Doblas Bajo, Carlos Fernandez Alvarez", 
                       "CFA, PAF" = "Carlos Fernandez Alvarez, Piluca Alvarez Fidalgo", 
                       "PAF, CFA" = "Piluca Alvarez Fidalgo, Carlos Fernandez Alvarez", 
                       "YJR, PAF" = "Yamil Jimenez Rodríguez, Piluca Alvarez Fidalgo", 
                       "AAG, MGF, GCT, CFA" = "Alvaro Asenjo Guerra, Mario Gonzalez Ferreiro, Guillermo Cabezas Torrero,Carlos Fernandez Alvarez  ", 
                       "MGF, IJF, AAG" = "Mario Gonzalez Ferreiro, Ines Jimenez Fernandez, Alvaro Asenjo Guerra "))

#Save data
write.table(x = data, file = "Data/Processed_raw_data/92_Nuñez_Carvajal_Galicia_2026.csv", 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

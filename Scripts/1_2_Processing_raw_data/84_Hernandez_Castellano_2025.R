
#cargar paquetes
library(here)
library(readxl)
library(dplyr)
library(tidyr)

#read data

data <- read.csv(here("Data/Rawdata/csvs/84_Hernandez_Castellano_2025.csv"), sep = ";")


#Save data
write.table(x = data, file = "Data/Processed_raw_data/84_Hernandez_Castellano_2025.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

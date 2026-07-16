
#cargar paquetes
library(here)
library(readxl)
library(dplyr)
library(tidyr)

#read data

data_castellanos <- read_xlsx(here("Data/Rawdata/csvs/84_Hernandez_Castellano_2025.xlsx"))
check <- read_xlsx("Add_New_Data_Template_English_Version.xlsx", sheet = 3)


#Check vars
intersect(names(check), names(data_castellanos))
setequal(names(check), names(data_castellanos))

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/84_Hernandez_Castellano_2025.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

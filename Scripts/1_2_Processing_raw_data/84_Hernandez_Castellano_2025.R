setwd("C:/Users/maria/Dropbox/Spanish_Bees/done/Data_MJ")

data_castellanos <- read_xlsx("Hernandez_Castellano_2025.xlsx")
check <- read_xlsx("Add_New_Data_Template_English_Version.xlsx", sheet = 3)

#cargar paquetes
library(readxl)
library(dplyr)
library(tidyr)


#Check vars
intersect(names(check), names(data_castellanos))
setequal(names(check), names(data_castellanos))

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/84_Hernandez_Castellano_2025.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

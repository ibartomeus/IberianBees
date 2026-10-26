source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

library(here)
library(readxl)
library(dplyr)
library(tidyr)

#read data

newdat <- read.csv(here("Data/Rawdata/csvs/84_Hernandez_Castellano_2025.csv"), sep = ";")

#Compare vars
compare_variables(check, newdat) #All variables missing. 
#Add missing variables
newdat <- add_missing_variables(check, newdat)

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/84_Hernandez_Castellano_2025.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

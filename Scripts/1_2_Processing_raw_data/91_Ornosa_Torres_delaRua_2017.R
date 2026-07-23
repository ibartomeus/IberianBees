library(here)
library(readxl)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)


data <- read.csv(here("Data/Rawdata/csvs/91_Ornosa_Torres_delaRua_2017.csv"), sep = ";")

sort(unique(data$Locality))

#fix sexes

#Add "1" in Not.specified where all Female, Male, Not.specified are NAs.
data$Not.specified <- ifelse((data$Female == 0 & data$Male == 0),1,0)

#Save data
write.table(x = data, file = "Data/Processed_raw_data/91_Ornosa_Torres_delaRua_2017.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)



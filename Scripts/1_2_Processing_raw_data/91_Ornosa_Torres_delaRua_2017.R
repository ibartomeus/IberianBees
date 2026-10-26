source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template


library(here)
library(readxl)

newdat <- read.csv(here("Data/Rawdata/csvs/91_Ornosa_Torres_delaRua_2017.csv"), sep = ";")

#Compare vars
compare_variables(check, newdat) #Many variables missing.

#Add missing variables
newdat <- add_missing_variables(check, newdat)

#fix sexes

#Add "1" in Not.specified where all Female, Male, Not.specified are NAs.
newdat$Not.specified <- ifelse((newdat$Female == 0 & newdat$Male == 0),1,0)

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/91_Ornosa_Torres_delaRua_2017.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)



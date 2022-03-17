#Here we check species names and add them to the file of manual checks once is done

#Two step process:

#1) Read to_check, select unique cases and check. Ask Thomas Wood if cannot be solved easily.
#IMPORTANT: This csv is updated manuallly by us.

#2) Append checked species or add the full dataset checked to manual checks

#3) RUN Scripts/3_1_Final_cleaning.R and to_checks is automatially updated
#it should have 0 records after all species has bee checked

library(tidyverse)
#List of species to check
to_check <- read.csv("Data/Processing_iberian_bees_raw/to_check.csv", row.names = 1)

#Select unique cases
to_check <- distinct(to_check) #145 species 

#Now load manual checks and append
#Read manual checks
manual <- read.csv("Data/Processing_iberian_bees_raw/manual_checks.csv", sep = ",", stringsAsFactors = FALSE, 
                   na.strings = c(NA, ""))

#cbind dataframes
manual <- dplyr::bind_rows(manual, to_check)

#Save new manual checks
write.csv2(manual, "Data/Processing_iberian_bees_raw/manual_checks.csv")

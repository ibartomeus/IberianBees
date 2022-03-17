#Here we check species names and add them to the file of manual checks once is done

#Two step process:

#1) Read to_check, select unique cases and check. Ask Thomas Wood if cannot be solved easily.

#2) Append checked species or add the full dataset checked to manual checks
#For security reasons we keep track of all manual checks. They will be stored on different files
#For instance, manual_checks.csv, manual_checks_1.csv, manual_checks_2.csv
#An update of this on 2_Final_cleaning will be done when big changes are produced

library(tidyverse)
#List of species to check
to_check <- read.csv("Data/Processing_iberian_bees_raw/to_check.csv", row.names = 1)

#Select unique cases
to_check <- distinct(to_check) #145 species 
#To check by version
#write.csv2(to_check, "Data/Processing_iberian_bees_raw/To_check_by_version/to_check_1.0.csv")

#Load checked species here and append to manual_checks
#Read manual checks
to_check_1.0 <- read.csv("Data/Processing_iberian_bees_raw/To_check_by_version/to_check_1.0.csv", sep = ",", stringsAsFactors = FALSE, 
                   na.strings = c(NA, ""), row.names = 1)

#All versions of to check would be added here 
#Although this has been done already we starts with the count now

#Now load manual checks and append
#Read manual checks
manual <- read.csv("Data/Processing_iberian_bees_raw/manual_checks.csv", sep = ",", stringsAsFactors = FALSE, 
                   na.strings = c(NA, ""))

#cbind dataframes
manual <- dplyr::bind_rows(manual, to_check_1.0)

#Save new manual checks
#write.csv2(manual, "Data/Processing_iberian_bees_raw/manual_checks.csv")
#To have a record of all manual checks
#The first manual checks is considered as 0.0 (see folder)
#write.csv2(manual, "Data/Processing_iberian_bees_raw/Manual_checks_by_version/Manual_checks_1.0.csv")

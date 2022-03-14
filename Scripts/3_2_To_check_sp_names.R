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

#Read manual checks
manual <- read.csv("Data/Processing_iberian_bees_raw/manual_checks.csv", sep = ";", stringsAsFactors = FALSE, 
                   na.strings = c(NA, ""))


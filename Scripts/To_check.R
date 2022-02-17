#To check file

#I need to work on this but basically load manual check, maybe append rows with the handy function of tidyverse
#and the not found ones by us would be checked by Thomas Woods 

#Read manual checks
manual <- read.csv("Data/Processing_iberian_bees_raw/manual_checks.csv", sep = ";", stringsAsFactors = FALSE, 
                   na.strings = c(NA, ""))


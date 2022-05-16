
#Load library
library(tidyverse)

#Load data
data <- read.table("Data/iberian_bees.csv.gz",  header=T, quote="\"", sep=",",row.names=1)

#Filter data (all records older than 1990 for now)

older_1990 <- data %>% filter(Year < 1990)


#Number of levels of locality (this may give an idea of the locations with most records)
localities <- older_1990 %>% 
  group_by(Locality) %>%
  summarise(no_rows = length(Locality))

#We need to filter locations with unique records
#Maybe unique levels of species by location...

unique_loc <- older_1990 %>%
  group_by(Locality) %>%
  summarise(total = n(),
            Y = n_distinct(Accepted_name))

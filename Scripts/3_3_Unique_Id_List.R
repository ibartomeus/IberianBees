#Select unique identifier from the datasets to add the right the dataset holder
#mail and all metadata related
library(tidyverse)

data <- read.table("Data/iberian_bees.csv.gz",  header=T, quote="\"", sep=",",row.names=1)
head(data)

#Select unique identifier (I love R but won't be able to remember this (.*)_([^_]+)$)
data <- data %>% extract(Unique.identifier, into = c("Id", "number"), "(.*)_([^_]+)$")
#Nacho just changed "uid" by "Unique.identifier" as this is how is named. Is this correct?

#Select unique identifier of dataset instead of record
data <- data %>% select(Id) %>% distinct(Id)

#Arrange by same order that we have in "Scripts/1_2_Processing_raw_data"
library(stringr)
data$Number <- word(data$Id, 1, sep = "_")
data$Number <- as.numeric(data$Number)
data <- data %>% arrange(-desc(Number))

#Save data
write.csv(data, "Data/Processing_iberian_bees_raw/dataset_id_list.csv", row.names =F)


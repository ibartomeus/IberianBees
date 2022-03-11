#Select unique identifier from the datasets to add the right the dataset holder
#mail and all metadata related
library(tidyverse)

data <- read.table("Data/iberian_bees.csv.gz",  header=T, quote="\"", sep=",")
#Delete first col that are rownames
data <- data %>% select(-X)

#Select unique identifier (I love R but won't be able to remember this (.*)_([^_]+)$)
data <- data %>% extract(uid, into = c("Id", "number"), "(.*)_([^_]+)$")

#Select unique identifier of dataset instead of record
data <- data %>% select(Id) %>% distinct(Id)

#arrange by same order that I have
library(stringr)
data$Number <- word(data$Id, 1, sep = "_")
data$Number <- as.numeric(data$Number)
data <- data %>% arrange(-desc(Number))

write.csv(data, "Data/Processing_iberian_bees_raw/dataset_id_list.csv", row.names =F)


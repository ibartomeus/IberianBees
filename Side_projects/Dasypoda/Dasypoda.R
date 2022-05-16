library(tidyverse)

data <- read.table("Data/iberian_bees.csv.gz",  header=T, quote="\"", sep=",",row.names=1)


dasy <- data %>% filter(Genus=="Dasypoda")

write.csv(dasy, "Side_projects/Dasypoda/Dasypoda.csv")

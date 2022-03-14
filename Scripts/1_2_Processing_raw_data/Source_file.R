#####################################################################################--
#Source code to process raw data
#####################################################################################--
#Set up----
library(cleanR)
library(dplyr)
library(tidyr)
library(mgrs)
library(stringr)

#First create TEMPLATE to add new data.
#Create an empty data file. 
data <- matrix(ncol = 28, nrow = 1)
data <- as.data.frame(data)
colnames(data) <- c("Genus","Subgenus","Species","Subspecies",
                    "Country","Province","Locality",
                    "Latitude","Longitude","Coordinate.precision",
                    "Year","Month","Day","Start.date","End.date",
                    "Collector","Determined.by","Female","Male","Worker","Not.specified",
                    "Reference.doi","Flowers.visited","Local_ID","Authors.to.give.credit",
                    "Any.other.additional.data","Notes.and.queries", "uid")

write.csv(data, "Data/data.csv", row.names = FALSE)
#read data.csv for comparisons
data <- read.csv("Data/data.csv",stringsAsFactors=TRUE)
#colnames(data)
#head(data)
check <- define_template(data, NA)


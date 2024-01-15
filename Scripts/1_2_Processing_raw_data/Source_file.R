#####################################################################################--
#Source code to process raw data
#####################################################################################--
#Set up----
#devtools::install_github("RadicalCommEcol/CleanR", build_vignettes = TRUE)
library(cleanR)
library(dplyr)
library(tidyr)
#remotes::install_github("hrbrmstr/mgrs")
library(mgrs)
library(stringr)

#First create TEMPLATE to add new data.
#Create an empty data file. 
data <- matrix(ncol = 28, nrow = 2)
data <- as.data.frame(data)
colnames(data) <- c("Genus","Subgenus","Species","Subspecies",
                    "Country","Province","Locality",
                    "Latitude","Longitude","Coordinate.precision",
                    "Year","Month","Day","Start.date","End.date",
                    "Collector","Determined.by","Female","Male","Worker","Not.specified",
                    "Reference.doi","Flowers.visited","Local_ID","Authors.to.give.credit",
                    "Any.other.additional.data","Notes.and.queries", "uid")

#Adding min and max values, and adjusting variables so that classes become correct.
data$Genus <- as.character("Genus") #First time I run code is factor, when I only mark this line it gets character.
data$Subgenus <- as.character("Subgenus")
data$Species <- as.character("Species")
data$Subspecies <- as.character("Subspecies")
data$Country <- as.character("Country")
data$Province <- as.character("Province")
data$Locality <- as.character("Locality")
data$Latitude <- c(25, 44) #Should be numeric because they have decimals.
data$Longitude <- c(-20, 10)
data$Coordinate.precision <- as.character("Coordinate.precision")
data$Year <- as.integer(c(1900, 2023))
data$Month <- as.integer(c(1, 12))
data$Day <- as.integer(c(1, 31))
data$Start.date <- as.character("Start.date")
data$End.date <- as.character("End.date")
data$Collector <- as.character("Collector")
data$Determined.by <- as.character("Determined.by")
data$Female <- as.integer(c(0,50))
data$Male <- as.integer(c(0, 50))
data$Worker <- as.integer(c(0, 50))
data$Not.specified <- as.integer(c(0, 50))
data$Reference.doi <- as.character("Reference.doi")
data$Flowers.visited <- as.character("Flowers.visited")
data$Local_ID <- as.character("Local_ID")
data$Authors.to.give.credit <- as.character("Authoras.to.give.credit")
data$Any.other.additional.data <- as.character("Any.other.additional.data")
data$Notes.and.queries <- as.character("Notes.and.queries")
data$uid <- as.character("uid")

write.csv(data, "Data/Processing_iberian_bees_raw/data.csv", row.names = FALSE)
#read data.csv for comparisons
data <- read.csv("Data/Processing_iberian_bees_raw/data.csv",stringsAsFactors=TRUE)
str(data)
#colnames(data)
#head(data)
check <- define_template(data, NA)


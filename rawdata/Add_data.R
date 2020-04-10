# Template to Add new data.

#CReate an empty data file. This is done just once, and hence is commented
# data <- matrix(ncol = 24, nrow = 1)
# data <- as.data.frame(data)
# colnames(data) <- c("Genus","Species","Subspecies",
#                     "Country","Province","Locality",
#                     "Latitude","Longitude","Coordinate.precision",
#                     "Year","Month","Day",
#                     "Collector","Determined.by","Female","Male","Worker","Not.specified",
#                     "Reference.doi","Flowers.visited","Local_ID","Authors.to.give.credit",
#                     "Any.other.additional.data","Notes.and.queries")
# head(data)
# write.csv(data, "data/data.csv", row.names = FALSE)

#read data.csv for comaprisions
data <- read.csv("data/data.csv")
colnames(data)
head(data)

#Add data
newdat <- read.csv(file = "rawdata/Wood_Asher_Naturalis_20200313.csv")
colnames(newdat)
colnames(data)
#strat with a simpier one

#Add data Montero
newdat <- read.csv(file = "rawdata/AnaMontero.csv")
#quick way to compare colnames
cbind(colnames(newdat) , colnames(data)) #can be merged
summary(newdat)
newdat$Authors.to.give.credit <- "Ana Montero-Castaño, Montserrat Vilà"
#newdat$Reference..doi. several doi's listed "," and "and" separated. Fix later?
#questions flowers species with Genus_spcies -> accepted, easy to change in bulk. 
write.table(x = newdat, file = "data/data.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE, append = TRUE)




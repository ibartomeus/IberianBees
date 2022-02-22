source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 5_Banos-Picon_etal ----

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/5_Banos-Picon_etal.csv')

#reorder and drop variables
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) 
summary(newdat)

#Fix coordinates, they are UTM
#Spain has zone 30, rgdal does the job but think in another package
#this was is being deleted from cran in 2023
library(rgdal) 
#provide coordinate format
utm <- SpatialPoints(cbind(newdat$Longitude, newdat$Latitude), 
                     proj4string=CRS("+proj=utm +zone=30 +datume=WGS84 "))
#Convert to lon/lat
coord <- as.data.frame(spTransform(utm, 
                                   CRS("+proj=longlat +datum=WGS84"))) #lon/lat
#Store back as lon/lat in the data
newdat$Longitude <- coord$coords.x1
newdat$Latitude <- coord$coords.x2

#Replace hyphen by forward slash
newdat$Start.date <- gsub("-", "/", newdat$Start.date)
newdat$End.date <- gsub("-", "/", newdat$End.date)
#Convert to standard format of the database
library(anytime)  
#This library is awesome and can stand 
#leading zeros and without zeros
#Start.date
newdat$Start.date <- anydate(newdat$Start.date)
newdat$Start.date <- as.Date(newdat$Start.date,format = "%Y/%d/%m")
newdat$Start.date <- format(newdat$Start.date, "%d/%m/%Y")
#End.date
newdat$End.date <- anydate(newdat$End.date)
newdat$End.date <- as.Date(newdat$End.date,format = "%Y/%d/%m")
newdat$End.date <- format(newdat$End.date, "%d/%m/%Y")

#Convert DOI to link
levels(factor(newdat$Reference.doi)) #annoying error in doi (classical excel one)
#Substitute all partial matches with the correct doi
newdat$Reference.doi[grepl("10.1016/j.baae", 
newdat$Reference.doi, ignore.case=FALSE)] <- "10.1016/j.baae.2012.12.008"
#Substitute all partial matches with the correct doi
newdat$Reference.doi[grepl("10.1111/ele.13", 
newdat$Reference.doi, ignore.case=FALSE)] <- "10.1111/ele.13265"
#Now seems right
#Convert to link format
newdat$Reference.doi <- paste0("https://doi.org/",
                               newdat$Reference.doi)
#Ugly but works, convert now "https://doi.org/NA" back to NA
newdat$Reference.doi <- gsub("https://doi.org/NA" , NA, newdat$Reference.doi)
#The four links work

#Add unique identifier
newdat <- add_uid(newdat = newdat, '5_Banos-Picon_')

#save data
write.table(x = newdat, file = 'Data/Processed_raw_data/5_Banos-Picon_etal.csv', 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

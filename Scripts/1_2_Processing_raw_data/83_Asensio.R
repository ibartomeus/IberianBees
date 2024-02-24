source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 83_Asensio ---- (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/83_Asensio.csv', sep = ";")

#Compare vars
compare_variables(check, newdat) #Many variables missing.

#Add missing variables
newdat <- add_missing_variables(check, newdat)

#Renaming long variable name so that cleaning is easier.
colnames(newdat)[colnames(newdat) == "X..id...genus...species...num_individuals...sex...m_IT...day...month...year...collector...taxonomist...Lat2...Long2."] <- "X"

#Removing "id" to facilitate the succeeding cleaning.
newdat <- mutate(newdat, X = gsub("^\\d{2,4},(?:\\d{1,4}|NA),", "", X))

#Divide the data into the correct variables.
newdat[1698, "X"] <- gsub('eous morice, 1904', 'eous morice 1904', newdat[1698, "X"]) #A small fix on one row before next step.
#Next step is based on separating variables based on comma signs.
split_data <- strsplit(newdat$X, ",")

newdat$Genus <- sapply(split_data, "[[", 1)
newdat$Species <- sapply(split_data, "[[", 2)
newdat$Not.specified <- sapply(split_data, "[[", 3)
newdat$Sex <- as.character(sapply(split_data, "[[", 4)) #Adding a variable Sex just to work with rn. Is changed below.
newdat$Notes.and.queries <- sapply(split_data, "[[", 5) #This variable is called m_IT. Not sure what it is so I put in Notes-var.
newdat$Day <- as.numeric(sapply(split_data, "[[", 6))
newdat$Month <- as.integer(sapply(split_data, "[[", 7))
newdat$Year <- as.integer(sapply(split_data, "[[", 8))
newdat$Collector <- as.character(sapply(split_data, "[[", 9))
newdat$Determined.by <- as.character(sapply(split_data, "[[", 10))
newdat$Latitude <- sapply(split_data, "[[", 11)
newdat$Longitude <- sapply(split_data, "[[", 12)

#Removing rows that are not consistent with the comma signs separations and hence get faulty values.
#All these can be recognized by faulty getting a character in the Latitude variable. 
newdat <- newdat[!grepl("[A-Za-z]", newdat$Latitude), ] # ~50 rows deleted.

#Rearranging "female" and "male" in variable Sex to the correct variables.
unique(newdat$Sex)
newdat$Female <- ifelse(newdat$Sex == "\"female\"", 1, NA)
newdat$Male <- ifelse(newdat$Sex == "\"male\"", 1, NA)
#Ignoring the "NA"s since these will be NAs anyways.

#Remove " in Genus and Species.
newdat$Genus <- gsub("^\"|\"$", "", newdat$Genus)
newdat$Species <- gsub("^\"|\"$", "", newdat$Species)
newdat$Collector <- gsub("^\"|\"$", "", newdat$Collector)
newdat$Determined.by <- gsub("^\"|\"$", "", newdat$Determined.by)

#Add localities through csv file "Locations".
library(dplyr)
library(readxl)
location_data <- read.csv(file = 'Data/Processing_iberian_bees_raw/Locations.csv', sep = ";")
location_data$Lat <- gsub(",", ".", location_data$Lat)
location_data$Long <- gsub(",", ".", location_data$Long)
newdat <- left_join(newdat, location_data |> distinct(Lat, .keep_all = TRUE), by = c("Latitude" = "Lat"), keep = FALSE, relationship = "many-to-many")
#many-to-many means I only keep the first location in csv file corresponding to a coordinate. 

#####
# #Read in another csv file for additional coordinates who aren't in Locations.csv.
# location_coordinates_data <- read.csv(file = 'Data/Processing_iberian_bees_raw//Locations_coordinates.csv', sep = ";")
# colnames(location_coordinates_data)[colnames(location_coordinates_data) == "X.Var1.Freq.Locality.Lat..Long...Precision.site..city..natural.park..etcÉ..."] <- "X"
# 
# split_data <- strsplit(location_coordinates_data$X, ",")
# 
# location_coordinates_data$X <- sapply(split_data, "[[", 1)
# location_coordinates_data$Var1 <- sapply(split_data, "[[", 2)
# location_coordinates_data$Freq <- sapply(split_data, "[[", 3)
# location_coordinates_data$Locality <- sapply(split_data, "[[", 4)
# location_coordinates_data$Lat <- sapply(split_data, "[[", 5)
# location_coordinates_data$Long <- sapply(split_data, "[[", 6)
# location_coordinates_data$Precision <- sapply(split_data, "[[", 7)
# #NOTE: coordinates have very different formats. Some have 41,442,884,-4,460,304 and some 41.442884,-4.460304 or 41"442"884",-4"460"304.
# #For now I'm only working with the ones that are already in the correct format, ie 41.442884,-4.460304.
# #But more work can be done here when time allows. ~80% of the data is in weird formats.
# #For now, this means that csv file Locations_coordinates don't give any more data than the csv file Locations, if we don't clean it,
# #However, I'll still keep the code so it can be worked with in the future.
# #Code is within ##### symbols.
# 
# location_coordinates_data <- select(location_coordinates_data, c(-X, -Freq))
# 
# newdat <- left_join(newdat, location_coordinates_data |> distinct(Lat, .keep_all = TRUE), by = c("Latitude" = "Lat"), keep = FALSE, relationship = "many-to-many")
#####

#Choose to put the variable "Var1" as Locality, instead of "Locality.y", since Var1 have ~2600 more rows than Locality.y with information.
newdat$Locality <- newdat$Var1

#Remove "" in Locality
newdat$Locality <- gsub("^\"|\"$", "", newdat$Locality)

#Fix typo in Locality
newdat$Locality <- gsub("Zamadue\\?as", "Zamadueñas", newdat$Locality)

#Add provincies through shapefiles
library(sf)
library(dplyr)

#Shape files from https://public.opendatasoft.com/explore/dataset/georef-spain-provincia/export/?disjunctive.acom_code&disjunctive.acom_name&disjunctive.prov_code&disjunctive.prov_name
spain_provinces <- st_read("Data/Processing_iberian_bees_raw/georef-spain-provincia/georef-spain-provincia-millesime.shp")
portugal_provinces <- st_read("Data/Processing_iberian_bees_raw/georef-portugal-distrito/georef-portugal-distrito-millesime.shp")

newdat_sf <- st_as_sf(newdat, coords = c("Longitude", "Latitude"), crs = 4326)  # Assuming coordinates are in WGS84

#Making sure everything is in the same coordinate system
st_crs(spain_provinces) <- st_crs(portugal_provinces) <- st_crs(newdat_sf) <- st_crs("+proj=longlat +datum=WGS84")

#Spatial join with the newdat shape file and shapefiles spain and portugal.
newdat_sf <- st_join(newdat_sf, spain_provinces, join = st_intersects)
newdat_sf <- st_join(newdat_sf, portugal_provinces, join = st_intersects)

#Extract province names and add to the variable Province.
newdat_sf$Province <- ifelse(!is.na(newdat_sf$prov_name), newdat_sf$prov_name, newdat_sf$dis_name)

#Add province names to newdat.
newdat$Province <- newdat_sf$Province

#Fix coordinate precision.
#Coordinate precisions are based on assumptions on site info in variable Precision.site..city..natural.park..etcÉ.
for (i in 1:nrow(newdat)) {
  # Extract the current precision
  precision <- newdat$Precision.site..city..natural.park..etcÉ.[i]
  
  # Conditions
  if (is.na(precision)) {
    newdat$Coordinate.precision[i] <- NA
  } else if (precision == "Site" || precision == "Park" ||
             precision =="Urban Park" || precision == "Site - Road through mountains") { #Assume park and urban park are rather small.
    newdat$Coordinate.precision[i] <- "<100m"
  } else if (precision == "Municipality" || precision == "Valley region" ||
             precision == "Town/Municipality" || precision == "Municipality " ||
             precision == "Natural park" || precision == "Natural Park" ||
             precision == "National Park" || precision == "County" ||
             precision == "Region" || precision == "Municipality/Town" ||
             precision == "Mountain Range" || precision == "Mountain range" ||
             precision == "Natural region") { #Note different typos like blank spaces in precision.
    newdat$Coordinate.precision[i] <- "<10km"
  } else if (precision == "Village" || precision == "Town " ||
             precision == "City" || precision == "Mountain site" ||
             precision == "Hamlet") {
    newdat$Coordinate.precision[i] <- "<1km"
  } else if (precision == "Valladolid Province") { #Assume province >10km.
    newdat$Coordinate.precision[i] <- ">10km"
  } 
}

#Remove where Day is 75. Have double checked in original dataset and is also there written faulty as 75.
rows_to_remove <- which(newdat$Day == 75) #The function subset faulty removed ~600 rows instead of one, that's why code is a bit longer. 
newdat <- newdat[-rows_to_remove, ]
rm(rows_to_remove)

#Drop variables
newdat <- drop_variables(check, newdat)

#Add unique identifier
newdat$uid <- paste("83_Asensio", 1:nrow(newdat), sep = "")

head(newdat, 100)
#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/83_Asensio.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

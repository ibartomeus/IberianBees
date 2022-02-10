source("Processing_raw_data/Source_file.R") #Generate template

# 3_Montero_etal ----

#Read data
newdat <- read.csv(file = "Rawdata/csvs/3_Montero_etal.csv")
#old template, subgenus, start and end date missing.
#compare variables
compare_variables(check, newdat)

#Rename variables
colnames(newdat)[which(colnames(newdat) ==
"Coordinate.precision..e.g..GPS...10km.")] <- "Coordinate.precision"
colnames(newdat)[which(colnames(newdat) ==
"Reference..doi.")] <- "Reference.doi"

#Check levels from Reference.doi
levels(factor(newdat$Reference.doi))
#One level has multiple DOI's in a single cell separated with ',' and with 'and'
#Let's make the separator a ',' for all cases
newdat$Reference.doi <- gsub(" and", ",", newdat$Reference.doi)
#Just show the oldest DOI for now for simplicity
#In this case is https://doi.org/10.1016/j.actao.2014.01.001
#As note, DOI 3 in level 2 levels(factor(newdat$Reference.doi)) 
#seems to link with an incorrect paper
#Extract just the first doi (the oldest)
newdat$Reference.doi <- sub(',.*$','', newdat$Reference.doi) 
#Check levels now
levels(factor(newdat$Reference.doi)) 
#It's correct, next!

newdat <- add_missing_variables(check, newdat)
#reorder and drop variables
newdat <- drop_variables(check, newdat)
#quick way to compare colnames
cbind(colnames(newdat) , colnames(data)) #can be merged
summary(newdat)
newdat$Authors.to.give.credit <- "Ana Montero-Castaño, Montserrat Vilà"
temp <- extract_pieces(newdat$Genus, subgenus = TRUE) 
newdat$Subgenus <- temp$piece1
newdat <- add_uid(newdat = newdat, "3_Montero_")

#Fix Genus
levels(factor(newdat$Genus)) #Erase everything after underscore
newdat$Genus <- gsub("\\_.*","",newdat$Genus) #Correct now

#Flowers visited, delete underscore, Genus_species to Genus species
newdat$Flowers.visited <- gsub("_", " ", newdat$Flowers.visited)

#Convert DOI to link
levels(factor(newdat$Reference.doi))
newdat$Reference.doi <- paste0("https://doi.org/",newdat$Reference.doi)
#Both links work

#Save data
write.table(x = newdat, file = "Data/Processing_raw_data/3_Montero_etal.csv", 
            quote = TRUE, sep = ",", col.names = FALSE,
            row.names = FALSE)

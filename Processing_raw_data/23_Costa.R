source("Processing_raw_data/Source_file.R") #Generate template

# 23_Costa ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Rawdata/csvs/23_Costa.csv', sep = ";")

#Check vars
compare_variables(check, newdat)
newdat <- add_missing_variables(check, newdat)
#extract_pieces()
#help_geo()
#help_species()
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)

#Convert moth to number
newdat$Month <- gsub("Agosto", "08", newdat$Month)
newdat$Month <- gsub("Marzo", "03", newdat$Month)
#Add leading 0 to month
newdat$Day <- ifelse(newdat$Day < 10, paste0("0", newdat$Day), newdat$Day)

#Convert to link format
newdat$Reference.doi <- paste0("https://doi.org/",
                               newdat$Reference.doi)
#Ugly but works, convert now "https://doi.org/NA" back to NA
newdat$Reference.doi <- gsub("https://doi.org/NA" , NA, newdat$Reference.doi)
#Both links work fine

#Delete species with sp.
newdat <- newdat %>% filter(Species!="sp.")

#Add unique identifier
newdat <- add_uid(newdat = newdat, '23_Costa_')

#Save data
write.table(x = newdat, file = 'Data/Processing_raw_data/23_Costa.csv', quote = TRUE, 
            sep = ',', col.names = FALSE, row.names = FALSE)

source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 71_Rodrigo_etal ---- From Data_Saray (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/71_Rodrigo_etal.csv', sep = ";")
str(newdat)

#Dataset doesn't include coordinates nor dates.

#Compare vars
compare_variables(check, newdat) #No vars missing, no extra vars. Some classes wrong. Number of females out of range, 
#but still a reasonable number (ie max = 110 observations).

#Removing "ssp" in subspecies, and subspecies "Melona" to a small letter.
newdat$Subspecies <- gsub("ssp. Melona", "melona", newdat$Subspecies)

#Note that some data in var 'Species' include "cfr." for uncertainty. Not deleting this.

#Replace plants with their latin name (retrived from the paper w doi 10.1080/00379271.2020.1847191)
newdat$Flowers.visited <- ifelse(newdat$Flowers.visited == "Melon", "Cucumis melo", newdat$Flowers.visited)
newdat$Flowers.visited <- gsub("Watermelon", "Citrullus lanatus", newdat$Flowers.visited)

#Replacing zeros to NAs in sexes.
newdat$Female <- replace(newdat$Female, newdat$Female == 0, NA)
newdat$Male <- replace(newdat$Male, newdat$Male == 0, NA)
newdat$Worker <- replace(newdat$Worker, newdat$Worker == 0, NA)

#Add "1" in Not.specified where all Female, Male, Worker, Not.specified are NAs.
na_rows <- is.na(newdat$Female) & is.na(newdat$Male) & is.na(newdat$Worker) & is.na(newdat$Not.specified)
newdat$Not.specified[na_rows] <- 1

#Reorder and drop variables
newdat <- drop_variables(check, newdat) #No valuable info is lost

#Add unique identifier
newdat$uid <- paste("71_Rodrigo_etal", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/71_Rodrigo_etal.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

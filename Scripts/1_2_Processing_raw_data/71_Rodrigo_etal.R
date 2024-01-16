source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 71_Rodrigo_etal ---- From Data_Saray (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/71_Rodrigo_etal.csv', sep = ";")
str(newdat)

newdat$Female <- ifelse(is.na(newdat$Female), 0, newdat$Female) #Adding this so I get a warning that number of obs are out of range.
newdat$Male <- ifelse(is.na(newdat$Female), 0, newdat$Male)

#Compare vars
compare_variables(check, newdat) #No vars missing, no extra vars. Some classes wrong. Number of females out of range, 
#but still a reasonable number (ie max = 110 observations).

#Unsure if "ssp" in subspecies Melona should still be there. Not removing it now.
#Note that some data in var 'Species' include "cfr." for uncertainty. Not deleting this.

#Dataset doesn't include coordinates nor dates.

#Replace plants with their latin name (retrived from the paper w doi 10.1080/00379271.2020.1847191)
#newdat$Flowers.visited <- gsub("melon", "Cucumis melo L.", newdat$Flowers.visited)
newdat$Flowers.visited <- ifelse(newdat$Flowers.visited == "Melon", "Cucumis melo L.", newdat$Flowers.visited)
newdat$Flowers.visited <- gsub("Watermelon", "Citrullus lanatus", newdat$Flowers.visited)

#Reorder and drop variables
newdat <- drop_variables(check, newdat) #No valuable info is lost

#Add unique identifier
newdat$uid <- paste("71_Rodrigo_etal", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/71_Rodrigo_etal.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

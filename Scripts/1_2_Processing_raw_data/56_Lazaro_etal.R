source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 56_Lazaro_etal  ---- proyecto WILDFUN

#Read data
newdat <- read.csv(file = "Data/Rawdata/csvs/56_Lazaro_etal.csv", sep=",")

#Check vars
compare_variables(check, newdat)

#Before renaming cols and to avoid the loss of information 
#we integrate municipality in the location column
newdat$Municipality <- paste0("(", newdat$Municipality, ")")
newdat$Locality <- paste(newdat$Locality, newdat$Municipality)

#Rename cols
colnames(newdat)[which(colnames(newdat) == 'Determiner')] <- 'Determined.by'

#Split sex column into two cols
newdat$Female <- ifelse(newdat$Sex=="f", 1, NA)
newdat$Male <- ifelse(newdat$Sex=="m", 1, NA)

#Check vars again
compare_variables(check, newdat)

#Add authors to give credit
newdat$Authors.to.give.credit <- "Amparo Lázaro, Carmelo Gómez-Martínez y Miguel Ángel González-Estévez"

#Add missing vars
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables

#Add unique identifier
newdat$uid <- paste("56_Lazaro_etal", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/56_Lazaro_etal.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)


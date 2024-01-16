source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 72_Dardon_etal ---- From Data_Saray (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/72_Dardon_etal.csv', sep = ";")

newdat$Year <- ifelse(is.na(newdat$Year), 0, newdat$Year) #Adding this because I note some yrs are far back.
#So I can spot if some yrs are out of range. 
min(newdat$Year[newdat$Year > 0]) #Just to see that earliest sample is from 1890.

#Compare vars
compare_variables(check, newdat) #No vars missing, no extra vars.

#Dataset includes countries may countries over 10. Budapest wrongly put as a country. Fix this.
newdat$Country <- gsub("Budapest", "Hungary", newdat$Country)
newdat$Province <- ifelse(newdat$Country == "Hungary", "Budapest", newdat$Province)
newdat$Country <- gsub("Alemania", "Germany", newdat$Country)
newdat$Country <- gsub("Bélgica", "Belgium", newdat$Country)
#NOTE: There are more to fix here for countries, eg Hakkari is put as a country.
#I don't do more at this point, but this can be fixed later.

# DOI 10.11646/zootaxa.0000.0.10 doesn't seem to work?

#Reorder and drop variables
newdat <- drop_variables(check, newdat) #No valuable info is lost

#Add unique identifier
newdat$uid <- paste("72_Dardon_etal", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/72_Dardon_etal.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

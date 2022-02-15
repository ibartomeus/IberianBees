source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 10_Ornosa_etal ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/10_Ornosa_etal.csv', sep=";")

#Check vars
compare_variables(check, newdat)

#Fix dates
(temp <- extract_date(newdat$Date, "%d-%m-%Y"))
newdat$Day <- temp$day
newdat$Year <- temp$year
newdat$Month <- temp$month
newdat$Authors.to.give.credit <- "C. Ornosa"

#reorder and drop variables
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) 
summary(newdat)

#Rename country
newdat$Country <- gsub("España", "Spain", newdat$Country)

#This dataset has - in some cells instead of NA
newdat[newdat=="-"] <- NA

#add unique identifier
newdat <- add_uid(newdat = newdat, '10_Ornosa_etal_')

colnames(newdat)

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/10_Ornosa_etal.csv', 
            quote = TRUE, sep = ',', col.names = TRUE, 
            row.names = FALSE)

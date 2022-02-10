source("Processing_raw_data/Source_file.R") #Generate template


# 40_Gonzalez  ----

#Check help of the function CleanR
help_structure()

#Read data
newdat <- read.csv(file = 'rawdata/csvs/40_Gonzalez.csv', sep = ";")

#Check vars
compare_variables(check, newdat)

#fFix dates
(temp <- extract_date(newdat$Date, "%d-%m-%Y"))
newdat$Day <- temp$day
newdat$Month <- temp$month
newdat$Year <- temp$year

#Add vars
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat$Authors.to.give.credit <- "C. Ornosa"

#Rename country
newdat$Country <- gsub("España", "Spain", newdat$Country)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '40_Gonzalez_')

#Save data
write.table(x = newdat, file = 'Data/Processing_raw_data/40_Gonzalez.csv',
            quote = TRUE, sep = ',', col.names = FALSE, 
            row.names = FALSE)

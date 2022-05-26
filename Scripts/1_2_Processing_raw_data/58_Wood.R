source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 58_Wood ----

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/58_Wood.csv', sep = ",")

#Compare vars
compare_variables(check, newdat)

# Rename col
newdat <- newdat %>% mutate(Determined.by = Determiner)

#Fix dates
temp <- extract_date(newdat$Start.date, format_ = "%d/%m/%Y")
newdat$Day <- temp$day
newdat$Month <- temp$month
newdat$Year <- temp$year

#Add and drop variables
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) #reorder and drop variables

newdat$Collector <- "T. Wood"
newdat$Determined.by <- "T. Wood"
newdat$Authors.to.give.credit <- "T. Wood"
newdat$Locality <- "Aznalcazar"
newdat$Year <- 2021
newdat$Start.date <- "21/05/2021"
newdat$End.date <- "21/05/2021"

#Add uid
newdat$uid <- paste("58_Wood_", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/58_Wood.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)


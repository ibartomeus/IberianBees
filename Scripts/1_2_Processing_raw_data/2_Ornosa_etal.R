source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 2_Ornosa_etal ----

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/2_Ornosa_etal.csv', sep = ";")
#Compare vars
compare_variables(check, newdat)
#check help for coordinates
help_geo()
newdat$Latitude <- parzer::parse_lat(as.character(newdat$GPS))
newdat$Longitude <- parzer::parse_lon(as.character(newdat$GPS.1))
#rename authors to give credit
newdat$Authors.to.give.credit <- "C.Ornosa"
#reorder and drop variables
newdat <- add_missing_variables(check, newdat)
newdat <- drop_variables(check, newdat) 

#Exclude rows that are NA in genus (full rows NA'S except some values)
newdat <- newdat[!is.na(newdat$Genus),]

#Fix countries (I do it in this way so we do not require any packages)
newdat$Country[newdat$Province=="Granada"] <- "España"
newdat$Country[newdat$Province=="Huesca"] <- "España"
newdat$Country[newdat$Province=="Gerona"] <- "España"
newdat$Country[newdat$Province=="Lérida"] <- "España"
newdat$Country[newdat$Province=="Pontevedra"] <- "España"
newdat$Country[newdat$Province=="Madrid"] <- "España"
newdat$Country[newdat$Province=="Segovia"] <- "España"
newdat$Country[newdat$Province=="Jaén"] <- "España"
newdat$Country[newdat$Province=="Zaragoza"] <- "España"
#seems ok now
#Rename countries in English
levels(factor(newdat$Country))
newdat$Country <- gsub("España", 
                       "Spain", newdat$Country, fixed = TRUE) 
newdat$Country <- gsub("Marruecos", 
                       "Morocco", newdat$Country, fixed = TRUE) 
newdat$Country <- gsub("Francia", 
                       "France", newdat$Country)

#Fix provinces (just the Spanish ones for now)
newdat$Province[newdat$Locality=="Moratalla"] <- "Murcia"

#Fix now dates, some years missing that can be filled from start and end date
#Extract year from strat.date column, store it another dataframe
year_d <- as.data.frame(format(as.Date(newdat$Start.date, format="%d-%m-%Y"),"%Y"))
colnames(year_d) <- "y" #New colname for simplicity
year_d$Year <- newdat$Year #Add new column (the year one from newdat)
#Workaround to fill missing years (needs Tydiverse)
year_d_1 <- data.frame(t(year_d)) %>% 
  fill(., names(.)) %>%
  t() %>% as.data.frame()
#Works well, add now the column back to the dataframe
newdat$Year <- year_d_1$Year
#Check levels, fix "   6", its year 2008
levels(factor(newdat$Year))
newdat$Year <- gsub("   6", 
                    "2008", newdat$Year)

#Now this process can be repeated by month
#Extract month from start.date column, store it another dataframe
month_d <- as.data.frame(format(as.Date(newdat$Start.date, format="%d-%m-%Y"),"%m"))
colnames(month_d) <- "m" #New colname for simplicity
#Add leading 0 to month column before merging
newdat$Month <- ifelse(newdat$Month < 10, paste0("0", newdat$Month), newdat$Month)
month_d$Month <- newdat$Month #Add new column (the month one from newdat)

#Workaround to fill missing years (needs Tydiverse)
month_d_1 <- data.frame(t(month_d)) %>% 
  fill(., names(.)) %>%
  t() %>% as.data.frame()
#Works well, add now the column back to the dataframe
newdat$Month <- month_d_1$Month

#Replace hyphen by forward slash
newdat$Start.date <- gsub("-", "/", newdat$Start.date)
newdat$End.date <- gsub("-", "/", newdat$End.date)

#Check collector levels
levels(factor(newdat$Collector)) #they are a bit chaotic
#Lets unify a bit
newdat$Collector <- gsub("C. Onosa", 
                         "C. Ornosa", newdat$Collector)
newdat$Collector <- gsub("A. Glez.-Posada", 
                         "A. Glez-Posada", newdat$Collector)
newdat$Collector <- gsub("Pablo Vargas", 
                         "P. Vargas", newdat$Collector)
newdat$Collector <- gsub("P. Vargas (de M. Luceño)", 
                         "P. Vargas", newdat$Collector, fixed = TRUE) #because of the ñ, fixed=T
#Now looks a bit better

#Check detetermined.by levels
levels(factor(newdat$Determined.by)) 
newdat$Determined.by <- gsub("C. Onosa", 
                             "C. Ornosa", newdat$Determined.by)

#Add space to  credit author
levels(factor(newdat$Authors.to.give.credit))
newdat$Authors.to.give.credit <- gsub("C.Ornosa", 
                                      "C. Ornosa", newdat$Authors.to.give.credit)

#Add unique identifier
newdat <- add_uid(newdat = newdat, '2_Ornosa_')

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/2_Ornosa_etal.csv', quote = TRUE, sep = ',', 
col.names = TRUE, row.names = FALSE)

source("Scripts/Processing_raw_data/Source_file.R") #Generate template


# 19_Kuhlmann_etal ----

#Check help of the function CleanR
#help_structure()

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/19_Kuhlmann_etal.csv', sep = ";")

#Check vars
compare_variables(check, newdat)

#Rename variables if needed
colnames(newdat)[which(colnames(newdat) == 'Coll....source')] <- 'Authors.to.give.credit' 
newdat$Genus <- "Colletes"

#Add vars
newdat <- add_missing_variables(check, newdat)
unique(newdat$Country)
newdat <- subset(newdat, Country == "SPAIN") #PT already in T. Wood compilation according to Luisa. Check?

#Fix coordinates
help_geo()
newdat$Latitude <- parzer::parse_lat(as.character(newdat$Latitude))
newdat$Longitude <- parzer::parse_lon(as.character(newdat$Longitude))
newdat <- drop_variables(check, newdat) #reorder and drop variables
summary(newdat)
newdat <- add_uid(newdat = newdat, '19_Kuhlmann_etal_')

#Rename Country
newdat$Country <- gsub("SPAIN", "Spain", newdat$Country)

#Extract year and month and fill
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

#The number of levels here is a bit crazy
#and maybe a bit repetitive
levels(factor(newdat$Authors.to.give.credit))
#just convert to lower case these ones
newdat$Authors.to.give.credit <- gsub("(NOSKIEWICZ 1936)", 
                                      "Noskiewicz 1936", newdat$Authors.to.give.credit, fixed=T)
newdat$Authors.to.give.credit <- gsub("(RATHJEN 1998)",
                                      "Rathjen 1998", newdat$Authors.to.give.credit, fixed=T)
newdat$Authors.to.give.credit <- gsub("(WARNCKE 1978)",
                                      "Warncke 1978", newdat$Authors.to.give.credit, fixed=T)
newdat$Authors.to.give.credit <- gsub("(WESTRICH 1997)",
                                      "Westrich 1997", newdat$Authors.to.give.credit, fixed=T)

#Save data
write.table(x = newdat, file = 'Data/Processed_raw_data/19_Kuhlmann_etal.csv', 
            quote = TRUE, sep = ',', col.names = FALSE, 
            row.names = FALSE)

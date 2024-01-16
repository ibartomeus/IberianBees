source("Scripts/1_2_Processing_raw_data/Source_file.R") #Generate template

# 64_Zafra ---- (Unni)

#Read data
newdat <- read.csv(file = 'Data/Rawdata/csvs/64_Zafra.csv', sep = ";")

#Compare vars
compare_variables(check, newdat) #Only uid missing. No extra vars. Some classes wrong.

#Change from 'España' to 'Spain'
newdat$Country <- ifelse(newdat$Country == "España", "Spain", newdat$Country)

#Change months from alphabetic to numeric
month_names <- c("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre")
newdat$Month <- match(trimws(newdat$Month), month_names) #Using trimws because I noted that Marzo was followed by a blank space.

#Add missing variables
newdat <- add_missing_variables(check, newdat)  #uid added.

#Comparing vars again
compare_variables(check, newdat) #Looks good.

#Reorder and drop variables
newdat <- drop_variables(check, newdat) #No valuable info is lost

#Add unique identifier
newdat$uid <- paste("64_Zafra", 1:nrow(newdat), sep = "")

#Save data
write.table(x = newdat, file = "Data/Processed_raw_data/64_Zafra.csv", 
            quote = TRUE, sep = ",", col.names = TRUE,
            row.names = FALSE)

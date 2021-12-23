#This script is to keep record of how the old names have been changed
#The old names can be found in "Rename_csvs.csv"


#Script to rename files to a shorter 
#unique identifier with number and main author 
#e.g., "1_Ornosa.csv" or "1_Ornosa_etal.csv" if there 
#are more authors involved

#Read all files
file_names_old <- list.files("~/R_projects/IberianBees/rawdata/csvs")              # Get current file names
#write.csv(file_names_old, "Rename_csv.csv") #Save file names to add
#names manually, this needs a proper search in the dataset and check
#who is the main contributor of the dataset, that is, 
#the most repeated name in collector and identifier or the only author 
#mentioned in the dataset file name

#Once this previous task is done and the new names are added manually
#we proceed to read the data and rename after
file_names_new <- read.csv("~/R_projects/IberianBees/rawdata/Rename_csvs.csv")
file_names_new <- file_names_new$New_Name #Overwrite with list of new names
  
#Set path name and rename
my_path <- "~/R_projects/IberianBees/rawdata/csvs/"
# Rename files  
file.rename(paste0(my_path, file_names_old),      
            paste0(my_path, file_names_new))            
            
#The file rename has been executed correctly with no mistakes 

           
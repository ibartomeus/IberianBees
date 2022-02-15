
#Read all files and merge into one 
file_names <- dir("Data/Processed_raw_data") #where you have your files
iberian_bees <- do.call(rbind,lapply(paste("Data/Processed_raw_data/", filenames, sep=""),read.csv))




#This script runs all individual scripts to process the data and merge them all

# First Run all individual scripts from "Scripts/Processing_raw_data/"
#and second (Merge all files) in "Data/Processed_raw_data/"

# 1 Run all scripts ----

#Surprisingly it doesn't take much time
#Remember that the online data file has to be updated 1st from fetch data
#This step takes some time and is not included here

#Read all scripts (Just when updating or need it)
sourceEntireFolder <- function(folderName, verbose=FALSE, showWarnings=TRUE) { 
  files <- list.files(folderName, full.names=TRUE)
  
  # Grab only R files
  files <- files[ grepl("\\.[rR]$", files) ]
  
  if (!length(files) && showWarnings)
    warning("No R files in ", folderName)
  
  for (f in files) {
    if (verbose)
      cat("sourcing: ", f, "\n")
    ## TODO:  add caught whether error or not and return that
    try(source(f, local=FALSE, echo=FALSE), silent=!verbose)
  }
  return(invisible(NULL))
}

sourceEntireFolder("Scripts/1_2_Processing_raw_data")

# 2 Merge all files ----
#Read all files and merge into one 
file_names <- dir("Data/Processed_raw_data") #where you have your files

###manually exclude Asensio, which needs further cleaning
file_names <- file_names[-81]
###

iberian_bees_raw <- do.call(rbind,lapply(paste("Data/Processed_raw_data/", file_names, sep=""),read.csv))

#Save as a zip file
write.csv(iberian_bees_raw, file=gzfile("Data/Processing_iberian_bees_raw/iberian_bees_raw.csv.gz"))

#That's it! The Iberianbees dataset has been generated and now it needs a final cleaning

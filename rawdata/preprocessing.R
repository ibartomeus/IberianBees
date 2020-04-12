#This file is internal and converts xls to csv's to make the repo lightweight.
library(openxlsx)
library(filesstrings)

#xls files should be properly names, and with the data in the first sheet.
# Create a vector of Excel files to read
files.to.read = list.files(path = "rawdata/xls_to_add", pattern="xlsx")

# Read each file and write it to csv
lapply(files.to.read, function(f) {
  df = read.xlsx(xlsxFile = paste("rawdata/xls_to_add/",f, sep = ""), sheet=1, detectDates = TRUE)
  write.csv(df, paste("rawdata/", gsub("xlsx", "csv", f), sep = ""), row.names=FALSE)
})

#Note, some (e.g. Serida fail when reading dates...). Use [-x] in this cases.
# Read each file and write it to csv
#lapply(files.to.read[14], function(f) {
#  df = read.xlsx(xlsxFile = paste("rawdata/xls_to_add/",f, sep = ""), sheet=1)
#  write.csv(df, paste("rawdata/", gsub("xlsx", "csv", f), sep = ""), row.names=FALSE)
#})

#move xls's
file.move(files = paste("rawdata/xls_to_add/", files.to.read, sep = ""), 
          destinations = "rawdata/xls_added")


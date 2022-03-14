#This file is internal and converts xls to csv's to make the repo lightweight.
library(openxlsx)
library(filesstrings)

#xls files should be properly named, and with the data in the first sheet.
# Create a vector of Excel files to read
files.to.read = list.files(path = "Rawdata/xls_to_add", pattern="xlsx")

# Read each file and write it to csv
lapply(files.to.read, function(f) {
  df = read.xlsx(xlsxFile = paste("Rawdata/xls_to_add/",f, sep = ""), sheet=1, detectDates = TRUE)
  write.csv(df, paste("Rawdata/csvs/", gsub("xlsx", "csv", f), sep = ""), row.names=FALSE)
})

#Note, some (e.g. Serida, BAC fail when reading dates...). Use [-x] in this cases above.
# And load them with this
#lapply(files.to.read[-x], function(f) {
#  df = read.xlsx(xlsxFile = paste("rawdata/xls_to_add/",f, sep = ""), sheet=1)
#  write.csv(df, paste("rawdata/csvs/", gsub("xlsx", "csv", f), sep = ""), row.names=FALSE)
#})

#move xls's
file.move(files = paste("Rawdata/xls_to_add/", files.to.read, sep = ""), 
          destinations = "Rawdata/xls_added")


[![License](https://licensebuttons.net/l/by/4.0/80x15.png)](https://raw.githubusercontent.com/ibartomeus/IberianBees/master/LICENSE)

*ver version en español más abajo*  

# IberianBees

This is an in progress repo to document Iberian Bees Database (v.0.3.0). You can see a summary of the data [here](https://github.com/ibartomeus/IberianBees/blob/master/Summary.md)      

# How to use this repo  

- If you want to use clean data go to: `data/data_clean.csv`. Metadata can be veiwed [here](http://htmlpreview.github.io/?https://github.com/ibartomeus/IberianBees/blob/master/docs/index.html). If you spot any error, please fill an [issue](https://github.com/ibartomeus/IberianBees/issues) and indicate the uid of the record to fix. If you plan to clean this data further (e.g. dates, localities), let @ibartomeus know to avoid duplicating efforts.

- If you want to fix non recognized species (*blink, blink* -> Thomas), the only data that can be manually altered is `data/manual_checks.csv`. We can move this file via email, and that way you don't need to get into git. If you want to see details on removed specimens, check `data/removed.csv`. If you wish to correct any of those, fill an issue [issue](https://github.com/ibartomeus/IberianBees/issues) and indicate the uid of the record to fix. 

- If you are curious on the process keep reading.

# Process:

1-   Use "rawdata/Fetch_data.R" to update data from interent (e.g. Gbif, iNaturalist)   
2-   Add new excels with data locally to "/rawdata/xls_to_add/" with the data in the first sheet.  
3-   Run "rawdata/preprocessing.R" to convert those to csv and upload them to github.  
3.3- I modified manually some csvs because of non ASCII characters, and other annoying stuff. Sorry for the non-reproducible part.  
4-   Add new csv's programatically using "/rawdata/Add_data.R".  
5-   Use "data/datascript.R" to generate "data/clean_data.csv".  
5.5- To fix species names I am using the workflow in "data/datascript.R" along with "data/manual_checks.csv", which can be edited to add synonims, etc...  
6-   Knit Summary.Rmd to see updated nice summaries.  
7-   Commit and push. Automatic tests may be done (in the future). Manually release a version on major updates.   
8-   Metadata in EML is generated in Metadata_generator.R and can be consulted in "data/metadata"    
9-   The manuscript is written in folder /manuscript

# To Do:

  [x] Download data from Gbif, iNat (as per May 2020).  
  [x] pre-preprocess data contributed by coauthors (as per Aug 2021).  
  [x] read from rawdata, clean and append files to data.   
  [x] Implement manual tests... (datascript.R) 
  [ ] Think on automated testing (e.g. use package CleanR?)
  [x] create summary.
  [o] Think what to do with manual data cleaning? Aim to keep it reproducible in datascript.R   
  [o] Create metadata (in EML? Dataspice?)  
  [ ] Add more data (see below)  
  [o] Write a paper explaining scope, methodology, potential uses. 
  [ ] Recover Lat long from localities (automated)

# Datasets to add

  [x] Species master list  
  [x] Contributors via .xls in "/rawdata" [missing: Curro, Cap de creus, ...]     
  [x] Thomas Wood et al. data (Check data from Ian Cross)  
  [x] Gbif + iNaturalist in Fetch_data.R    
  [o] Historical papers  [MA] 
  [ ] E. Asensio data 
  [o] Museo ciencias Naturales  [Piluca]   
  [ ] Museo bcn [Curro]
  [ ] Other datasets: Felix Torres, Leopoldo Castro, Obeso[x], Aguado, Piluca, Ortiz PDFs ...    




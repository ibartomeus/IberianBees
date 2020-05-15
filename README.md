[![Build Status](https://travis-ci.org/ibartomeus/IberianBees.svg?branch=master)](https://travis-ci.org/ibartomeus/IberianBees)
[![License](http://i.creativecommons.org/p/zero/1.0/88x31.png)](https://raw.githubusercontent.com/ibartomeus/IberianBees/master/LICENSE)

# IberianBees

This is an in progress repo to document Iberian Bees Database (v.0.2.0). You can see a summary of the data [here](https://github.com/ibartomeus/IberianBees/blob/master/Summary.md)      

# How to use this repo  

- If you want to use clean data go to: `data/data_clean.csv`. If you spot any error, please fill an [issue](https://github.com/ibartomeus/IberianBees/issues) and indicate the uid of the record to fix. If you plan to clean this data further (e.g. dates, localities), lat @ibartomeus know to avoid duplicating efforts.

- If you want to fix non recognized species (*blink, blink* -> Thomas), the only data that can be manually altered is `data/manual_checks.csv`. We can move this file via email, and that way you don't need to get into git. If yo want to see details on removed specimens, check `data/removed.csv`. If you wish to correct any of those, fill an issue [issue](https://github.com/ibartomeus/IberianBees/issues) and indicate the uid of the record to fix. 

- If you are curious on the process keep reading.

# Process:

1-   Use "rawdata/Fetch_data.R" to update data from interent (e.g. Gbif, iNaturalist)   
2-   Add new excels in local to "/rawdata/xls_to_add/" with the data in the first sheet.  
3-   Run "rawdata/preprocessing.R" to convert those to csv and upload to github.  
4-   Add new csv's programatically using "/rawdata/Add_data.R".  
5-   Use "data/datascript.R" to generate "data/clean_data.csv".  
5.5- Fix manual things using the workflow in "data/manual_checks.csv"  
6-   Knit Summary.Rmd to see updated nice sumaries.  
7-   Commit and push. Automatic tests will be done (in the future).   

# To Do:

  [x] Download data from Gbif, iNat (as per May 2020).  
  [x] pre-preprocess data contributed by coauthors (as per May 2020).  
  [x] read from rawdata, clean and append files to data.   
  [x] Implement tests... (datascript.R)   
  [x] create summary.
  [o] Think what to do with manual data cleaning? Aim to keep it reproducible in datascript.R   
  [ ] Create metadata (in EML?)  
  [ ] Add more data (see below)  
  [ ] Write a paper explaining scope, methodology, potential uses.  

# Datasets to add

  [x] Species master list (add subgenus?)  
  [x] Contributors via .xls in "/rawdata" [missing: Curro, Cap de creus, ...]     
  [x] Thomas Wood et al. data (Check data from Ian Cross)  
  [x] Gbif + iNaturalist in Fetch_data.R    
  [o] Historical papers  [MA] (more to come, including Asensio)  
  [ ] Museo ciencias Naturales  [Cristina]   
  [ ] Other datasets: Felix Torres, Leopoldo Castro, Obeso[x], Aguado, Piluca, ...    



----------------------
We used this awesome [Template](https://github.com/weecology/livedat) designed to assist in setting up a repository for regularly-updated data. Read [thier PLOS Biology paper](https://doi.org/10.1371/journal.pbio.3000125) for more details. Instructions for creating an updating data workflow can be found at the companion website: [UpdatingData.org](https://www.updatingdata.org/).

[![Build Status](https://travis-ci.org/ibartomeus/IberianBees.svg?branch=master)](https://travis-ci.org/ibartomeus/IberianBees)
[![License](http://i.creativecommons.org/p/zero/1.0/88x31.png)](https://raw.githubusercontent.com/ibartomeus/IberianBees/master/LICENSE)

# IberianBees

This is an in progress repo to document Iberian Bees.   

# Process:

1- Add excels in local to "/rawdata/xls_to_add/" with the data in the first sheet.  
2- Run "rawdata/preprocessing.R"" to convert those to csv.  
3- Add new csv's manually using "/rawdata/Add_data.R".  
4- Use "datascript.R" to clean data and create summaries.
4- Commit and push. Automatic tests will be done on data/data.csv.  

# To Do:

  [x] preprocess data contributed by coauthors 
  [x] read from rawdata, clean and append files to data, manually? Yes.  
  [ ] Add a trusted column to data: if(collector %in% ) or Check by Thomas and create two datastets.    
  [ ] create summary (to readme also?)  
  [ ] Implement tests...  e.g. remove duplicates.
  [ ] What with data cleaning? e.g. Thomas checks Data?  Scripted?  
  [ ] Make a nice map
  
# Datasets to add

  [ ] Contributors via xls in "/rawdata"  
  [ ] Thomas Wood et al.  [talk to Thomas First]
  [ ] Gbif + iNaturalist in ... [easy]
  [ ] Historical papers  [talk Cristina and MA]
  [ ] Museo ciencias Naturales  [Cristina]
  [ ]   




----------------------
We used this awesome [Template](https://github.com/weecology/livedat) designed to assist in setting up a repository for regularly-updated data. Read [thier PLOS Biology paper](https://doi.org/10.1371/journal.pbio.3000125) for more details. Instructions for creating an updating data workflow can be found at the companion website: [UpdatingData.org](https://www.updatingdata.org/).

[![License](https://licensebuttons.net/l/by/4.0/80x15.png)](https://raw.githubusercontent.com/ibartomeus/IberianBees/master/LICENSE)

# IberianBees database v.0.3.0 :bee:

This is a work in progress repository to document the distribution and diversity of bee species of the Iberian Peninsula. You can see a summary of the data [here](https://github.com/ibartomeus/IberianBees/blob/master/Summary.md).   

## How to use this repo  

- The Iberiabees database can be found on: `Data/iberian_bees.csv.gz`. This is a zip file so double click on it to unzip.

- Records with non-accepted names have been excluded of the final dataset but can be found on `Data/Processing_iberian_bees_raw/removed.csv`. Non-accepted names are checked manually with special help of Thomas Wood and will be updated on the list of `Data/Processing_iberian_bees_raw/manual_checks.csv` that automatically will include the corrected records once the file 
`Scripts/3_1Final_cleaning.R` is run again. 

- Please, if you spot any issue or you want to clean this data further, please let @ibartomeus know to avoid duplicating efforts by creating an [issue](https://github.com/ibartomeus/IberianBees/issues) with the corresponding unique identifier (uid) of the record that needs to be fixed.

- If you are curious on the process keep reading.

# Process:

1- Use "rawdata/Fetch_data.R" to update data from interent (e.g. Gbif, iNaturalist).

2- Add new excels with data locally to "/rawdata/xls_to_add/" with the data in the first sheet.  

3- Run "rawdata/preprocessing.R" to convert those to csv and upload them to github.  
3.1- I modified manually some csvs because of non ASCII characters, and other annoying stuff. Sorry for the non-reproducible part.

4- Add new csv's programatically using "/rawdata/Add_data.R".

5- Use "data/datascript.R" to generate "data/clean_data.csv".  
5.1- To fix species names I am using the workflow in "data/datascript.R" along with "data/manual_checks.csv", which can be edited to add synonims, etc...  

6- Knit Summary.Rmd to see updated nice summaries.  

7- Commit and push. Automatic tests may be done (in the future). Manually release a version on major updates.

8- Metadata in EML is generated in Metadata_generator.R and can be consulted in "data/metadata".

9- The manuscript is written in folder /manuscript.

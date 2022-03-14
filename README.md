[![License](https://licensebuttons.net/l/by/4.0/80x15.png)](https://raw.githubusercontent.com/ibartomeus/IberianBees/master/LICENSE)

# IberianBees database v.1.0.0 :bee:

This is a repository to document the distribution and diversity of bee species of the Iberian Peninsula. You can see a summary of the data [here](https://github.com/ibartomeus/IberianBees/blob/Jose_cleaning/Manuscript/Summary/Summary.md).   

## How to contribute:

If you have data on Iberian bee's occurrence, fill in this [template](https://github.com/ibartomeus/IberianBees/Data/IBD_template.odt) and send it to nacho.bartomeus@gmail.com

## How to use this repo  

- The IberianBees database can be found on: `Data/iberian_bees.csv.gz`. This is a zip file so double click on it to unzip.

- Metadata can be consulted here: https://rawcdn.githack.com/ibartomeus/IberianBees/Jose_cleaning/docs/index.html

- Records with non-accepted names on the Iberian bee species masterlist have been excluded of the final dataset but can be found on `Data/Processing_iberian_bees_raw/removed.csv`. 

- Please, if you spot any issue, please let @ibartomeus know to avoid duplicating efforts by creating an [issue](https://github.com/ibartomeus/IberianBees/issues) with the corresponding unique identifier (uid) of the record that needs to be fixed.

- If you are curious on the process keep reading.

# Process:

To build this database, we follow a reproducible workflow to clean and ensemble the data.  

1- Use `Scripts/1_1_Fetch_data.R` to update data from internet (i.e. Gbif, iNaturalist).

2- Add new datasets (i.e. csv files) locally to `Data/Rawdata/csvs/`.

3- Process and clean individual files and assign a unique identifier within the folder `Scripts/1_2_Processing_raw_data/`.

4- Run `Scripts/2_Run_all-Merge_all.R`. This will run all individual files in `Scripts/1_2_Processing_raw_data/`and bind the data. The data can be merged directly without running all files by running the second section of the code "2 Merge all files".

5- Conduct a final cleaning (things that weren't fixed on the individual files on step 3). This is done in `Scripts/3_1_Final_cleaning.R` and will generate the final dataset `Data/iberian_bees.csv.gz`.

5.1- Non accepted species are excluded and saved on `Data/Processing_iberian_bees_raw/removed.csv`. 

5.2- The non-accepted species names (e.g., synonyms) are checked manually from `Data/Processing_iberian_bees_raw/to_check.csv` and added to `Data/Processing_iberian_bees_raw/manual_checks.csv` once they have been reviewed with taxonomic advice when necessary.  After running `Scripts/3_1_Final_cleaning.R` the fixed species will be included on the final Iberianbees dataset.

![plot](Manuscript/Summary/summary_repo.png)

Metadata is generated using DataSpice.

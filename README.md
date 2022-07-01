[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.6354502.svg)](https://doi.org/10.5281/zenodo.6354502)
[![License: CC BY 4.0](https://img.shields.io/badge/License-CC_BY_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

# IberianBees database v.1.0.0 :bee:

This is a repository to document the distribution and diversity of bee species of the Iberian Peninsula. You can see a summary of the data [here](https://github.com/ibartomeus/IberianBees/blob/master/Manuscript/Summary/Summary.md).   

## How to contribute:

If you have data on Iberian bee's occurrence, fill in this [template](https://github.com/ibartomeus/IberianBees/blob/master/Add_New_Data_Template_English_Version.xlsx) and send it to nacho.bartomeus@gmail.com

## How to use this repo  

- The IberianBees database can be found on: `Data/iberian_bees.csv.gz`. This is a zip file so double click on it to unzip.

- Metadata can be consulted [here](https://rawcdn.githack.com/ibartomeus/IberianBees/65a387dca56829a7b3b6d00661eba64394b4ef8e/Data/metadata/index.html). 


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

Metadata is generated using [DataSpice](https://github.com/ropensci/dataspice).

![](Manuscript/Summary/summary_repo.png)

# Example:

Here, we provide an example of how to select, filter and plot the distribution of the species _Xylocopa violacea_ for the records after the year 1999.

- First, read compressed data in gzip format:
```r
data <- read.table("../Data/iberian_bees.csv.gz", 
header = T, quote = "\"", sep = ",",row.names=1)
```
- Second, select records of _X. violacea_ after 1999

```r
library(dplyr) #Library to filter data
xylocopa <- data %>% filter(Accepted_name == "Xylocopa violacea" & Year > 1999)
```
- Finally, load map and plot records:

```r
library(ggplot2) #to load worldmap and plotting
#Load map
world <- map_data("world")
#Plot records and adjust map to the Iberian Peninsula
ggplot(data = xylocopa, aes(Longitude, Latitude)) +
geom_map(data = world, map = world,
aes(long, lat, map_id = region), color = "white", fill = "grey", size = 0.1) +
coord_sf(xlim = c(-9, 4), ylim = c(36, 44)) +
geom_point() 
```

![](Manuscript/Summary/xylocopa_map.png)



library(tidyverse)
library(ggplot2)
library(data.table)
data <- read.table("Data/iberian_bees.csv.gz",  header=T, quote="\"", sep=",")

#Prepare data
data$Longitude <- as.numeric(data$Longitude)
data$Latitude <- as.numeric(data$Latitude)
data <- data %>% filter(!is.na(Latitude) & !is.na(Longitude))
#Filter points in Spain
data$Country_1 <- NA
data$Country_1 <- maps::map.where(x = data$Longitude, y = data$Latitude)
data <- data %>% filter(Country_1=="Spain")

#City by autonomous community
#1
andalucia <- c("Almería", "Cádiz", "Córdoba", "Granada",
              "Huelva", "Jaén", "Málaga", "Sevilla")
#2
aragon <- c("Huesca", "Teruel", "Zaragoza")
#3
asturias <- c("Asturias")
#4
baleares <- c("Balears, Illes")
#5Canarias not considered here
#6
cantabria <- c("Cantabria")
#7
castilla_leon <- c("Ávila", "Burgos", "León", "Palencia",
                   "Salamanca", "Segovia", "Soria", "Valladolid",
                   "Zamora")
#8
castilla_la_mancha <- c("Albacete", "Ciudad Real", "Cuenca",
                        "Guadalajara", "Toledo")

#9
cataluna <- c("Barcelona", "Girona", "Lleida", "Tarragona")

#10
comunidad_valenciana <- c("Alicante/Alacant", "Castellón/Castelló",
                        "Valencia/València")
#11
extremadura <- c("Badajoz", "Cáceres")
#12
galicia <- c("Coruña, A", "Lugo", "Ourense", "Pontevedra")
#13
comunidad_madrid <- c("Madrid")
#14
region_murcia <- c("Murcia")
#15
comunidad_foral_navarra <- c("Navarra")
#16
pais_vasco <- c("Araba/Álava", "Bizkaia", "Gipuzkoa")
#17
la_rioja <- c("Rioja, La")
#No included ceuta and melilla

spanish_communities <- list(andalucia, aragon, asturias, baleares, cantabria, castilla_leon,
     castilla_la_mancha, cataluna, comunidad_valenciana,
     extremadura, galicia, comunidad_madrid, region_murcia,
     comunidad_foral_navarra, pais_vasco, la_rioja)

sc <- c("andalucia", "aragon", "asturias", "baleares", "cantabria", "castilla_leon",
"castilla_la_mancha", "cataluna", "comunidad_valenciana",
"extremadura", "galicia", "comunidad_madrid", "region_murcia",
"comunidad_foral_navarra", "pais_vasco", "la_rioja")

#Now try to loop to extract the first 10 records of each element

list_communities = list()

for(i in 1:16){

  d <- data %>% filter(!accepted_name=="Apis mellifera") %>% 
  filter(Province %in% spanish_communities[[i]])
  
  top_10 <- d %>% group_by(accepted_name) %>%
    summarise(no_rows = length(accepted_name)) %>% 
    arrange(-no_rows) %>% slice(1:10)
  
  colnames(top_10) <- c("Species_name", "Number_of_records")
  
  list_communities[[i]] <- top_10
  
  names(list_communities)[[i]] <- sc[i]
  
  filename = paste0("Side_projects/Top_50_species/Top_10_by_community/", 
  names(list_communities)[[i]], ".csv")
  
  write.csv(list_communities[[i]], filename, row.names = F)

}

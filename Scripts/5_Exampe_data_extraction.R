
#Ejemplo de cómo extraer datos de Iberianbees

#Leemos los datos que se encuentran comprimidos en formato gzip ".gz"
data <- read.table("Data/iberian_bees.csv.gz", header = T, quote = "\"", sep = ",",row.names=1)

#Seleccionamos los registros de la especie Xylocopa violacea y
#filtramos todos los registros posteriores al año 1999
xylocopa <- data %>% dplyr::filter(Accepted_name == "Xylocopa violacea") %>%
filter(Year > 1999)

#Finalmente exploramos la distribución espacial de estos registros
#Para ello cargamos la librería "ggspatial" que contiene un mapa del mundo
library(ggspatial)
world <- map_data("world")

#Ploteamos los registros, y ajustamos a las coordenadas de la península
library(ggplot2)
ggplot(data=xylocopa, aes(Longitude, Latitude)) +
geom_map(data = world, map = world,
aes(long, lat, map_id = region), color = "white", fill = "grey", size = 0.1) +
coord_sf(xlim = c(-9, 4), ylim = c(36, 44)) +
geom_point() 
  

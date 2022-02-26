[![License](https://licensebuttons.net/l/by/4.0/80x15.png)](https://raw.githubusercontent.com/ibartomeus/IberianBees/master/LICENSE)

# Iberianbees database :bee: (English version)

This is an in progress repository to document the Iberian Bees Database (v.0.3.0). You can see a summary of the data [here](https://github.com/ibartomeus/IberianBees/blob/master/Summary.md).   

## How to use this repo  

- If you want to use clean data go to: `data/data_clean.csv`. Metadata can be viewed [here](http://htmlpreview.github.io/?https://github.com/ibartomeus/IberianBees/blob/master/docs/index.html). If you spot any error, please fill an [issue](https://github.com/ibartomeus/IberianBees/issues) and indicate the uid of the record to fix. If you plan to clean this data further (e.g. dates, localities), let @ibartomeus know to avoid duplicating efforts.

- If you want to fix non recognized species (*blink, blink* -> Thomas), the only data that can be manually altered is `data/manual_checks.csv`. We can move this file via email, and that way you don't need to get into git. If you want to see details on removed specimens, check `data/removed.csv`. If you wish to correct any of those, fill an issue [issue](https://github.com/ibartomeus/IberianBees/issues) and indicate the uid of the record to fix. 

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

# Iberianbees database :bee: (versión en español)

Este es un repositorio en curso para documentar la Base de Datos de Abejas Ibéricas (v.0.3.0). Puedes ver un extracto de estos datos [aquí](https://github.com/ibartomeus/IberianBees/blob/master/Summary.md).

# ¿Cómo usar este repositorio?

- Para usar los datos ya procesados ir a: `data/data_clean.csv`. Los metadatos pueden ser visualizados [aquí](http://htmlpreview.github.io/?https://github.com/ibartomeus/IberianBees/blob/master/docs/index.html). En el caso de detectar algún error, este puede ser informado mediante un [issue](https://github.com/ibartomeus/IberianBees/issues) con el identificador único (uid) del dato en cuestión. En el caso de que estos datos vayan a ser procesados o limpiados  (p. ej. fechas, localidades, coordenadas, etc) aún más, por favor notifíquenlo a @ibartomeus para evitar duplicar esfuerzos de procesamiento de datos.

- Para arreglar las especies no reconocidas, el único archivo que puede ser manualmente alterado es `data/manual_checks.csv`. Este archivo se podrá mandar via mail y así evitar tener que trabajar desde dentro del repositorio. Las especies no incluidas pueden ser consultadas en el archivo `data/removed.csv`. Para realizar correcciones en cualquiera de estos archivos, por favor rellenar un [issue](https://github.com/ibartomeus/IberianBees/issues) e indicad el identificador único del registro (uid).

- Más información de como estos datos son procesados es mostrada a continuación.

# Procesado:

1- Usar "rawdata/Fetch_data.R" para actualizar datos desde internet (e.g. Gbif, iNaturalist).

2- Añadir nuevos excels localmente a "/rawdata/xls_to_add/" con los datos ubicados en la primera hoja.  

3- Correr script "rawdata/preprocessing.R" para convertir estos a csv y subirlos a github. 
3.1- Algunos csv han tenido que ser modificados manualmente debido a la presencia de caracteres no ASCII y otros elementos que dificultaban su procesamiento. Disculpad por este apartado no reproducible.

4- Añadir csv's de manera programática usando "/rawdata/Add_data.R". 

5- Usar "data/datascript.R" para generar "data/clean_data.csv".  
5.1- Los nombres de las especies han sido arreglados con "data/datascript.R" junto con "data/manual_checks.csv", estos pueden ser editados para evitar sinónimos o cualquier otra incorrección.

6- Knit Summary.Rmd para ver un resumen actualizado.

7- Guardar y subir a github. Test automáticos quizás puedan ser incorporados en el futuro. Manualmente hacer pública la nueva versión con estas actualizaciones.

8- Los metadatos en EML han sido generados en el script Metadata_generator.R y pueden ser encontrados en "data/metadata".

9- El manuscrito se encuentra en /manuscript.


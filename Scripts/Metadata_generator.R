# Metadata is created using dataspice ----

#RUN JUST ONCE! As involves manual data entry via shiny apps.
#install.packages("dataspice")
library(dataspice)
create_spice() #creates metadata directory
# Then fill in template CSV files, more on this below
files <- "~/Documents/R/IberianBees/data/data_clean.csv"
attributes_path <- file.path("data", "metadata", "attributes.csv")
files %>%
  purrr::map(~ prep_attributes(.x, attributes_path),
             attributes_path = attributes_path
  )
edit_attributes()
edit_access()
edit_creators()
edit_biblio()

write_spice() #creates Json Original name is dataspice.json. Manually renamed to IBD.json

build_site() # Optional

#create EML (and validate it)
IBD_json <-  "~/Documents/R/IberianBees/data/metadata/IBD.json"
eml_doc <- spice_to_eml(IBD_json)
library(EML)
eml_validate(eml_doc)
eml_doc$packageId <- uuid::UUIDgenerate()
eml_doc$system <- "uuid"
eml_validate(eml_doc) #need to fix those...

#write EML
write_eml(eml_doc, "data/metadata/IBD.xml")









# I also explored EML package... but this is not used, IGNORE-----

#install.packages("EML")
library(EML)

#schema
# - eml
#   - dataset
#   - creator
#   - title
#   - publisher
#   - pubDate
#   - keywords
#   - abstract 
#   - intellectualRights
#   - contact
#   - methods
#   - coverage
#     - geographicCoverage
#     - temporalCoverage
#     - taxonomicCoverage
#   - dataTable
#     - entityName
#     - entityDescription
#     - physical
#     - attributeList

#minimal example
au <- list(individualName = list(givenName = "Ignasi", surName = "Bartomeus"))
IBD_eml <- list(dataset = list(
  title = "Iberian Bees Database",
  creator = au,
  contact = au)
)
#

#more
geographicDescription <- "Iberian peninsula"
coverage <- 
  set_coverage(begin = '2012-06-01', end = '2013-12-31', #update
               sci_names = "Apoidea",
               geographicDescription = geographicDescription,
               west = -122.44, east = -117.15, #update
               north = 37.38, south = 30.00, #update
               altitudeMin = 160, altitudeMaximum = 330, #update
               altitudeUnits = "meter") #update
methods <- set_methods()
eml$creator()

my_eml <- eml$eml(
  packageId = uuid::UUIDgenerate(),  
  system = "uuid",
  dataset = eml$dataset(
    title = "Iberian Bees Database",
    creator = au,
    pubDate = "2021",
    intellectualRights = "CC-by",
    abstract = abstract,
    keywordSet = keywordSet,
    coverage = coverage,
    contact = contact,
    methods = methods,
    dataTable = eml$dataTable(
      entityName = "clean_data.csv",
      entityDescription = "",
      physical = physical,
      attributeList = attributeList)
  ))


eml_validate(IBD_eml)
#write_eml(IBD_eml, "IBD.xml")




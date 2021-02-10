#Test EML

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
write_eml(IBD_eml, "IBD.xml")


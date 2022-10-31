master <- read.csv(file = "Data/Processing_iberian_bees_raw/Iberian_species_masterlist.csv")
head(master)

master$Authority

library(cleanR)
help_species()
author <- c()
year <- c()
temp <- strsplit(x = master$Authority, split = ',') 
for (i in 1:length(master$Authority)){
  author[i] <- temp[[i]][1]
  year[i] <- temp[[i]][2]
}
year
master[364,]
master[963,]
year <- gsub(pattern = ')', '', year)
year <- as.numeric(year)

author <- gsub(pattern = '(', '', author, fixed = TRUE)
author <- gsub(pattern = ')', '', author, fixed = TRUE)
author <- gsub(pattern = "[[:digit:]]+", '', author)
author <- trimws(author)

#Alternative
matches <- regmatches(master$Authority, gregexpr("[[:digit:]]+", master$Authority))
year <- as.numeric(unlist(matches))


plot(as.numeric(cumsum(table(year))) ~ as.numeric(names(table(year))),
     las = T, type = "l", ylab = "species described", xlab = "year")

barplot(tail(sort(table(author)), 20), las = 2, cex.names = 0.5)
        
library(tidyverse)
library(ggplot2)
library(data.table)
data <- read.table("Data/iberian_bees.csv.gz",  header=T, quote="\"", sep=",")
#Prepare top 50 records
top_50 <- data %>% filter(!accepted_name=="Apis mellifera") %>% group_by(accepted_name) %>%
  summarise(no_rows = length(accepted_name)) %>% 
  arrange(-no_rows) %>% slice(1:50)
#Fix row position
top_50$accepted_name <- factor(top_50$accepted_name, levels = top_50$accepted_name)

#Plot
ggplot(top_50, aes(x=accepted_name, y=no_rows)) + 
  geom_bar(stat = "identity", fill="#287D8EFF") +
  theme_classic()+
  theme(axis.text.x=element_text(angle=45, hjust=1, size=5, face = "italic")) +
  ylab("Number of records") + 
  xlab("Species") + scale_y_continuous(expand = c(0, 0)) +
  ggtitle("Top 50 Species")

#Save list of top 50 species
colnames(top_50) <- c("Species_name", "Number_of_records")
#Save data
write_csv(top_50, "Side_projects/Top_50_species/top_50_iberian_peninsula.csv")


library(testthat)
library(tidyverse)
library(readr)

context("checks that the values of field_level template meet our requirements")


# Test the features of datasets

# Right labels (dataframe's labels are equal to those of "field_level_data" template)
# Right number of columns (dataframe's number of columns is equal to that of "field_level_data" template)
# All studies are identified (Study_ID is not NA)
# All sites are identified (Site_ID is not NA)
# Single study-site IDs (no duplication of study_ID+site_ID)
# Sampling start month format (integer number between 1 and 12)
# Sampling end month format (integer number between 1 and 12)
# REMOVED: Year format (integer greater that 1900)
# REMOVED: Yield (non-negative number or NA)
# Mean fruits per plant format (non-negative number or NA)
# Fruit weight format (non-negative number or NA)
# Plant density format (non-negative number or NA)
# Field size format (non-negative number or NA)
# Pollinator richness format (non-negative number or NA)
# Abundance format (non-negative number or NA)
# Honeybees abun. format (non-negative number or NA)
# Bombus abun. format (non-negative number or NA)
# Wild bees abun. format (non-negative number or NA)
# Syrphids abun. format  (non-negative number or NA)
# Humbleflies abun. format  (non-negative number or NA)
# Other_flies abun. format  (non-negative number or NA)
# Beetles abun. format  (non-negative number or NA)
# Lepidoptera abun. format  (non-negative number or NA)
# Non bee hymenoptera abun. format  (non-negative number or NA)
# Others abun. format (non-negative number or NA)
# Transect area format (non-negative number or NA)
# Transect time format (non-negative number or NA)
# Total vis. rate format (non-negative number or NA)
# Honeybees vis. rate format (non-negative number or NA)
# Bombus vis. rate format (non-negative number or NA)
# Wild bees vis. rate format (non-negative number or NA)
# Syrphids vis. rate format (non-negative number or NA)
# Humbleflies vis. rate format  (non-negative number or NA)
# Other_flies vis. rate format  (non-negative number or NA)
# Beetles vis. rate format  (non-negative number or NA)
# Lepidoptera vis. rate format  (non-negative number or NA)
# Non bee hymenoptera abun. format  (non-negative number or NA)
# Others vis. rate format (non-negative number or NA)


labels_OK <- c("study_id","site_id","crop","variety","management","country","latitude",
               "longitude","X_UTM","Y_UTM","zone_UTM","sampling_start_month",
               "sampling_end_month","sampling_year","field_size","yield","yield_units",
               "yield2","yield2_units","yield_treatments_no_pollinators",
               "yield_treatments_pollen_supplement","yield_treatments_no_pollinators2",
               "yield_treatments_pollen_supplement2","fruits_per_plant","fruit_weight",
               "plant_density","seeds_per_fruit","seeds_per_plant","seed_weight",
               "pollinator_richness","richness_estimator_method","abundance",
               "ab_honeybee","ab_bombus","ab_wildbees","ab_syrphids","ab_humbleflies",
               "ab_other_flies","ab_beetles","ab_lepidoptera","ab_nonbee_hymenoptera",
               "ab_others","total_sampled_area","total_sampled_time","visitation_rate_units",
               "visitation_rate","visit_honeybee","visit_bombus","visit_wildbees",
               "visit_syrphids","visit_humbleflies","visit_other_flies","visit_beetles",
               "visit_lepidoptera","visit_nonbee_hymenoptera","visit_others","Publication",
               "Credit","Email_contact")       




exp_column_number <- length(labels_OK)

folder_base <- "../Datasets_storage"
files_base <- list.files(folder_base)
list_files_field_level <- files_base[grepl("field_level_data", files_base)]

for (i in seq(length(list_files_field_level))) {
  
  file_field_level_i <- paste(folder_base, list_files_field_level[i], sep = "/")
  field_level_i <- read_csv(file_field_level_i,
                            col_types = cols(
                              study_id = col_character(),
                              site_id = col_character(),
                              crop = col_character(),
                              variety = col_character(),management = col_character(),
                              country = col_character(),latitude = col_double(),
                              longitude = col_double(),X_UTM = col_double(),
                              Y_UTM = col_double(),#zone_UTM = col_double(),
                              sampling_start_month = col_double(),
                              sampling_end_month = col_double(),
                              field_size = col_double(),#sampling_year = col_double(),
                              yield = col_double(),
                              yield_units = col_character(),
                              yield2 = col_double(),yield2_units = col_character(),
                              yield_treatments_no_pollinators = col_double(),
                              yield_treatments_pollen_supplement = col_double(),
                              yield_treatments_no_pollinators2 = col_double(),
                              yield_treatments_pollen_supplement2 = col_double(),
                              fruits_per_plant = col_double(),fruit_weight = col_double(),
                              plant_density = col_double(),seeds_per_fruit = col_double(),
                              seeds_per_plant = col_double(),seed_weight = col_double(),
                              pollinator_richness = col_double(),
                              richness_estimator_method = col_character(),
                              abundance = col_double(),ab_honeybee = col_double(),
                              ab_bombus = col_double(),ab_wildbees = col_double(),
                              ab_syrphids = col_double(),ab_humbleflies = col_double(),
                              ab_other_flies = col_double(),ab_beetles = col_double(),
                              ab_lepidoptera = col_double(),ab_nonbee_hymenoptera = col_double(),
                              ab_others = col_double(),total_sampled_area = col_double(),
                              total_sampled_time = col_double(),
                              visitation_rate_units = col_character(),
                              visitation_rate = col_double(),visit_honeybee = col_double(),
                              visit_bombus = col_double(),visit_wildbees = col_double(),
                              visit_syrphids = col_double(),visit_humbleflies = col_double(),
                              visit_other_flies = col_double(),visit_beetles = col_double(),
                              visit_lepidoptera = col_double(),visit_nonbee_hymenoptera = col_double(),
                              visit_others = col_double(),
                              Publication = col_character(),
                              Credit = col_character(),Email_contact = col_character()))
  
  test_name_i <- paste("Right labels:", list_files_field_level[i], sep = " ")
  
  test_that(test_name_i,{
    
    labels_i <- labels(field_level_i)[[2]]
    expect_equal(labels_i, labels_OK)
    
    
  })
  
  
  test_name_i <- paste("Study identified:", list_files_field_level[i], sep = " ")
  
  test_that(test_name_i,{
    
    
    studyID_i <- any(is.na(field_level_i$study_id))
    expect_equal(studyID_i, FALSE)
  })
  
  test_name_i <- paste("All sites are identified:", list_files_field_level[i], sep = " ")
  
  test_that(test_name_i,{
    
    fieldID_i <- any(is.na(field_level_i$site_id))
    expect_equal(fieldID_i, FALSE)
  })
  
  test_name_i <- paste("Single study-site IDs:", list_files_field_level[i], sep = " ")
  
  test_that(test_name_i,{
    
    ID_i <- field_level_i %>% select(study_id,site_id)
    expect_equal(any(duplicated(ID_i)), FALSE)
  })
  
  test_name_i <- paste("Start month format:", list_files_field_level[i], sep = " ")
  
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$sampling_start_month)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$sampling_start_month[!NA_values]
      expect_equal(all(1 <= values_pos_i) & all(values_pos_i <= 12) &
                     all(values_pos_i%%1==0), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  test_name_i <- paste("End month format:", list_files_field_level[i], sep = " ")
  
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$sampling_end_month)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$sampling_end_month[!NA_values]
      expect_equal(all(1 <= values_pos_i) & all(values_pos_i <= 12) &
                     all(values_pos_i%%1==0), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
  # There are datasets whose year reads "2011-2012" (such as clas01)
  
  #test_name_i <- paste("Year format:", list_files_field_level[i], sep = " ")
  
  #test_that(test_name_i,{
  
  #  NA_values <- is.na(field_level_i$sampling_year)
  #  if(all(NA_values) == FALSE){
  #    values_pos_i <- field_level_i$sampling_year[!NA_values]
  #    expect_equal(all(1900 <= values_pos_i) & all(values_pos_i%%1==0), TRUE)
  
  #  }else{
  #    expect_equal(TRUE, TRUE)
  #  }
  #})
  
  #test_name_i <- paste("0 <= Yield :", list_files_field_level[i], sep = " ")
  
  #test_that(test_name_i,{
  
  #  NA_values <- is.na(field_level_i$yield)
  #  if(all(NA_values) == FALSE){
  #    values_pos_i <- field_level_i$yield[!NA_values]
  #    expect_equal(all(0 <= values_pos_i), TRUE)
  
  #  }else{
  #    expect_equal(TRUE, TRUE)
  #  }
  #})
  
  #test_name_i <- paste("0 <= Yield2 :", list_files_field_level[i], sep = " ")
  
  #test_that(test_name_i,{
  
  #  NA_values <- is.na(field_level_i$yield2)
  #  if(all(NA_values) == FALSE){
  #    values_pos_i <- field_level_i$yield2[!NA_values]
  #    expect_equal(all(0 <= values_pos_i), TRUE)
  
  #  }else{
  #    expect_equal(TRUE, TRUE)
  #  }
  #})
  
  
  # test_name_i <- paste("0 <= yield_treatments_no_pollinators :", list_files_field_level[i], sep = " ")
  # 
  # test_that(test_name_i,{
  #   
  #   NA_values <- is.na(field_level_i$yield_treatments_no_pollinators)
  #   if(all(NA_values) == FALSE){
  #     values_pos_i <- field_level_i$yield_treatments_no_pollinators[!NA_values]
  #     expect_equal(all(0 <= values_pos_i), TRUE)
  #     
  #   }else{
  #     expect_equal(TRUE, TRUE)
  #   }
  # })
  
  
  # test_name_i <- paste("0 <= yield_treatments_pollen_supplement :", list_files_field_level[i], sep = " ")
  # 
  # test_that(test_name_i,{
  #   
  #   NA_values <- is.na(field_level_i$yield_treatments_pollen_supplement)
  #   if(all(NA_values) == FALSE){
  #     values_pos_i <- field_level_i$yield_treatments_pollen_supplement[!NA_values]
  #     expect_equal(all(0 <= values_pos_i), TRUE)
  #     
  #   }else{
  #     expect_equal(TRUE, TRUE)
  #   }
  # })
  # 
  # 
  # test_name_i <- paste("0 <= yield_treatments_no_pollinators2 :", list_files_field_level[i], sep = " ")
  # 
  # test_that(test_name_i,{
  #   
  #   NA_values <- is.na(field_level_i$yield_treatments_no_pollinators2)
  #   if(all(NA_values) == FALSE){
  #     values_pos_i <- field_level_i$yield_treatments_no_pollinators2[!NA_values]
  #     expect_equal(all(0 <= values_pos_i), TRUE)
  #     
  #   }else{
  #     expect_equal(TRUE, TRUE)
  #   }
  # })
  # 
  # 
  # 
  # test_name_i <- paste("0 <= yield_treatments_pollen_supplement2 :", list_files_field_level[i], sep = " ")
  # 
  # test_that(test_name_i,{
  #   
  #   NA_values <- is.na(field_level_i$yield_treatments_pollen_supplement2)
  #   if(all(NA_values) == FALSE){
  #     values_pos_i <- field_level_i$yield_treatments_pollen_supplement2[!NA_values]
  #     expect_equal(all(0 <= values_pos_i), TRUE)
  #     
  #   }else{
  #     expect_equal(TRUE, TRUE)
  #   }
  # })
  
  
  test_name_i <- paste("Mean fruits per plant format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$fruits_per_plant)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$fruits_per_plant[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
  test_name_i <- paste("Fruit weight format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$fruit_weight)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$fruit_weight[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
  test_name_i <- paste("Plant density format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$plant_density)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$plant_density[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
  
  test_name_i <- paste("seeds_per_fruit format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$seeds_per_fruit)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$seeds_per_fruit[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  test_name_i <- paste("seeds_per_plant format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$seeds_per_plant)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$seeds_per_plant[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  test_name_i <- paste("seed_weight:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$seed_weight)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$seed_weight[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
  test_name_i <- paste("Field size format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$field_size)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$field_size[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
  
  test_name_i <- paste("Pollinator richness format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$pollinator_richness)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$pollinator_richness[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  ################
  
  
  test_name_i <- paste("Abundance format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$abundance)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$abundance[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
  
  test_name_i <- paste("Honeybees abun. format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$ab_honeybee)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$ab_honeybee[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
  test_name_i <- paste("Bombus abun. format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$ab_bombus)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$ab_bombus[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
  
  test_name_i <- paste("Wild bees abun. format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$ab_wildbees)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$ab_wildbees[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  test_name_i <- paste("Syrphids abun. format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$ab_syrphids)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$ab_syrphids[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
  test_name_i <- paste("Others abun. format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$ab_others)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$ab_others[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  test_name_i <- paste("Humbleflies abun. format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$ab_humbleflies)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$ab_humbleflies[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
  test_name_i <- paste("Other flies abun. format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$ab_other_flies)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$ab_other_flies[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
  test_name_i <- paste("Beetles abun. format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$ab_beetles)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$ab_beetles[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
  test_name_i <- paste("Lepidoptera abun. format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$ab_lepidoptera)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$ab_lepidoptera[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
  test_name_i <- paste("Non-bee hymenoptera abun. format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$ab_nonbee_hymenoptera)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$ab_nonbee_hymenoptera[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
  #########
  
  test_name_i <- paste("Total sampled area format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$total_sampled_area)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$total_sampled_area[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  test_name_i <- paste("Total sampled time format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$total_sampled_time)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$total_sampled_time[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  ##################
  
  
  test_name_i <- paste("Vis. rate format:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$visitation_rate)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$visitation_rate[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  test_name_i <- paste("Honeybees vis. rate:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$visit_honeybee)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$visit_honeybee[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  test_name_i <- paste("Bombus vis. rate:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$visit_bombus)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$visit_bombus[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
  test_name_i <- paste("Wild bees vis. rate:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$visit_wildbees)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$visit_wildbees[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
  test_name_i <- paste("Syrphids vis. rate:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$visit_syrphids)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$visit_syrphids[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
  test_name_i <- paste("Humbleflies vis. rate:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$visit_humbleflies)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$visit_humbleflies[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
  test_name_i <- paste("Other flies vis. rate:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$visit_other_flies)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$visit_other_flies[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
  test_name_i <- paste("Beetles vis. rate:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$visit_beetles)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$visit_beetles[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  test_name_i <- paste("Lepidoptera vis. rate:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$visit_lepidoptera)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$visit_lepidoptera[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  test_name_i <- paste("Non bee hymenoptera vis. rate:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$visit_nonbee_hymenoptera)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$visit_nonbee_hymenoptera[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  test_name_i <- paste("Others vis. rate:", list_files_field_level[i], sep = " ")
  test_that(test_name_i,{
    
    NA_values <- is.na(field_level_i$visit_others)
    if(all(NA_values) == FALSE){
      values_pos_i <- field_level_i$visit_others[!NA_values]
      expect_equal(all(0 <= values_pos_i), TRUE)
      
    }else{
      expect_equal(TRUE, TRUE)
    }
  })
  
  
}
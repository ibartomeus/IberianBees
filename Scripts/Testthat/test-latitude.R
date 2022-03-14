library(testthat)
library(dplyr)
context("checks that period values are valid")

base_data <- read.csv('../data/occurences.csv',
                      stringsAsFactors = F)

test_that("period numbers are valid", { #e.g change!
  
  expect_true(all(base_data$period < 1000)) #e.g. change!
  
})
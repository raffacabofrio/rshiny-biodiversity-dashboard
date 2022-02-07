library(testthat)

source("functions/as.named.R")
source("functions/getScientificName.R")
source("functions/getImageUrl.R")


test_that("ShouldHaveValidNamedVector", {
  
  people      <- data.frame(id = c(1, 2, 3), name = c("Raffa", "Camila", "Paulina"))
  peopleNamed <- as.named(people, "id", "name")
  
  outputLength         <- length(peopleNamed)
  outputLengthExpected <- 4
  
  outputFirstValue         <- as.character(peopleNamed[1])
  outputFirstValueExpected <- ""
  
  outputFirstName <- names(peopleNamed)[1]
  outputFirstNameExpected <- "Select"
  
  outputLastValue         <- as.character(peopleNamed[4])
  outputLastValueExpected <- "3"
  
  outputLastName         <- names(peopleNamed)[4]
  outputLastNameExpected <- "Paulina"
  
  
  expect_equal(outputLength,     outputLengthExpected)
  expect_equal(outputFirstValue, outputFirstValueExpected)
  expect_equal(outputFirstName,  outputFirstNameExpected)
  expect_equal(outputLastValue,  outputLastValueExpected)
  expect_equal(outputLastName,   outputLastNameExpected)
})


test_that("ShouldHaveOnlyScientificName", {
  
  input          <- "Acanthagenys rufogularis ( Spiny-cheeked Honeyeater )"
  expectedOutput <- "Acanthagenys rufogularis"
  output         <- getScientificName(input)
  
  expect_equal(output, expectedOutput)
  
  
  input          <- "Macaco"
  expectedOutput <- "Macaco"
  output         <- getScientificName(input)
  
  expect_equal(output, expectedOutput)
})


test_that("ShouldGetImageUrl", {
  
  url <- getImageUrl("Macaco")
  classOutput    <- class(url)
  NotEmptyOutput <- nchar(url) > 0
  
  classOutputExpected    <- "character"
  NotEmptyOutputExpected <- TRUE
  
  expect_equal(classOutput, classOutputExpected)
  expect_equal(NotEmptyOutput, NotEmptyOutputExpected)
  
})






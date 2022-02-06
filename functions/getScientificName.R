getScientificName <- function(specieFullName) {
  
  hasVernacularName <- grepl( "(", specieFullName, fixed = TRUE)
  
  if(!hasVernacularName){
    return(specieFullName)
  }
  
  name <- strsplit(specieFullName, "(", fixed = TRUE)[[1]][1]
  name <- substr(name, 0,  nchar(name) -1)
  return(name)
}

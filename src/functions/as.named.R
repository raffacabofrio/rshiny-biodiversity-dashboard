as.named <- function(data, id, description) {
  
  dataNamed <- as.character(get(id, data))
  names(dataNamed) <- get(description, data)
  dataNamed <- c( "Select" = "", dataNamed  )
  return(dataNamed)
  
}
getConfig <- function(key, defaultValue) {
  
  value <- Sys.getenv(key)
  if(value == "") value = defaultValue
  return(value)
  
}
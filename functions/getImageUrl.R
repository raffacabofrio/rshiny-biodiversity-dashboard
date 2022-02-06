getImageUrl <- function(search){
  
  search <- gsub(" ", "+", search)
  page <- read_html(paste("https://www.google.com/search?q=", search, "&tbm=isch", sep = ""))
  node <- html_nodes(page,xpath = '//img')
  src <-  html_attr(node,"src")
  return(src[2])
  
}

getImageUrl("macaco")
getImageUrl("Acanthagenys rufogularis")

dbQuery <- function( sql ) {
  
  # TODO SECURITY: get from OS env vars
  con <- dbConnect(RPostgres::Postgres(), dbname = "dashboard", host="127.0.0.1", port=5432, user="postgres", password="goku123") 
  result <- dbGetQuery(con, sql) 
  return(result)
  
}

dbQuery.GetCountries <- function() {
  return( dbQuery("select id, country, countryCode from countries order by country") )
}

dbQuery.GetSpecies <- function() {
  
  sql <- "select 
          	id, 
          	scientificname || 
          	CASE 
          		WHEN vernacularname is not null THEN ' ( ' || vernacularname || ' ) ' 
          		ELSE ''
          	END as name  
          from species 
          order by name"
  
  return( dbQuery(sql) )
}

dbQuery.GetOcurrencesByLocality <- function(idCountry, idEspecie) {
  
  idCountry <- dbQuery.Escape(idCountry)
  idEspecie <- dbQuery.Escape(idEspecie)
  
  sql <- paste("select \"longitudeDecimal\", latitudedecimal, count from ocurrences_by_locality
          where country_id = ", idCountry, " and specie_id = ", idEspecie)
  
  return( dbQuery(sql) )
}

dbQuery.GetOcurrencesByDate <- function(idCountry, idEspecie) {
  
  idCountry <- dbQuery.Escape(idCountry)
  idEspecie <- dbQuery.Escape(idEspecie)
  
  sql <- paste("select \"eventDate\", \"count\" from ocurrences_by_date
          where country_id = ", idCountry, " and specie_id = ", idEspecie,
          "order by \"eventDate\"")
  
  return( dbQuery(sql) )
}

dbQuery.Escape <- function(param) {
  
  return( gsub("'","''",param) )
  
}

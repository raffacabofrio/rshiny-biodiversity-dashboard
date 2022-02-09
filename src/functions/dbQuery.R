dbQuery <- function( sql ) {

  # Connect to docker when localhost. 
  dbname   <- dbQuery.GetConfig("POSTGRES_DBNAME", "dashboard")
  host     <- dbQuery.GetConfig("POSTGRES_HOST", "127.0.0.1")
  port     <- dbQuery.GetConfig("POSTGRES_PORT", "5432")
  user     <- dbQuery.GetConfig("POSTGRES_USER", "postgres")
  password <- dbQuery.GetConfig("POSTGRES_PASSWORD", "goku123")

  con <- dbConnect(RPostgres::Postgres(), dbname = dbname, host=host, port=port, user=user, password=password) 
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

dbQuery.GetSuggestedSpecies <- function(idCountry) {
  
  idCountry <- dbQuery.Escape(idCountry)
  
  sql <- paste("select s.id, s.scientificname, count(\"count\") as total 
                from 
                	ocurrences_by_locality o INNER JOIN species s
                	on o.specie_id = s.id
                where country_id = ", idCountry, "
                group by s.id, s.scientificname
                order by total desc
                limit 5")
  
  return( dbQuery(sql) )
  
}

dbQuery.Escape <- function(param) {
  
  return( gsub("'","''",param) )
  
}

dbQuery.GetConfig <- function(key, defaultValue) {
  value <- Sys.getenv(key)
  if(value == "") value = defaultValue
  return(value)
}

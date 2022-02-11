dbQuery <- function( sql ) {
  
  if(CSV_DEMO_MODE) return()

  # Connect to docker when localhost. 
  dbname   <- getConfig("POSTGRES_DBNAME", "dashboard")
  host     <- getConfig("POSTGRES_HOST", "127.0.0.1")
  port     <- getConfig("POSTGRES_PORT", "5432")
  user     <- getConfig("POSTGRES_USER", "postgres")
  password <- getConfig("POSTGRES_PASSWORD", "goku123")

  con <- dbConnect(RPostgres::Postgres(), dbname = dbname, host=host, port=port, user=user, password=password) 
  result <- dbGetQuery(con, sql) 
  return(result)
  
}

dbQuery.GetCountries <- function() {
  
  if(CSV_DEMO_MODE) return( read.csv(file = 'csv_mode/countries.csv') )
  
  result = dbQuery("select id, country, countryCode from countries order by country")
  
  # write.csv(result,"csv_mode/countries.csv", col.names = TRUE, row.names = FALSE)
  
  return( result )
}

dbQuery.GetSpecies <- function() {
  
  if(CSV_DEMO_MODE) return( read.csv(file = 'csv_mode/species.csv') )
  
  sql <- "select 
          	id, 
          	scientificname || 
          	CASE 
          		WHEN vernacularname is not null THEN ' ( ' || vernacularname || ' ) ' 
          		ELSE ''
          	END as name  
          from species 
          order by name"
  
  result <- dbQuery(sql)
  # write.csv(result,"csv_mode/species.csv", col.names = TRUE, row.names = FALSE)
  return( result )
  
  
  
  
}

dbQuery.GetOcurrencesByLocality <- function(idCountry, idEspecie) {
  
  if(CSV_DEMO_MODE){
    csv_path <- paste("csv_mode/ocurrences_by_locality_", idCountry, "_", idEspecie, ".csv")
    return( read.csv(file = csv_path) )
  } 
  
  idCountry <- dbQuery.Escape(idCountry)
  idEspecie <- dbQuery.Escape(idEspecie)
  
  sql <- paste("select \"longitudeDecimal\", latitudedecimal, count from ocurrences_by_locality
          where country_id = ", idCountry, " and specie_id = ", idEspecie)
  
  result <- dbQuery(sql)
  
  # csv_path <- paste("csv_mode/ocurrences_by_locality_", idCountry, "_", idEspecie, ".csv")
  # write.csv(result, csv_path, col.names = TRUE, row.names = FALSE)
  return( result )
}

dbQuery.GetOcurrencesByDate <- function(idCountry, idEspecie) {
  
  if(CSV_DEMO_MODE){
    csv_path <- paste("csv_mode/ocurrences_by_date_", idCountry, "_", idEspecie, ".csv")
    return( read.csv(file = csv_path) )
  } 
  
  idCountry <- dbQuery.Escape(idCountry)
  idEspecie <- dbQuery.Escape(idEspecie)
  
  sql <- paste("select \"eventDate\", \"count\" from ocurrences_by_date
          where country_id = ", idCountry, " and specie_id = ", idEspecie,
          "order by \"eventDate\"")
  
  result <- dbQuery(sql)
  
  # csv_path <- paste("csv_mode/ocurrences_by_date_", idCountry, "_", idEspecie, ".csv")
  # write.csv(result, csv_path, col.names = TRUE, row.names = FALSE)
  return( result )
}

dbQuery.GetSuggestedSpecies <- function(idCountry) {
  
  if(CSV_DEMO_MODE){
    csv_path <- paste("csv_mode/suggestions_", idCountry, ".csv")
    return( read.csv(file = csv_path) )
  } 
  
  idCountry <- dbQuery.Escape(idCountry)
  
  sql <- paste("select s.id, s.scientificname, count(\"count\") as total 
                from 
                	ocurrences_by_locality o INNER JOIN species s
                	on o.specie_id = s.id
                where country_id = ", idCountry, "
                group by s.id, s.scientificname
                order by total desc
                limit 5")
  
  result <- dbQuery(sql)
  
  # csv_path <- paste("csv_mode/suggestions_", idCountry, ".csv")
  # write.csv(result, csv_path, col.names = TRUE, row.names = FALSE)
  return( result )
  
}

dbQuery.Escape <- function(param) {
  
  return( gsub("'","''",param) )
  
}



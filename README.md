# RSHINY-BIODIVERSITY-DASHBOARD
Biodiversity app for visualization of observed species on the map.

## PRE REQUISITES
- Docker
- pgAdmin
- R SDK
- R STUDIO

## HOW TO RUN? 
1 - Run Postgres database from docker hub.

docker run --name my-postgres-copy2 -p 5432:5432 -e POSTGRES_PASSWORD=goku123 -d raffacabofrio/dashboard_postgres

2 - Run shiny app on your R Studio

Look for "src/app.R"

## DATA MODELING
- All reproducible steps to create postgres database are described in file "data-modeling/create-tables.sql"
- Also you can find some useful sql snippets on "data-modeling/analisys.sql" to explore data.
- If you are hurry and need to stress the modeling script, please take a look at table "ocurrences_100k".

## TESTS 
- Please take a look at "src/unityTests.R"

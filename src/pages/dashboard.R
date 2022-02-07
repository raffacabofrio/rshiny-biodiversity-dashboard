dashboardPage <- function(id, label = "Dashboard") {
  ns <- NS(id)
  
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      selectizeInput(
        ns('country_select'), 'Select a country',
        choices = c("Loading"="")
      ),
      selectizeInput(
        ns('specie_select'), 'Select a specie',
        choices = c("Loading"="")
      ),
      htmlOutput(ns("imagePreview"))
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # not ready
      conditionalPanel( condition = "$(\"#dashboardPage-country_select\").val() == \"\" || $(\"#dashboardPage-specie_select\").val() == \"\"" , h1("Please select country and specie.", br(), icon("arrow-left"))),
      
      # ready
      conditionalPanel(condition = "$(\"#dashboardPage-country_select\").val() != \"\" && $(\"#dashboardPage-specie_select\").val() != \"\"" ,
         h3("Location plot"),                  
         htmlOutput(ns("locationView")),
         br(),
         h3("Timeline plot"), 
         plotlyOutput(ns("dateView")),
      )
    )
    
    
  )
  
}


dashboardServer <- function(id) {
  
  moduleServer(id, function(input, output, session) {
  
    # countries selectbox load
    countriesNamed <- as.named(COUNTRIES, "id", "country")
    updateSelectizeInput(session, "country_select", choices = countriesNamed, server = TRUE)
    
    
    # species selectbox load
    speciesNamed <- as.named(SPECIES, "id", "name")
    updateSelectizeInput(session, "specie_select", choices = speciesNamed, server = TRUE)
    
    
    # render location plot
    output$locationView <- renderGvis({
      
      country_id <- input$country_select
      specie_id  <- input$specie_select
      
      if(country_id == "" || specie_id == ""){
        return()
      }
      
      ocurrencesByLocality <<- dbQuery.GetOcurrencesByLocality(country_id, specie_id)
      ocurrencesByLocality$LatLong <- paste(ocurrencesByLocality$latitudedecimal, ocurrencesByLocality$longitudeDecimal, sep=":")
      
      currentRegion <- COUNTRIES[COUNTRIES$id == country_id,]$countrycode
      
      # force empty map if no occurrence found
      if(nrow(ocurrencesByLocality) == 0){
        ocurrencesByLocality[1,] = c(0, 0, 0, "0:0")
      }
      
      gvisGeoChart(ocurrencesByLocality, "LatLong",
                   colorvar="count", 
                   options=list(region=currentRegion, resolution="provinces", width="100%"))
      
    })
    
    # render timeline plot
    output$dateView <- renderPlotly({
      
      country_id <- input$country_select
      specie_id  <- input$specie_select
      
      if(country_id == "" || specie_id == ""){
        return()
      }
      
      ocurrencesBydate <<- dbQuery.GetOcurrencesByDate(country_id, specie_id)
      plot_ly(ocurrencesBydate, x = ~eventDate, y = ~count, type = 'scatter', mode = 'lines+markers')
      
    })
    
    # render specie image preview
    output$imagePreview <- renderUI({
      
      specie_id  <- input$specie_select
      
      if(specie_id == ""){
        return()
      }
      
      specieFullName <- SPECIES[SPECIES$id == specie_id,]$name
      specieScientifcName <- getScientificName(specieFullName)
      src <- getImageUrl(specieScientifcName)
      
      img(src=src, width="100%")
    })
  
  })
  
}
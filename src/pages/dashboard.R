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
      conditionalPanel( condition = "$(\"#dashboardPage-TextState\").text() == \"NOT_READY\"" , h1("Please select country and specie.", br(), icon("arrow-left"))),
      
      # ready
      conditionalPanel(condition = "$(\"#dashboardPage-TextState\").text() == \"READY\"" ,
         h3("Location plot"),                  
         htmlOutput(ns("locationView")),
         br(),
         h3("Timeline plot"), 
         plotlyOutput(ns("dateView")),
      ),
      
      # not found
      conditionalPanel(condition = "$(\"#dashboardPage-TextState\").text() == \"NOT_FOUND\"" ,
          h1("Sorry, no data found for selected country and specie. :/"),
          p("Suggestion of good sampling for this country. Try searching by then:"),
          tags$ul(
            uiOutput(ns('suggestionList'))
          )
      ),
      
      span(textOutput(ns("TextState")), style="color:#222222")
    )
    
    
  )
  
}


dashboardServer <- function(id) {
  
  moduleServer(id, function(input, output, session) {
    
    # page states
    # NOT_READY, READY, NOT_FOUND
    pageState <- reactiveVal('NOT_READY')
  
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
      
      if(nrow(ocurrencesByLocality) == 0)
      {
        pageState('NOT_FOUND')
        return()
      }
      
      currentRegion <- COUNTRIES[COUNTRIES$id == country_id,]$countrycode
      
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
      
      ocurrencesBydate <- dbQuery.GetOcurrencesByDate(country_id, specie_id)
      
      if(nrow(ocurrencesBydate) == 0)
      {
        pageState('NOT_FOUND')
        return()
      }

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
    
    # READY STATE
    observe({

      country_id <- input$country_select
      specie_id  <- input$specie_select
      
      if(country_id != "" && specie_id != ""){
        pageState('READY')
      }
      
    })
    
    # NOT FOUND STATE - suggestion list
    output$suggestionList <- renderUI({
      
      country_id <- input$country_select
      
      if(pageState() == "NOT_FOUND" && country_id != "")
      {
        suggestions <- dbQuery.GetSuggestedSpecies(country_id)
        apply(suggestions, 1, function(s) tags$li(s['scientificname']))
      }
    })
    
    # PAGE STATE HELPER
    output$TextState <- renderText({ 
      req(pageState())
      pageState()
    })
  
  })
  
}
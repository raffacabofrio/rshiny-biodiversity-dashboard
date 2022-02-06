library(shiny)
library(shinythemes)
library(DBI)
library(RPostgres)
library(googleVis)
library(plotly)
library("rvest")

source("functions/dbQuery.R")
source("functions/as.named.R")
source("functions/getScientificName.R")
source("functions/getImageUrl.R")



# ----------------------------------------------
# GLOBAL SCOPE FOR ALL SESSIONS
# 
COUNTRIES <<- dbQuery.GetCountries()
SPECIES   <<- dbQuery.GetSpecies()



# ----------------------------------------------
# USER INTERFACE
ui = navbarPage( "Biodiversity app", theme = shinytheme("darkly"), 
                 
   
                 
  tabPanel("Dashboard",

     sidebarLayout(
       
       # Sidebar panel for inputs ----
       sidebarPanel(
           
         selectizeInput(
           'country_select', 'Select a country',
           choices = c("Loading"="")
         ),
         selectizeInput(
           'specie_select', 'Select a specie',
           choices = c("Loading"="")
         ),
         htmlOutput("imagePreview")
   
       ),
   
   # Main panel for displaying outputs ----
   mainPanel(
     
    # not ready
    conditionalPanel(condition = "input.country_select == \"\" || input.specie_select == \"\"" , h1("Please select country and specie.", br(), icon("arrow-left"))),
    
    # ready
    conditionalPanel(condition = "input.country_select != \"\" && input.specie_select != \"\"" ,
      h3("Location plot"),                  
      htmlOutput("locationView"),
      br(),
      h3("Timeline plot"), 
      plotlyOutput("dateView"),
      HTML(
        "<div class=\"alert alert-warning\" role=\"alert\">
          No ocurrence found for timeline plot.
          </div>"
      )
    )
   )
   
   
  )
   
  ), # page dashboard
  
  tabPanel("About", h1("PAGE 2"))
)

# ----------------------------------------------
# SERVER
server = function(input, output, session) {
  
  
  
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
    
    currentRegion <- countries[countries$id == country_id,]$countrycode
    
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
    
    if(nrow(ocurrencesBydate) == 0)
    {
      # todo: show warning
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
  
  

}

# ----------------------------------------------
# RUN APP
shinyApp(ui, server)

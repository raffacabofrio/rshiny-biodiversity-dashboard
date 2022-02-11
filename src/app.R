library(shiny)
library(shinythemes)
library(shinyjs)
library(DBI)
library(RPostgres)
library(googleVis)
library(plotly)
library("rvest")


# ----------------------------------------------
# FUNCTIONS
source("functions/getConfig.R")
source("functions/dbQuery.R")
source("functions/as.named.R")
source("functions/getScientificName.R")
source("functions/getImageUrl.R")

# ----------------------------------------------
# PAGES
source("pages/dashboard.R")
source("pages/about.R")


# ----------------------------------------------
# GLOBAL SCOPE FOR ALL SESSIONS
# 
CSV_DEMO_MODE <<- as.logical( getConfig("CSV_DEMO_MODE", "FALSE") )
COUNTRIES     <<- dbQuery.GetCountries()
SPECIES       <<- dbQuery.GetSpecies()



# ----------------------------------------------
# USER INTERFACE
ui = navbarPage( "Biodiversity app", theme = shinytheme("darkly"), useShinyjs(),
  
  tabPanel("Dashboard", dashboardPage("dashboardPage", "Dashboard page")),
  tabPanel("About",     aboutPage("aboutPage",         "About page"))
  
)

# ----------------------------------------------
# SERVER
server = function(input, output, session) {
  
  dashboardServer("dashboardPage")
  aboutServer("aboutPage")
}

# ----------------------------------------------
# RUN APP
shinyApp(ui, server)



aboutPage <- function(id, label = "About") {
  ns <- NS(id)
  
  fluidPage( 
  
    fluidRow(
      column(2),
      column(8, h2("Raffaello Damgaard")),
      column(2)
    ),
    
    fluidRow(
      
      column(2),
      column(2, img(src="photos/raffa.jfif", width="100%")),
      column(6, 
             p("Hello, my name is Raffaello and I am a software developer. I have worked exclusively in this area for more than 17 years."),
             p("I have participated in several phases of the software life cycle. From specification, agile development to delivery and support."),
             p("I consider myself an enthusiast of new technologies and with good communication skills. I seek to use my entrepreneur / leader profile to exert a positive influence and engagement on teams.")
      ),
      column(2),
    ),
    
    fluidRow(
      column(2),
      column(8, h2("Developing this app")),
      column(2)
    ),
    
    fluidRow(
      
      column(2),
      column(2, img(id = ns("photo01"), src="photos/01.jpg", width="100%"), br(), br(), img(id = ns("photo02"),src="photos/02.jpg", width="100%"), br(), br(), img(id = ns("photo03"), src="photos/03.jpg", width="100%")),
      column(6, 
             p("My first step was to scribble some notebook pages to draw what the app would look like. I tried exploring the data with my spreadsheet editor, but 20GB was too much for it and it crashed with a fatal error. I immediately realized that this test would be very challenging, different from what I'm used to dealing with on a daily basis. I find this very amusing. =)"),
             p("I haven't worked with shiny for two years. I dedicated 3 days to refresh my skills."),
             p("The heart of my solution is in data modeling. I bet that a well-modeled and indexed Postgres would handle this huge volume of data. I spent 2 days just preparing the data. ( please check sql folder to follow my train of thought ) Along the way I had some dead ends. For example my first attempt to consolidate the data was by province of locality. Then I had to change the strategy to consolidate by latitude and longitude. I imagined the space divided into several squares the size of a small town. And for this small space, I grouped the samples. My criterion was to have a volume that is significant for visualization and at the same time the computational cost is viable for the app to perform well."),
             p("I chose googleVis among other plot options because it was the friendliest to use. Especially when drawing a country it accepts the CountryCode, while the plotly for example I would need to have the coordinates and zoom rate for each country. But I still used ploty for the line graph because it is more interactive."),
             p("Finally I developed some skills in docker and aws to publish the app. I usually ask the cloud team to take care of this part. But I thought it would be cool to demonstrate this initiative here."),
             p("Thanks for the opportunity. I had a lot of fun developing this app. Hope you like it."),
             
      ),
      column(2),
    )
  
  )
  
}


aboutServer <- function(id) {
  
  moduleServer(id, function(input, output, session) {
    
    zoomPhoto <- reactiveVal()
    shinyjs::onclick("photo01",  zoomPhoto('photos/01.jpg'))
    shinyjs::onclick("photo02",  zoomPhoto('photos/02.jpg'))
    shinyjs::onclick("photo03",  zoomPhoto('photos/03.jpg'))

    observe({  
      req(zoomPhoto())
      src <- zoomPhoto()
      
      showModal(modalDialog(
        title = "Zoom image", easyClose = TRUE,
        img(src=src, width="100%")
      ))
      
      zoomPhoto("")
      
    })
    
  })
}
#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

################################################################
# Load Libraries

  library(shiny)
  library(shinydashboard)
  library(ggplot2)
  library(dplyr)

################################################################
# Load data
source("./scripts/load_data.R")

################################################################
# Dashboard configuration

  ################################################################
  # Header
  header <- dashboardHeader(title = "Music Sampling Project")  
  
  ################################################################
  # Sidebar
  sidebar <- dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Code", icon = icon("send",lib='glyphicon'), 
               href = "https://github.com/cchacua/music_sampling")
    )
  )

  ################################################################
  # Body   

  source("./scripts/descriptive_ui.R")

  join_statistics<-fluidRow(
    tabBox(
      title = "Descriptive statistics",
      # The id lets us use input$tabset1 on the server to find the current tab
      id = "tabset1", width=12,
      tabPanel("Join",
               selector_per,
               source_row, 
               destination_row,
               all_row,
               footnote
               ),
      tabPanel("Tab2", "Tab content 2")
    )
    
  )
  
  body <- dashboardBody(join_statistics)
  
################################################################
# User Interface

ui <- dashboardPage(title="MB - WS",
  header,
  sidebar,
  body
)

################################################################
# Server
server <- function(input, output) {
  
  source("./scripts/descriptive_sv.R", local=TRUE)
  
  
}



# Run the application 
shinyApp(ui = ui, server = server)


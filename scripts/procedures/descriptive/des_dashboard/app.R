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
  # source("./scripts/procedures/descriptive/des_dashboard/general_countings.R")
  #source("./general_countings.R")

################################################################
# Load data

output_folder<-"/home/christian/github_new/music_sampling"

source_c<-open.rdata(paste0(output_folder,"/output/dashboard_data/source_count.RData"))
dest_c<-open.rdata(paste0(output_folder,"/output/dashboard_data/dest_count.RData"))
all_c<-open.rdata(paste0(output_folder,"/output/dashboard_data/all_count.RData"))

################################################################
# Dashboard configuration

  ################################################################
  # Header
  header <- dashboardHeader(title = "Descriptive: MB - WS")  
  
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
  source_row <- fluidRow(
    valueBoxOutput("source_c_wis_t"),
    valueBoxOutput("source_c_wis_id"),
    valueBoxOutput("source_c_matched")
  )

  destination_row <- fluidRow(
    valueBoxOutput("dest_c_wis_t"),
    valueBoxOutput("dest_c_wis_id"),
    valueBoxOutput("dest_c_matched")
  )
  
  body <- dashboardBody(source_row, destination_row)
  
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
  
  output$source_c_wis_t <- renderValueBox({
    valueBox(
      formatC(source_c$wis_t$count, format="d", big.mark=',')
      ,'Total songs in WS'
      ,icon = icon("stats",lib='glyphicon')
      ,color = "purple")  
  })
  
  output$source_c_wis_id <- renderValueBox({
    valueBox(
      formatC(source_c$wis_id$count, format="d", big.mark=',')
      ,'With MB ID in WS'
      ,icon = icon("stats",lib='glyphicon')
      ,color = "purple")  
  })
  
  output$source_c_matched <- renderValueBox({
    valueBox(
      formatC(source_c$matched$count, format="d", big.mark=',')
      ,'Matched'
      ,icon = icon("stats",lib='glyphicon')
      ,color = "purple")  
  })
  
  output$dest_c_wis_t <- renderValueBox({
    valueBox(
      formatC(dest_c$wis_t$count, format="d", big.mark=',')
      ,'Total songs in WS'
      ,icon = icon("stats",lib='glyphicon')
      ,color = "purple")  
  })
  
  output$dest_c_wis_id <- renderValueBox({
    valueBox(
      formatC(dest_c$wis_id$count, format="d", big.mark=',')
      ,'With MB ID in WS'
      ,icon = icon("stats",lib='glyphicon')
      ,color = "purple")  
  })
  
  output$dest_c_matched <- renderValueBox({
    valueBox(
      formatC(dest_c$matched$count, format="d", big.mark=',')
      ,'Matched'
      ,icon = icon("stats",lib='glyphicon')
      ,color = "purple")  
  })
  
}



# Run the application 
shinyApp(ui = ui, server = server)


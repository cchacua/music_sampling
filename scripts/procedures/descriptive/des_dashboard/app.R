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

  selector_per <- fluidRow(
    column(width = 10,""),
    column(width = 2,
           checkboxInput("percentage", 
                       label = "Percentages?",
                       FALSE)
    )
  )

  source_row <- fluidRow(
    column(width = 12,
           tags$h3("Source recordings")
    ),
    valueBoxOutput("source_c_wis_t"),
    valueBoxOutput("source_c_wis_id"),
    valueBoxOutput("source_c_matched")
  )

  
  destination_row <- fluidRow(
    column(width = 12,
           tags$h3("Destination recordings")
    ),
    valueBoxOutput("dest_c_wis_t"),
    valueBoxOutput("dest_c_wis_id"),
    valueBoxOutput("dest_c_matched")
  )
  
  footnote <- fluidRow(
    column(width = 12,
           tags$p("WS = Who Sampled; MB = Music Brainz; ID = Identifier"
           )
    )
  )
  
  all_row<-fluidRow(
    column(width = 12,
           tags$h3("All (Source ∪ Destination) recordings")
    ),
    valueBoxOutput("all_c_wis_t"),
    valueBoxOutput("all_c_wis_id"),
    valueBoxOutput("all_c_matched")
  )
  
  
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
  
  # percentages_out<-reactiveValues(
  #   s_wis_t<-source_c$wis_t$count
  # )
  
  counting_values<-function(){
    if(input$percentage==FALSE){
      # Source values
        s_wis_t<-formatC(source_c$wis_t$count, format="d", big.mark=',')
        s_wis_id<-formatC(source_c$wis_id$count, format="d", big.mark=',')
        s_matched<-formatC(source_c$matched$count, format="d", big.mark=',')
      # Destination values
        d_wis_t<-formatC(dest_c$wis_t$count, format="d", big.mark=',')
        d_wis_id<-formatC(dest_c$wis_id$count, format="d", big.mark=',')
        d_matched<-formatC(dest_c$matched$count, format="d", big.mark=',')
      # All (source U destinations) values
        a_wis_t<-formatC(all_c$wis_t$count, format="d", big.mark=',')
        a_wis_id<-formatC(all_c$wis_id$count, format="d", big.mark=',')
        a_matched<-formatC(all_c$matched$count, format="d", big.mark=',')
      # Labels
        l_wis_t<-"Total songs in WS"
        l_wis_id<-"With MB ID in WS"
        l_matched<-"Matched"
      }
    else{
          # Source percentages
            # s_wis_t<-formatC(100, format="f", big.mark=',', digits = 2)
            s_wis_t<-formatC(source_c$wis_t$count, format="d", big.mark=',')
            s_wis_id<-formatC(source_c$wis_id$count/source_c$wis_t$count*100, format="f", big.mark=',', digits = 2)
            s_matched<-formatC(source_c$matched$count/source_c$wis_id$count*100, format="f", big.mark=',', digits = 2)
          # Destination percentages
            # d_wis_t<-formatC(100, format="f", big.mark=',', digits = 2)
            d_wis_t<-formatC(dest_c$wis_t$count, format="d", big.mark=',')
            d_wis_id<-formatC(dest_c$wis_id$count/dest_c$wis_t$count*100, format="f", big.mark=',', digits = 2)
            d_matched<-formatC(dest_c$matched$count/dest_c$wis_id$count*100, format="f", big.mark=',', digits = 2)
          # All (source U destinations) values  
            a_wis_t<-formatC(all_c$wis_t$count, format="d", big.mark=',')
            a_wis_id<-formatC(all_c$wis_id$count/all_c$wis_t$count*100, format="f", big.mark=',', digits = 2)
            a_matched<-formatC(all_c$matched$count/all_c$wis_id$count*100, format="f", big.mark=',', digits = 2)
          # Labels
            l_wis_t<-"Total songs in WS"
            l_wis_id<-'% with MB ID in the total of WS'
            l_matched<-"% of matched, among those with ID"
            
            }
    
    return(list(s_wis_t=s_wis_t,
                s_wis_id=s_wis_id,
                s_matched=s_matched,
                d_wis_t=d_wis_t,
                d_wis_id=d_wis_id,
                d_matched=d_matched,
                a_wis_t=a_wis_t,
                a_wis_id=a_wis_id,
                a_matched=a_matched,
                l_wis_t=l_wis_t,
                l_wis_id=l_wis_id,
                l_matched=l_matched))
  }

  ################################################################
  # Source
  output$source_c_wis_t <- renderValueBox({
    valueBox(
      counting_values()$s_wis_t,
      counting_values()$l_wis_t,
      icon = icon("stats",lib='glyphicon'),
      color = "blue")  
  })
  
  output$source_c_wis_id <- renderValueBox({
    valueBox(
      counting_values()$s_wis_id,
      counting_values()$l_wis_id,
      icon = icon("cd",lib='glyphicon')
      ,color = "blue")  
  })
  
  output$source_c_matched <- renderValueBox({
    valueBox(
      counting_values()$s_matched,
      counting_values()$l_matched
      ,icon = icon("resize-small",lib='glyphicon')
      ,color = "blue")  
  })
  
  ################################################################
  # Destination
  output$dest_c_wis_t <- renderValueBox({
    valueBox(
      counting_values()$d_wis_t, 
      counting_values()$l_wis_t
      ,icon = icon("stats",lib='glyphicon')
      ,color = "green")  
  })
  
  output$dest_c_wis_id <- renderValueBox({
    valueBox(
      counting_values()$d_wis_id,
      counting_values()$l_wis_id
      ,icon = icon("cd",lib='glyphicon')
      ,color = "green")  
  })
  
  output$dest_c_matched <- renderValueBox({
    valueBox(
      counting_values()$d_matched,
      counting_values()$l_matched
      ,icon = icon("resize-small",lib='glyphicon')
      ,color = "green")  
  })
  
  ################################################################
  # All values (source U destination)
  output$all_c_wis_t <- renderValueBox({
    valueBox(
      counting_values()$a_wis_t, 
      counting_values()$l_wis_t
      ,icon = icon("stats",lib='glyphicon')
      ,color = "navy")  
  })
  
  output$all_c_wis_id <- renderValueBox({
    valueBox(
      counting_values()$a_wis_id,
      counting_values()$l_wis_id
      ,icon = icon("cd",lib='glyphicon')
      ,color = "navy")  
  })
  
  output$all_c_matched <- renderValueBox({
    valueBox(
      counting_values()$a_matched,
      counting_values()$l_matched
      ,icon = icon("resize-small",lib='glyphicon')
      ,color = "navy")  
  })
  
}



# Run the application 
shinyApp(ui = ui, server = server)


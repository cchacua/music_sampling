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


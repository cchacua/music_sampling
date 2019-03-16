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
         tags$h3("Source songs")
  ),
  valueBoxOutput("source_c_wis_t"),
  valueBoxOutput("source_c_wis_id"),
  valueBoxOutput("source_c_matched")
)


destination_row <- fluidRow(
  column(width = 12,
         tags$h3("Destination songs")
  ),
  valueBoxOutput("dest_c_wis_t"),
  valueBoxOutput("dest_c_wis_id"),
  valueBoxOutput("dest_c_matched")
)

footnote <- fluidRow(
  column(width = 12,
         tags$p("WS = Who Sampled; MB = Music Brainz; ID = Identifier; Song = WS Track_id (different from MB recording ID)"
         )
  )
)

all_row<-fluidRow(
  column(width = 12,
         tags$h3("All (Source ∪ Destination) songs")
  ),
  valueBoxOutput("all_c_wis_t"),
  valueBoxOutput("all_c_wis_id"),
  valueBoxOutput("all_c_matched")
)

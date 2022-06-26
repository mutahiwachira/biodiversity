source("global.R")

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Sidebar with a slider input for number of bins 
    navbarPage(
      "Biodiversity",
      tabPanel(
        "Occurence",
        shiny::wellPanel(
          search_ui("search", "Search by species")
        ),
        br(),
        # Show a plot of the generated distribution
        fluidRow(
          column(6, trendline_ui("trend-plot")),
          column(6, occurence_map_ui("spatial-plot"))
        )
      )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  
  
  get_data <- reactive({
    df <- db_get_occurence_data_by_country()
    return(df)
  })
  
  observe({search_server("search", get_data())})
  
  get_species_table <- reactive({
    get_species_table()
  })
  
  get_data_to_plot <- reactive({
    input$`search-search-button`
    data         <- get_data()
    search_terms = isolate({input$`search-search-bar`})
    
    if (!is.null(search_terms)) {
      species <- get_species_selection(search_terms, data = data) 
    }else {
      species <- NULL
    }
    
    results_list <- get_occurence_data_to_plot(data = data, species = species)
    
    return(results_list)
  })
  observe({
    input$`search-search-button`
    results <- get_data_to_plot()
    occurence_map_server("spatial-plot", results$data_to_map)
    trendline_server("trend-plot", results$data_to_trend)
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
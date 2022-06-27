source("global.R")

ui <- navbarPage(
    tags$head(
      tags$script(src = "toggle.js"),
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
    ),
    title = "Biodiversity",
    tabPanel(
      "Occurence",
      div(class = "container",
          style = "max-width: 1500px; height: 1500px;",
          controls_ui("controls"),
          
          # Show a plot of the generated distribution
          fluidRow(
            column(6, trendline_ui("trend-plot")),
            column(6, occurence_map_ui("spatial-plot"))
          )
      )
    )
)

server <- function(input, output) {
  
  
  
  get_data <- reactive({
    # We should only read from the database when updating the country selector
    # The data is small enough to keep in memory for all cases except The Netherlands
    country <- input$`controls-country_selector`
    df <- db_get_occurence_data_by_country(country)
    return(df)
  })
  
  observe({controls_server("controls", get_data())})
  
  get_species_table <- reactive({
    get_species_table()
  })
  
  get_data_to_plot <- reactive({
    input$`controls-search-button`
    data         <- get_data()
    search_terms = isolate({input$`controls-search-bar`})
    
    if (!is.null(search_terms)) {
      species <- get_species_selection(search_terms, data = data) 
    }else {
      species <- NULL
    }
    
    results_list <- get_occurence_data_to_plot(data = data, species = species)
    
    return(results_list)
  })
  observe({
    input$`controls-search-button`
    country_focus <- input$`controls-country_selector`
    results <- get_data_to_plot()
    occurence_map_server("spatial-plot", results$data_to_map, country_focus)
    trendline_server("trend-plot", results$data_to_trend)
  })
  
}

shinyApp(ui = ui, server = server)
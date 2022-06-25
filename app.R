# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Biodiversity Dashboard"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30)
        ),

        # Show a plot of the generated distribution
        mainPanel(
           leafletOutput("main_map")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  get_data <- reactive({
    df <- load_polish_sample()
    return(df)
  })
  
  output$main_map <- renderLeaflet({
    
    # TODO: Configure the default view of the map
    
    map_obj <- leaflet() |> 
      addTiles()
    
    map_obj
  })
  
  # add observations
  observe({
    data <- get_data()
    results_list <- get_occurence_data_to_plot(data, species = data$scientific_name[[1]])
    data_to_map <- results_list$data_to_map
    browser()
    leafletProxy("main_map") |> 
      add_observations(data = data_to_map)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

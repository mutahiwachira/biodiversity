source("module_map.R")

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
           occurence_map_ui("main")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  get_data <- reactive({
    df <- load_polish_sample()
    return(df)
  })
  
  get_data_to_plot <- reactive({
    data <- get_data()
    results_list <- get_occurence_data_to_plot(data, species = data$scientific_name[1:5])  
  })
  
  occurence_map_server("main", get_data_to_plot()$data_to_map)
}

# Run the application 
shinyApp(ui = ui, server = server)
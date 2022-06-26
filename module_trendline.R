trendline_ui <- function(id) {
  ns <- NS(id)
  tagList(
    plotlyOutput(ns("plot"))
  )
}

trendline_server <- function(id, data) {
  moduleServer(
    id,
    function(input, output, session) {
      
      output$plot <- renderPlotly({
        lollipop_plot <- data |> 
          ggplot(aes(x = date, y = count, group = scientific_name)) + 
          geom_point(color = "black", size = 2) + 
          geom_segment(aes(x=date, xend=date, y=0, yend=count), size = 0.1, color = "black") +
          theme_light() +
          theme(
            panel.grid.major = element_blank(), 
            panel.grid.minor = element_blank()
          )
        
        ggplotly(lollipop_plot)
      })
      
    }
  )
}
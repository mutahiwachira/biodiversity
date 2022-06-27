trendline_ui <- function(id) {
  ns <- NS(id)
  tagList(
    main_box("What is the trend in population numbers?",
             plotlyOutput(ns("plot")))
  )
}

trendline_server <- function(id, data) {
  moduleServer(
    id,
    function(input, output, session) {
      
      output$plot <- renderPlotly({
        
        # Shorter species names
        data <- data |> 
          mutate(scientific_name = abbreviate_scientific_names(scientific_name))
        
        # Match the colours and species so you can feed it to ggplot2 scale_color_manual.
        unique_species <- sort(unique(data$scientific_name))
        colpal <- c("Black", "Blue", "Red")
        colpal <- colpal[seq_along(unique_species)] # should never get more than 3 species, but can be less
        names(colpal) <- unique_species
        
        data <- data %>% 
          mutate(species = as_factor(scientific_name)) |> 
          select(Date = date, Count = count, Species = species)
        
        lollipop_plot <- data |> 
          ggplot(aes(x = Date, y = Count, color = Species))
        
        lollipop_plot <- lollipop_plot +
          geom_point(size = 2) +
          geom_segment(aes(x=Date, xend=Date, y=0, yend=Count), size = 0.1) +
          scale_color_manual(values = colpal, aesthetics = c("color"))
         
        lollipop_plot <- lollipop_plot +
          theme_light() +
          theme(
           panel.grid.major = element_blank(),
           panel.grid.minor = element_blank(),
         )
        
        lollipop_plot <- lollipop_plot + 
          theme_light()
        
        interactive_plot <- ggplotly(lollipop_plot)
        
        interactive_plot <- interactive_plot |> 
          layout(
            font = list(family = "Arial", size = 16),
            title = list(font = list(size = 18), text = "Number of observations by month"),
            xaxis = list(title = list(text = NULL), tickfont = list(family = "Arial", size = 16)),
            yaxis = list(title = list(text = NULL), tickfont = list(family = "Arial", size = 16)),
            showlegend = TRUE,
            legend = list(x = 0, y = -0.3, font = list(size = 14), text = "Species", orientation = "h"))
        
        # Make the tooltip data
        
        interactive_plot
        
      })
      
    }
  )
}

# Utility functions

abbreviate_scientific_names <- function(full_name){
  # Vectorised function to change long species names to abbreviated forms for neater time plots
  full_name <- str_split(full_name, " ",simplify = TRUE)
  genus <- full_name[,1] |> str_sub(1,1) |> str_c(".")
  species <- full_name[,2]
  res <- str_c(genus, species,sep = " ")
  
  return(res)
}

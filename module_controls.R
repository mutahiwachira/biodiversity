controls_ui <- function(id) {
  ns <- NS(id)
  tagList(
    main_box(
      title = "What species would you like to learn more about?",
      shiny::selectizeInput(ns("search-bar"), label = "Choose up to three", choices = NULL, multiple = TRUE, options = list(maxItems = 3), width = "800px"),
      actionButton(ns("search-button"), "Search", icon = icon("search")), # initialize empty, update with server.
      div(
        class = "pull-right",
        actionButton(inputId = ns("settings_button"), label = NULL, icon = icon("cog"))
      ),
      div(
        id = ns("app-settings"),
        style = "display: none",
        hr(),
        selectInput(ns("country_selector"), "Country", choices = global_variables$countries$country, selected = "Poland")
      )
    )
    
  )
}

controls_server <- function(id, data) {
  # this should take in a non-reactive, global data value as much as possible
  # we don't want to trigger these components every time you make a minor adjustment to the map
  # only when you switch countries or something like that
  moduleServer(
    id,
    function(input, output, session) {
      
      observeEvent(input$settings_button, {
        #shinyjs::toggle(id = paste0(id, "-app-settings"),anim = TRUE, asis = TRUE)
        session$sendCustomMessage(type = "toggle", message = paste0(id, "-app-settings"))
      })
      
      searchbar_table <- make_searchbar_vals_table(data)
      
      updateSelectizeInput(session, "search-bar", choices = searchbar_table$vals, server = TRUE) #server-side selectize for performance improvement
      
      return(searchbar_table)
    }
  )
}

# Utility functions ----

make_searchbar_vals_table <- function(data, species_table = NULL){
  if(is.null(species_table)){
    # If we haven't already loaded it into memory and passed it through, then we need to read it in from the csv/db
    species <- get_species_table() |> 
      tidyr::drop_na(common_name)
  }
  
  search_bar_vals_df <- data |> 
    distinct(scientific_name) |> 
    left_join(species, by = "scientific_name") |> 
    group_by(scientific_name) |> 
    summarise(common_names = str_c(common_name, collapse = "; "), .groups = "drop") |> 
    mutate(vals = str_c(scientific_name, paste0("(", common_names, ")"), sep = " "))
  
  return(search_bar_vals_df)
}

get_species_selection <- function(search_terms, data){
  species_label   <- search_terms
  searchbar_table <- make_searchbar_vals_table(data)
  
  species         <- searchbar_table |> 
    filter(vals %in% species_label) |> 
    pull(scientific_name) |> 
    unique()
  
  species
}

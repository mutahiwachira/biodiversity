search_ui <- function(id, label, choices = NULL) {
  ns <- NS(id)
  tagList(
    shiny::selectizeInput(ns("search-bar"), label, choices = NULL, multiple = TRUE),
    actionButton(ns("search-button"), "Search", icon = icon("search"))# initialize empty, update with server.
  )
}

search_server <- function(id, data) {
  # this should take in a non-reactive, global data value as much as possible
  # we don't want to trigger these components every time you make a minor adjustment to the map
  # only when you switch countries or something like that
  moduleServer(
    id,
    function(input, output, session) {
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

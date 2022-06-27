# Module code ----

occurence_map_ui <- function(id) {
  ns <- NS(id)
  tagList(
    main_box("Where are these species found?", 
             leafletOutput(ns("map")))
  )
}

occurence_map_server <- function(id, data_to_map, country_focus) {
  moduleServer(
    id,
    function(input, output, session) {
      output$map <- renderLeaflet({
        
        view_coords <- global_variables$countries |> 
          filter(country == country_focus)
        # TODO: Configure the default view of the map
        map_obj <- leaflet() |> 
          addTiles() |> 
          setView(lng = view_coords$longitude, lat = view_coords$latitude, zoom = 5)
        
        map_obj
      })
      
      # add observations
      observe({
        leafletProxy("map") |> 
          add_observations(data = data_to_map)
      })
    }
  )
}

# Utility functions ----

draw_base_map <- function(df_to_map, ...){
  df_to_map |> 
    leaflet() |> 
    addTiles(...)
}

add_observations <- function(leaflet_obj, data){
  
  # Abbreviate species name to save plot space
  data <- data |> 
    mutate(scientific_name = abbreviate_scientific_names(scientific_name))
  
  # Map the range of counts
  data <- data |> 
    mutate(sizes = scale_counts_to_sizes(count, lb = 5, ub = 15))  

  colpal <- c("Black", "Blue", "Red")
  unique_species <- as_factor(sort(unique(data$scientific_name)))
  colpal <- colpal[seq_along(unique_species)] # should never get more than 3 species, but can be less
  
  data_by_species <- data |> 
    split(as_factor(data$scientific_name))
  group_labels <- names(data_by_species)
  
  jitter <- c(0.01, -0,01, 0) # TODO: find a better way to prevent overplotting.
  for (i in seq_along(data_by_species)){
    leaflet_obj <- leaflet_obj |> 
      addCircleMarkers(stroke = TRUE, color = "black", weight = 0.5, opacity = 0.9, 
                 lng = ~longitude + jitter[i], lat = ~latitude + jitter[i], label = ~htmltools::htmlEscape(text = as.character(count)),
                 data = data_by_species[[i]],
                 group = group_labels[i],
                 fillOpacity = 0.7,
                 fillColor = colpal[i],
                 radius = ~sizes)
  }
  
  leaflet_obj <- leaflet_obj |> 
    addLayersControl(overlayGroups = group_labels,options = list(collapsed = FALSE)) |> 
    addLegend("bottomright",pal = colorFactor(colpal, domain = NULL), values = unique_species)
  
  return(leaflet_obj)
}

scale_counts_to_sizes <- function(x, lb = 5, ub = 10){
  # we want the smallest dot to be of radius lb and the largest to be of radius ub on the size scale of the circle markers
  # generalized to go between lb and ub
  
  # TODO: Tests - never divide by zero
  # Also, technically, since we will never have an observation of 0, this scale doesn't actually begin at lb
  weighted_sizes <- (ub-lb)*x/max(x)+lb
  return(weighted_sizes)
}


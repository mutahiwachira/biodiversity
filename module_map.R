# Module code ----

occurence_map_ui <- function(id) {
  ns <- NS(id)
  tagList(
    leafletOutput(ns("map"))
  )
}

occurence_map_server <- function(id, data_to_map) {
  moduleServer(
    id,
    function(input, output, session) {
      output$map <- renderLeaflet({
        
        # TODO: Configure the default view of the map
        map_obj <- leaflet() |> 
          addTiles()
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
  leaflet_obj |> 
    addCircleMarkers(stroke = FALSE, lng = ~longitude, lat = ~latitude, data = data, fillOpacity = 0.9)
}

# 2.0 Geometry utilities; Calculate bounds and positions ----

find_centroid <- function(lngs, lats){
  # given longs and lats, find the point in the center
  return()
}

get_map_bounds <- function(lngs, lats){
  # given longs and lats, find the enclosing rectangle
}

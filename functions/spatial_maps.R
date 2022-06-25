# 1.0 Core mappint utilities ---- 
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

# Tests to implement
# df <- load_polish_sample()
# 
# df_to_map <- df |> 
#   make_df_to_map()
# 
# df_to_map |> 
#   draw_base_map() |> 
#   add_observations(df_to_map)

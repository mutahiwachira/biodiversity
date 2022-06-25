# 1.0 Core mappint utilities ---- 

make_df_to_map <- function(data){
  # from the raw data, prepare the df we need to draw the map efficiently
  data |> 
    select(lng = longitudeDecimal, lat = latitudeDecimal) |> 
    sample_n(1000)
}

draw_base_map <- function(df_to_map, ...){
  df_to_map |> 
    leaflet() |> 
    addTiles(...)
}

add_observations <- function(leaflet_obj, data){
  leaflet_obj |> 
    addCircleMarkers(stroke = FALSE, data = data)
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

# 1.0 OCCURENCE DATA ----

## CSV Access / Database Access functions ----
load_polish_sample <- function(){
  # Loads the polish csv data, a smaller dataframe for testing purposes
  df <- readr::read_csv("data/biodiversity_poland.csv")
  return(df)
}

lookup_common_species_name <- function(lookup_table, common_name, species_name){
  
}


## Query Functions ----
qry_species <- function(data, scientific_name = NULL, common_name = NULL){
  
  # Use a common name to get a scientific_name
  
  df <- data |> 
    filter(scientific_name %in% scientific_name)
  
  return(df)
}

qry_time_frame <- function(data, start = min(data$eventDate), end = max(data$eventDate)){
  start <- as_date(start)
  end   <- as_date(end)
  
  df <- data |> 
    filter(date |> between(start, end))
  
  return(df)
}

# This function gets the basic counts for a given time range and species to map
# It's important to have this function because it aggregates over the time variable
# It makes sure we don't overplot multiple observations in the same place from different times
get_data_to_map <- function(data, start = min(data$eventDate), end = max(data$eventDate), scientific_name = NULL, common_name = NULL){
  data |> 
    qry_species(scientific_name, common_name) |> 
    qry_time_frame(start, end) |> 
    group_by(-date)
}

# Tests to implement


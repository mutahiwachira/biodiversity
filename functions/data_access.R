# 1.0 OCCURENCE DATA ----

## CSV Access / Database Access functions ----
load_polish_sample <- function(){
  # Loads the polish csv data, a smaller dataframe for testing purposes
  df <- readr::read_csv("data/biodiversity_poland.csv")
  return(df)
}

# get_lookup_table <- function(){
#   # this table has two columns - scientific_name and common_name
#   # we will use it for matching common_names to scientific
#   # we use scientific names everywhere because they are unique and regular
#   lookup_table <- readr::read_csv("data/species_names_lookup.csv")
#   lookup_table
# }

# lookup_species <- function(lookup_table = get_lookup_table(), species){
#   # if not supplied, then we read the lookup table from our data
#   # but the function allows you to supply it so that we minimize our dependence on read/write operations
#   # the lookup table won't be too big and is something we might like to keep in memory because it is used always.
#   
#   # TODO: validate lookup table: can't have the same common name refer to two different scientific names
#   
#   # Use a common name to get a scientific_name
#   all_scientific_names <- lookup_table$scientific_name
#   
#   species_scientific <- species[species %in% all_scientific_names]
#   species_common     <- species[!species %in% all_scientific_names]
#   
#   # check if the species other is in the lookup table
#   
#   common_name_val <- common_name # otherwise filter doesn't work right - treats it as column == column
#   scientific_names <- lookup_table |> 
#     filter(common_name == common_name_val) |> 
#     pull(scientific_name)
#   
#   # TODO: Defensive programming - the vectors should be the same length!
#   
#   # TODO: Defensive programming - what if they enter a nonsense value for the name?
#   
#   return(scientific_names)
# }


## Query Functions ----
qry_species <- function(data, species = NULL){
  # query only works with scientific name at low level design
  # higher level functions, UI, will always pass scientific names
  
  if (is.null(species)) return(data)
  
  df <- data |> 
    filter(scientific_name %in% species)
  
  return(df)
}

qry_time_frame <- function(data, start = min(data$date), end = max(data$date)){
  start <- as_date(start)
  end   <- as_date(end)
  
  df <- data |> 
    filter(date |> between(start, end))
  
  return(df)
}

qry_area <- function(data, coords_){
  # TODO: write a function to query the data based on given set of coordinates.
  # There is probably a convenience function for this in a package like sf - don't reinvent the wheel.
}

# This function gets the basic counts for a given time range and species to map
# It's important to have this function because it aggregates over the time variable
# It makes sure we don't overplot multiple observations in the same place from different times
get_occurence_data_to_plot <- function(data, start = min(data_by_species$date), end = max(data_by_species$date), species = NULL){
  
  data_by_species <- data |> 
    qry_species(species)
    # We made this object first so that, if not supplies, start and end can evaluate their min 
    # and max lazily from this smaller dataset
  
  data_within_range <- data_by_species |> 
    qry_time_frame(start, end)
  
  data_to_trend <- data_within_range |> 
    group_by(date, country, scientific_name) |> 
    summarise(count = sum(count), .groups = "drop") |> # for the trend data, we aggregate out the locations
    ungroup()
  
  data_to_map <- data_within_range |> 
    group_by(longitude, latitude, country, scientific_name) |> 
    summarise(count = sum(count), .groups = "drop") |> # for the map data, we aggregate out the dates
    ungroup()
  
  # We aggregate out these results to make the data required on each plot smaller, improving plot performance.
  # We return both of these plots from the very same function so that these data are always in sync.
  
  return(list(data_to_trend = data_to_trend, data_to_map = data_to_map))
}
# Tests to implement


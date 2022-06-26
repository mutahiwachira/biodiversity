# 1.0 OCCURENCE DATA ----

db_get_occurence_data_by_country <- function(country = "Poland"){
  # TODO: Validation of country input; match.arg
  con <- DBI::dbConnect(RSQLite::SQLite(),"data/appsilon")
  
  country_value = country
  df_occurence <- tbl(con, "occurence_non_nl") |> 
    filter(country == country_value) |> 
    collect() # for now let's load into memory until we have benchmarked performance.
  
  dbDisconnect(con)
  
  return(df_occurence)
}

db_get_countries <- function(){
  con <- DBI::dbConnect(RSQLite::SQLite(),"data/appsilon")
  
  countries_df <- tbl(con,"view_dim_countries") |> 
    collect()
  dbDisconnect(con)
  
  return(countries_df)
}
## CSV Access / Database Access functions ----

get_species_table <- function(){
  # this table has two columns - scientific_name and common_name
  # we use it to populate the search bar
  lookup_table <- readr::read_csv("data/species_names_lookup.csv")
  lookup_table
}

## Query Functions ----
qry_species <- function(data, species = NULL){
  # query only works with scientific name at low level design
  # higher level functions, UI, will always pass scientific names
  
  if (is.null(species) || length(species) == 0) {
    # a temporary default!
    # TODO
    df <- data |> 
      sample_n(50)
    return(df)
  } else {
    df <- data |> 
      filter(scientific_name %in% species)  
  }
  
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


# 1.0 OCCURENCE DATA ----

## CSV Access / Database Access functions ----
load_polish_sample <- function(){
  # Loads the polish csv data, a smaller dataframe for testing purposes
  df <- readr::read_csv("data/poland_occurence.csv")
  return(df)
}

## Query Functions ----
qry_species <- function(data, species_name){
  df <- data |> 
    filter(scientificName %in% species_name | vernacularName %in% species_name)
  
  return(df)
}

qry_time_frame <- function(data, start = min(data$eventDate), end = max(data$eventDate)){
  start <- as_date(start)
  end   <- as_date(end)
  
  df <- data |> 
    filter(eventDate |> between(start, end))
  
  return(df)
}


# Tests to implement
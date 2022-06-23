library(tidyverse)
library(DBI)
library(RSQLite)
library(dbplyr)

con <- DBI::dbConnect(RSQLite::SQLite(),"data/appsilon")

df_occurence <- tbl(con, "occurence")

poland_data <- df_occurence |> 
  filter(country == "Poland") |> 
  collect()

readr::write_csv(poland_data, "data/poland_occurence.csv")

dbDisconnect(con)

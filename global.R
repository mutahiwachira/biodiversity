library(shiny)
library(plotly)
library(tidyverse)
library(leaflet)
library(DBI)
library(RSQLite)
library(dbplyr)
library(lubridate)
library(ggplot2)
library(shinyjs)

# source functions
source("functions/data_access.R")
source("functions/spatial_maps.R")

# source shiny_modules
source("module_map.R")
source("module_controls.R")
source("module_trendline.R")

options(shiny.fullstacktrace=TRUE)

# Global Variables
# only load once, common to all users, possibly slow data load, read-only...
global_variables <<- list(
  countries = db_get_countries()
)
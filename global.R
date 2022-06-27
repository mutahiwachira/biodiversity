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
library(shinydashboard) # some useful UI elements like box

# source functions
source("functions/data_access.R")
source("functions/spatial_maps.R")

# source shiny_modules
source("module_map.R")
source("module_controls.R")
source("module_trendline.R")
source("custom_ui.R")

options(shiny.fullstacktrace=TRUE)

# Global Variables
# only load once, common to all users, possibly slow data load, read-only...
global_variables <<- list(
  countries = db_get_countries()
)
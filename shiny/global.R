library(stringr)

library(iccat.pub.base)
library(iccat.pub.data)

library(shiny)
library(shinyjs)
library(shinyWidgets)
library(shinycssloaders)
library(DT)

options(scipen = 9999)

# THIS IS ***FUNDAMENTAL*** TO HAVE THE DOCKER CONTAINER CORRECTLY LOAD THE .RData FILE WITH THE ORIGINAL UTF-8 ENCODING
Sys.setlocale(category = "LC_ALL", locale = "en_US.UTF-8")

TAB_DATA_LONG        = "Data (raw)"
TAB_DATA_WIDE        = "Data"
TAB_SUMMARY          = "Summary"
TAB_DETAILED_SUMMARY = "Detailed summary"

load("./META.RData")
load("./NC.RData")
load("./NC_l.RData")
load("./NC_w.RData")

ALL_CPCS           = setNames(as.character(REF_PARTIES$CODE),        paste0(REF_PARTIES$CODE,        " - ", REF_PARTIES$NAME_EN))
ALL_CPC_STATUS     = setNames(as.character(REF_PARTY_STATUS$CODE),   paste0(REF_PARTY_STATUS$CODE,   " - ", REF_PARTY_STATUS$NAME_EN))
ALL_FLAGS          = setNames(as.character(REF_FLAGS$CODE),          paste0(REF_FLAGS$CODE,          " - ", REF_FLAGS$NAME_EN))
ALL_FLEETS         = setNames(as.character(REF_FLEETS$CODE),         paste0(REF_FLEETS$CODE,         " - ", REF_FLEETS$NAME_EN))

ALL_GEAR_GROUPS    = setNames(as.character(REF_GEAR_GROUPS$CODE),    paste0(REF_GEAR_GROUPS$CODE,    " - ", REF_GEAR_GROUPS$NAME_EN))
ALL_GEARS          = setNames(as.character(REF_GEARS$CODE),          paste0(REF_GEARS$CODE,          " - ", REF_GEARS$NAME_EN))

ALL_STOCK_AREAS    = setNames(as.character(REF_STOCK_AREAS$CODE),    paste0(REF_STOCK_AREAS$CODE,    " - ", REF_STOCK_AREAS$NAME_EN))
ALL_SAMPLING_AREAS = setNames(as.character(REF_SAMPLING_AREAS$CODE), paste0(REF_SAMPLING_AREAS$CODE, " - ", REF_SAMPLING_AREAS$NAME_EN))
ALL_AREAS          = setNames(as.character(REF_AREAS$CODE),          paste0(REF_AREAS$CODE,          " - ", REF_AREAS$NAME_EN))
ALL_FISHING_ZONES  = setNames(as.character(REF_FISHING_ZONES$CODE),  paste0(REF_FISHING_ZONES$CODE,  " - ", REF_FISHING_ZONES$NAME_EN))

ALL_CATCH_TYPES    = setNames(as.character(REF_CATCH_TYPES$CODE),    paste0(REF_CATCH_TYPES$CODE,    " - ", REF_CATCH_TYPES$NAME_EN))
ALL_QUALITIES      = setNames(as.character(REF_QUALITY_LEVELS$CODE), paste0(REF_QUALITY_LEVELS$CODE, " - ", REF_QUALITY_LEVELS$NAME_EN))

UI_select_input = function(id, label, choices) {
  return(
    virtualSelectInput(
      inputId = id, 
      label = label,
      width = "100%",
      multiple = TRUE,
      autoSelectFirstOption = FALSE,
      choices = choices,
      search = TRUE,
      showValueAsTags = FALSE,
      updateOn = "close"
    )
  )
}

INITIAL_NUM_ENTRIES = 50

CSV_DATA_AVAILABLE   = "1"
CSV_DATA_UNAVAILABLE = ""

UI_DATA_AVAILABLE    = "◼"
UI_DATA_UNAVAILABLE  = "◻"

set_log_level(LOG_INFO)

MIN_YEAR = 1950 #min(CA_ALL$Year)
MAX_YEAR = max(NC_w$YEAR)

INFO(paste0(nrow(NC_w), " rows loaded from NC_w"))
ui = function() {
  TITLE = "ICCAT / Task 1 / NC / browser"
  return(
    fluidPage(
      shinyjs::useShinyjs(),
      title = TITLE,
      tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
      ),
      tags$div(
        class = "main-container",
        conditionalPanel(
          condition = "$('html').hasClass('shiny-busy')",
          tags$div(id = "glasspane",
                   tags$div(class = "loading", "Filtering data and preparing output...")
          )
        ),
        tags$div(
          fluidRow(
            column(
              width = 8,
              h2(
                style = "margin-top: 5px !important",
                img(src = "iccat-logo.jpg", height = "48px"),
                span(TITLE)
              )
            )
          ),
          fluidRow(
            column(
              width = 2,
              fluidRow(
                column(
                  width = 12,
                  sliderInput("years", "Year range",
                              width = "100%",
                              min = MIN_YEAR, max = MAX_YEAR,
                              value = c(max(MIN_YEAR, MAX_YEAR - 30 + 1), MAX_YEAR),
                              sep = "",
                              step  = 1)
                )
              ),
              fluidRow(
                column(
                  width = 12,
                  tabsetPanel(
                    tabPanel("Main filters",
                             icon = icon("filter"),
                             style = "padding-top: 1em", 
                             fluidRow(
                               column(
                                 width = 12,
                                 UI_select_input("flags", "Flag(s)", ALL_FLAGS)
                               )
                             ),
                             fluidRow(
                               column(
                                 width = 12,
                                 UI_select_input("gearGroups", "Gear group(s)", ALL_GEAR_GROUPS)
                               )
                             ),
                             fluidRow(
                               column(
                                 width = 12,
                                 UI_select_input("stockAreas", "Stock area(s)", ALL_STOCK_AREAS)
                               )
                             ),
                             fluidRow(
                               column(
                                 width = 12,
                                 UI_select_input("samplingAreas", "Sampling area(s)", ALL_SAMPLING_AREAS)
                               )
                             ),
                             fluidRow(
                               column(
                                 width = 12,
                                 UI_select_input("areas", "Area(s)", ALL_AREAS)
                               )
                             ),
                             fluidRow(
                               column(
                                 width = 12,
                                 UI_select_input("catchTypes", "Catch type(s)", ALL_CATCH_TYPES)
                               )
                             )
                    ),
                    tabPanel("Other filters",
                             icon = icon("filter"),
                             style = "padding-top: 1em", 
                             fluidRow(
                               column(
                                 width = 12,
                                 UI_select_input("CPCs", "CPC(s)", ALL_CPCS)
                               )
                             ), 
                             fluidRow(
                               column(
                                 width = 12,
                                 UI_select_input("CPCStatus", "CPC status(es)", ALL_CPC_STATUS)
                               )
                             ), 
                             fluidRow(
                               column(
                                 width = 12,
                                 UI_select_input("fleets", "Fleet(s)", ALL_FLEETS)
                               )
                             ),
                             fluidRow(
                               column(
                                 width = 12,
                                 UI_select_input("gears", "Gear(s)", ALL_GEARS)
                               )
                             ),
                             fluidRow(
                               column(
                                 width = 12,
                                 UI_select_input("fishingZones", "Fishing zone(s)", ALL_FISHING_ZONES)
                               )
                             ),
                             fluidRow(
                               column(
                                 width = 12,
                                 UI_select_input("qualityLevels", "Quality level(s)", ALL_QUALITIES)
                               )
                             )
                    )
                  )
                )
              ),
              fluidRow(
                column(
                  width = 12,
                  actionButton("resetFilters", "Reset all filters", icon = icon("filter-circle-xmark"))
                )
              ),
              fluidRow(
                column(
                  width = 12,
                  h5(strong("Download current dataset:"))
                )
              ),
              fluidRow(
                column(
                  width = 4,
                  downloadButton("downloadFiltered", "Filtered", style = "width: 100px")
                ),
                column(
                  width = 4,
                  downloadButton("downloadFull",     "Full",     style = "width: 100px")
                ),
                column(
                  width = 4,
                  span("as ", style = "vertical-align: -5px",
                       code(".csv.gz")
                  )
                )
              ),
              fluidRow(
                column(
                  width = 12,
                  hr(),
                  span("Data last updated on:"), 
                  strong(META$LAST_UPDATE)
                )
              )
            ),
            column(
              width = 10,
              tabsetPanel(
                id = "dataset",
                tabPanel(TAB_DATA_LONG, icon = icon("table-list"),
                         tags$div(id = "filtered_data_container_long",
                                  dataTableOutput("filtered_data_long")
                         )
                ),
                tabPanel(TAB_DATA_WIDE, icon = icon("table-list"),
                         tags$div(id = "filtered_data_container_wide",
                                  dataTableOutput("filtered_data_wide")
                         )
                ),
                tabPanel(TAB_SUMMARY, icon = icon("rectangle-list"),
                         tags$div(id = "filtered_summary_container",
                                  dataTableOutput("summary_data"))
                ),
                tabPanel(TAB_DETAILED_SUMMARY, icon = icon("rectangle-list"),
                         tags$div(id = "filtered_detailed_summary_container",
                                  dataTableOutput("detailed_summary_data")
                         )
                )
              )
            )
          )
        )
      )
    )
  )
}

server = function(input, output, session) {
  SPECIES_ORDERED = c("BFT", "ALB", # Temperate tunas
                      "YFT", "BET", "SKJ", # Tropical tunas
                      "SWO", "BUM", "SAI", "SPF", "WHM", # Billfish
                      "BLF", "BLT", "BON", "BOP", "BRS", "CER", "FRI", "KGM", "LTA", "MAW", "SLT", "SSM", "WAH",  "DOL", # Small tunas
                      "BIL", "BLM", "MSP", "MLS", "RSP", # Other billfish
                      "SBF", # Southern bluefin tuna
                      "oTun", # Other tunas
                      "BSH", "POR", "SMA", # Main shark species
                      "oSks", # Other sharks
                      "oFis", # Other fish
                      "rest" # Everything else
  )
  
  EMPTY_FILTER = 
    list(years = c(),
         CPCs = c(),
         CPCStatus = c(),
         flags = c(),
         fleets = c(),
         gearGroups = c(),
         gears = c(),
         stockAreas = c(),
         samplingAreas = c(),
         areas = c(),
         fishingZoneCodes = c(),
         catchTypes = c(),
         qualities = c()
    )
  
  
  default_filter_data = function(data, input = EMPTY_FILTER) {
    INFO(paste0("Years          : ", paste0(input$years,         collapse = "-")))
    INFO(paste0("CPCs           : ", paste0(input$CPCs,          collapse = ", ")))
    INFO(paste0("CPC status     : ", paste0(input$CPCStatus,     collapse = ", ")))
    INFO(paste0("Flags          : ", paste0(input$flags,         collapse = ", ")))
    INFO(paste0("Fleets         : ", paste0(input$fleets,        collapse = ", ")))
    INFO(paste0("Gear groups    : ", paste0(input$gearGroups,    collapse = ", ")))
    INFO(paste0("Gears          : ", paste0(input$gears,         collapse = ", ")))
    INFO(paste0("Stock areas    : ", paste0(input$stockAreas,    collapse = ", ")))
    INFO(paste0("Sampling areas : ", paste0(input$samplingAreas, collapse = ", ")))
    INFO(paste0("Areas          : ", paste0(input$areas,         collapse = ", ")))
    INFO(paste0("Fishing zones  : ", paste0(input$fishingZones,  collapse = ", ")))
    INFO(paste0("Catch types    : ", paste0(input$catchTypes,    collapse = ", ")))
    INFO(paste0("Quality levels : ", paste0(input$qualityLevels, collapse = ", ")))
    
    start = Sys.time()
    
    filtered = data
    
    has_years = length(input$years) == 2
    
    if(has_years) {
      first_year = input$years[1]
      last_year  = input$years[2]
      
      filtered = filtered[YEAR >= first_year & YEAR <= last_year]
    } else {
      first_year = min(data$YEAR)
      last_year  = max(data$YEAR)
    }
    
    if(!is.null(input$CPCs)) {
      filtered = filtered[CPC_CODE %in% input$CPCs]
    }
    
    if(!is.null(input$CPCStatus)) {
      filtered = filtered[CPC_STATUS_CODE %in% input$CPCStatus]
    }
    
    if(!is.null(input$flags)) {
      filtered = filtered[FLAG_CODE %in% input$flags]
    }
    
    if(!is.null(input$fleets)) {
      filtered = filtered[FLEET_CODE %in% input$fleets]
    }
    
    if(!is.null(input$gearGroups)) {
      filtered = filtered[GEAR_GROUP_CODE %in% input$gearGroups]
    }
    
    if(!is.null(input$gears)) {
      filtered = filtered[GEAR_CODE %in% input$gears]
    }
    
    if(!is.null(input$stockAreas)) {
      filtered = filtered[STOCK_AREA_CODE %in% input$stockAreas]
    }
    
    if(!is.null(input$samplingAreas)) {
      filtered = filtered[SAMPLING_AREA_CODE %in% input$samplingAreas]
    }
    
    if(!is.null(input$areas)) {
      filtered = filtered[AREA_CODE %in% input$areas]
    }
    
    if(!is.null(input$fishingZones)) {
      filtered = filtered[FISHING_ZONE_CODE %in% input$fishingZones]
    }
    
    if(!is.null(input$catchTypes)) {
      filtered = filtered[CATCH_TYPE_CODE %in% input$catchTypes]
    }
    
    if(!is.null(input$qualityLevels)) {
      filtered = filtered[QUALITY_CODE %in% input$qualityLevels]
    }
    
    end = Sys.time()
    
    INFO(paste0("Filtering data: ", end - start))
    
    INFO(paste0("Filtered data size: ", nrow(filtered)))
    
    return(filtered)
  }
  
  filter_nc_data_wide = reactive({
    return(
      filter_nc_data_wide_(input)
    )
  })
  
  filter_nc_data_wide_ = function(input = EMPTY_FILTER) {
    filtered = default_filter_data(NC_w, input)

    return(filtered)
  }
  
  filter_nc_data_long = reactive({
    return(
      filter_nc_data_long_(input)
    )
  })
  
  filter_nc_data_long_ = function(input = EMPTY_FILTER) {
    filtered = default_filter_data(NC_l, input)

    return(filtered)
  }
  
  filter_nc_data_ = function(input = EMPTY_FILTER) {
    filtered = default_filter_data(NC_w, input)
    
    return(filtered)
  }
  
  filter_summary_data = reactive({
    return(
      filter_summary_data_(input, TRUE)
    )
  })
  
  filter_summary_data_ = function(input = EMPTY_FILTER, use_symbols = FALSE) {
    filtered = default_filter_data(NC, input)
    filtered = 
      filtered[, .(CATCH = sum(CATCH, na.rm = TRUE)), keyby = .(FLAG_CODE,
                                                                FLAG_NAME_EN, 
                                                                GEAR_GROUP_CODE, 
                                                                CATCH_TYPE_CODE, 
                                                                YEAR, YEAR_SHORT)][CATCH > 0]
    
    has_years = length(input$years) == 2
    
    if(has_years) {
      first_year = input$years[1]
      last_year  = input$years[2]
      
      filtered = filtered[YEAR >= first_year & YEAR <= last_year]
    } else {
      first_year = min(filtered$YEAR)
      last_year  = max(filtered$YEAR)
    }
    
    FILTERED_YEAR_SHORTS = lapply(first_year:last_year, function(y) { return (str_sub(as.character(y), 3, 4) ) })
    
    filtered[, YEAR_SHORT := str_sub(as.character(YEAR), 3, 4)]
    
    filtered$YEAR_SHORT =
      factor(
        filtered$YEAR_SHORT,
        labels = as.character(FILTERED_YEAR_SHORTS),
        levels = as.character(FILTERED_YEAR_SHORTS),
        ordered = TRUE
      )
    
    filtered = filtered[, .(FLAG_CODE, FLAG_NAME_EN, GEAR_GROUP_CODE, CATCH_TYPE_CODE, YEAR_SHORT, CATCH)]
    
    filtered_w =
      dcast.data.table(
        filtered,
        FLAG_CODE + FLAG_NAME_EN + GEAR_GROUP_CODE + CATCH_TYPE_CODE ~ YEAR_SHORT,
        fun.aggregate = function(v) { return (ifelse(use_symbols, UI_DATA_AVAILABLE, CSV_DATA_AVAILABLE)) },
        drop = c(TRUE, FALSE),
        value.var = "CATCH",
        fill = ifelse(use_symbols, UI_DATA_UNAVAILABLE, CSV_DATA_UNAVAILABLE)
      )
    
    return(filtered_w)
  }
  
  filter_detailed_summary_data = reactive({
    return(
      filter_detailed_summary_data_(input, TRUE)
    )
  })
  
  filter_detailed_summary_data_ = function(input = EMPTY_FILTER, use_symbols = FALSE) {
    filtered = default_filter_data(NC, input)
    
    filtered = 
      filtered[, .(CATCH = sum(CATCH, na.rm = TRUE)), keyby = .(FLAG_CODE, FLAG_NAME_EN,
                                                                FLEET_CODE, 
                                                                GEAR_GROUP_CODE, GEAR_CODE, 
                                                                STOCK_AREA_CODE, SAMPLING_AREA_CODE,
                                                                CATCH_TYPE_CODE, 
                                                                YEAR, YEAR_SHORT)][CATCH > 0]
    
    has_years = length(input$years) == 2
    
    if(has_years) {
      first_year = input$years[1]
      last_year  = input$years[2]
      
      filtered = filtered[YEAR >= first_year & YEAR <= last_year]
    } else {
      first_year = min(filtered$YEAR)
      last_year  = max(filtered$YEAR)
    }
    
    FILTERED_YEAR_SHORTS = lapply(first_year:last_year, function(y) { return (str_sub(as.character(y), 3, 4) ) })
    
    filtered[, YEAR_SHORT := str_sub(as.character(YEAR), 3, 4)]
    
    filtered$YEAR_SHORT =
      factor(
        filtered$YEAR_SHORT,
        labels = as.character(FILTERED_YEAR_SHORTS),
        levels = as.character(FILTERED_YEAR_SHORTS),
        ordered = TRUE
      )
    
    filtered_w =
      dcast.data.table(
        filtered,
        FLAG_CODE + FLAG_NAME_EN + FLEET_CODE + GEAR_GROUP_CODE + GEAR_CODE + STOCK_AREA_CODE + SAMPLING_AREA_CODE + CATCH_TYPE_CODE ~ YEAR_SHORT,
        fun.aggregate = function(v) { return (ifelse(use_symbols, UI_DATA_AVAILABLE, CSV_DATA_AVAILABLE)) },
        drop = c(TRUE, FALSE),
        value.var = "CATCH",
        fill = ifelse(use_symbols, UI_DATA_UNAVAILABLE, CSV_DATA_UNAVAILABLE)
      )
    
    return(filtered_w)
  }

  validate_filtering = function(filtered_data) {
    filtered_rows = nrow(filtered_data)
    
    if(filtered_rows == 0) {
      shinyjs::disable("downloadFiltered")
      
      showModal(modalDialog(title  = "No matching records", 
                            footer = NULL,
                            easyClose = TRUE,
                            fade = FALSE,
                            "Please refine your current filtering criteria!"))
    } else {
      shinyjs::enable("downloadFiltered")
    }
    
    #validate(need(filtered_rows > 0, "Current filtering criteria do not identify any valid record!"))
    
    return(filtered_data)
  }
  
  output$filtered_data_long =
    renderDataTable({
      filtered_data = validate_filtering(filter_nc_data_long())
      
      filtered_data$FLAG_CODE = NULL
      
      return(
        DT::datatable(
          filtered_data,
          options = list(
            pageLength = INITIAL_NUM_ENTRIES, 
            autoWidth = TRUE,
            scrollX = TRUE,
            dom = "ltipr" # To remove the 'search box' - see: https://rstudio.github.io/DT/options.html and https://datatables.net/reference/option/dom
          ),
          filter    = "none",
          selection = "none",
          rownames = FALSE,
          colnames = c("Dataset ID", "Strata ID",
                       "Flag", "Fleet code", 
                       "CPC", "CPC status",
                       "Gear group", "Gear",
                       "Year", 
                       "Stock area", "Sampling area", "Area", "Fishing zone",
                       "Catch type",
                       "Quality level",
                       "Catch unit",
                       "Species", "Catch")
        ) 
        %>% DT::formatCurrency(columns = c("CATCH"), currency = "")
      )
    })
  
  output$filtered_data_wide =
    renderDataTable({
      filtered_data = validate_filtering(filter_nc_data_wide())

      #filtered_data$DATASET_ID = NULL
      #filtered_data$STRATA_ID = NULL
      filtered_data$FLAG_CODE = NULL
      
      return(
        DT::datatable(
          filtered_data,
          options = list(
            pageLength = INITIAL_NUM_ENTRIES, 
            autoWidth = TRUE,
            scrollX = TRUE,
            dom = "ltipr" # To remove the 'search box' - see: https://rstudio.github.io/DT/options.html and https://datatables.net/reference/option/dom
          ),
          filter    = "none",
          selection = "none",
          rownames = FALSE,
          colnames = c("Flag", "Fleet code", 
                       "CPC", "CPC status",
                       "Gear group", "Gear",
                       "Year", 
                       "Stock area", "Sampling area", "Area", "Fishing zone",
                       "Catch type",
                       "Quality level",
                       "Catch unit",
                       "Total",
                       SPECIES_ORDERED)
        ) 
        %>% DT::formatCurrency(columns = c("TOTAL", SPECIES_ORDERED), currency = "")
      )
    })
  
  output$summary_data =
    renderDataTable({
      filtered_data = validate_filtering(filter_summary_data())
      
      filtered_data$FLAG_CODE = NULL
      
      return(
        DT::datatable(
          filtered_data,
          options = list(
            pageLength = INITIAL_NUM_ENTRIES, 
            autoWidth = TRUE,
            scrollX = TRUE,
            dom = "ltipr" # To remove the 'search box' - see: https://rstudio.github.io/DT/options.html and https://datatables.net/reference/option/dom
          ),
          filter    = "none",
          selection = "none",
          rownames = FALSE,
          colnames = c("Flag", 
                       "Gear group",
                       "Catch type",
                       colnames(filtered_data[, 4:ncol(filtered_data)]))
        )
      )
    })
  
  output$detailed_summary_data =
    renderDataTable({
      filtered_data = validate_filtering(filter_detailed_summary_data())
      
      filtered_data$FLAG_CODE = NULL
      
      return(
        DT::datatable(
          filtered_data,
          options = list(
            pageLength = INITIAL_NUM_ENTRIES, 
            autoWidth = TRUE,
            scrollX = TRUE,
            dom = "ltipr" # To remove the 'search box' - see: https://rstudio.github.io/DT/options.html and https://datatables.net/reference/option/dom
          ),
          filter    = "none",
          selection = "none",
          rownames = FALSE,
          colnames = c("Flag", "Fleet code", 
                       "Gear group", "Gear",
                       "Stock area", "Sampling area",
                       "Catch type",
                       colnames(filtered_data[, 8:ncol(filtered_data)]))
        )
      )
    })
  
  get_filename_components = function(input) {
    components = c(paste0(input$years,         collapse = "-"), 
                   paste0(input$CPCs,          collapse = "+"), 
                   paste0(input$CPCStatus,     collapse = "+"),
                   paste0(input$flags,         collapse = "+"),
                   paste0(input$fleets,        collapse = "+"),
                   paste0(input$gearGroups,    collapse = "+"),
                   paste0(input$gears,         collapse = "+"),
                   paste0(input$stockAreas,    collapse = "+"),
                   paste0(input$samplingAreas, collapse = "+"),
                   paste0(input$areas,         collapse = "+"),
                   paste0(input$fishingZones,  collapse = "+"),
                   paste0(input$catchTypes,    collapse = "+"),
                   paste0(input$qualityLevels, collapse = "+"))
    
    components = components[which(components != "")]
    
    return(paste0(str_replace_all(META$LAST_UPDATE, "\\-", ""), "_", paste0(components, collapse = "_")))
  }
  
  output$downloadFiltered = downloadHandler(
    filename = function() {
      dataset = input$dataset
      
      if(dataset == TAB_DATA_LONG)
        return(paste0("ICCAT_T1NC_raw_", get_filename_components(input), ".csv.gz"))
      else if(dataset == TAB_DATA_WIDE)
        return(paste0("ICCAT_T1NC_", get_filename_components(input), ".csv.gz"))
      else if(dataset == TAB_SUMMARY) 
        return(paste0("ICCAT_T1NC_summary_", get_filename_components(input), ".csv.gz"))
      else # Detailed summary
        return(paste0("ICCAT_T1NC_detailed_summary_", get_filename_components(input), ".csv.gz"))
    },
    content = function(file) {
      dataset = input$dataset
      
      if(dataset == TAB_DATA_LONG)
        to_download = filter_nc_data_long()
      else if(dataset == TAB_DATA_WIDE)
        to_download = filter_nc_data()
      else if(dataset == TAB_SUMMARY)
        to_download = filter_summary_data_(input, FALSE)
      else # Detailed summary
        to_download = filter_detailed_summary_data_(input, FALSE)
      
      write.csv(to_download, gzfile(file), row.names = FALSE, na = "")
    }
  )
  
  output$downloadFull = downloadHandler(
    filename = function() {
      dataset = input$dataset
      
      if(dataset == TAB_DATA_LONG) 
        return(META$FILENAME_LONG)
      else if(dataset == TAB_DATA_WIDE)
        return(META$FILENAME_WIDE)
      else if(dataset == TAB_SUMMARY) 
        return(paste0("ICCAT_T1NC_summary_", str_replace_all(META$LAST_UPDATE, "\\-", ""), "_full.csv.gz"))
      else # Detailed summary
        return(paste0("ICCAT_T1NC_detailed_summary_", str_replace_all(META$LAST_UPDATE, "\\-", ""), "_full.csv.gz"))
    },
    content = function(file) {
      dataset = input$dataset
      
      if(dataset == TAB_DATA_LONG)
        file.copy(paste0("www/", META$FILENAME_LONG), file)
      else if(dataset == TAB_DATA_WIDE)
        file.copy(paste0("www/", META$FILENAME_LONG), file)
      else {
        if(dataset == "Summary") 
          to_download = filter_summary_data_(EMPTY_FILTER, FALSE)
        else # Detailed summary
          to_download = filter_detailed_summary_data_(EMPTY_FILTER, FALSE)
        
        write.csv(to_download, gzfile(file), row.names = FALSE, na = "")
      } 
    }
  )
}

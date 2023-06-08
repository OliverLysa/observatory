# *******************************************************************************
# Extraction functions
#********************************************************************************

# Read all sheets of an excel file
read_excel_allsheets <- function(filename, tibble = FALSE) {
  # but if you would prefer a tibble output, pass tibble = TRUE
  sheets <- readxl::excel_sheets(filename)
  x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
  if(!tibble) x <- lapply(x, as.data.frame)
  names(x) <- sheets
  x
}

# Use the OTS package to extract trade data from the UKTradeInfo API
extractor <- function(x) {
  trade_results <-
    load_ots(
      # The month argument specifies a range in the form of c(min, max)
      month = c(200801, 202112),
      flow = NULL,
      commodity = c(x),
      country = NULL,
      print_url = TRUE,
      join_lookup = TRUE,
      output = "df"
    )
  trade_results <- trade_results %>%
    mutate(search_code = x)
  
  return(trade_results)
}

# *******************************************************************************
# Wrangling functions
#********************************************************************************

# Clean prodcom sheets
clean_prodcom <- function(df) {
    df %>% drop_na(1) %>%
    clean_names() %>%
    rename("Variable" = 1) %>%
    # filter(!grepl('Note', Variable)) %>%
    filter(!grepl("type change",Variable)) %>%
    filter(Variable != c("SIC Totals and Non Production Headings"))
    
}

# Calculate CDF from Weibull parameters
cdweibull <- function(x, shape, scale, log = FALSE){
  dd <- dweibull(x, shape= shape, scale = scale, log = log)
  dd <- 1-(cumsum(dd) * c(0, diff(x)))
  return(dd)
}
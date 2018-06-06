# 
# Server logic to display the data table
#

library(shiny)
library(dplyr)

shinyServer(function(input, output) {
  # Read the table data
  # Make the column names nice
  tbl_dat <- readRDS("experiment_table.rds") %>%
    rename("File" = mzml_file,
           "Scan Cnt (Tot)" = scan_count_tot,
           "Scan Cnt (MS1)" = scan_count_ms1,
           "Scan Cnt (MS2)" = scan_count_ms2,
           "Exp Time (sec)" = end_time,
           "Barcode" = barcode,
           "Patient" = patient,
           "Collection Time" = collection_time,
           "Collection Date" = collection_date,
           "Notes" = notes)
  
  # Display the table
  output$exp_tbl <- DT::renderDataTable({
    DT::datatable(tbl_dat, 
                  filter = "top", 
                  rownames = FALSE) %>%
                  DT::formatRound(5, digits = 0)
  })
})

# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(mzR)
library(dplyr)
library(ggplot2)

shinyServer(function(input, output) {
  
  
  ms_data <- reactive({
    input$load_btn
    isolate(openMSfile(file.path(mzml_dir, input$mzml_file), backend = "pwiz"))
  })
  

  ms1_peaks <- reactive({
    if (input$load_btn == 0) {
      return(NULL)
    }
    
    scan_headers <- header(ms_data()) %>% filter(msLevel == 1)
    peaks(ms_data(), scan_headers$seqNum)
  })
  
  ms2_peaks <- reactive({
    if (input$load_btn == 0) {
      return(NULL)
    }
    
    scan_headers <- header(ms_data()) %>% filter(msLevel == 2)
    peaks(ms_data(), scan_headers$seqNum)
  })
  
  observeEvent(input$load_btn, {
    withProgress({
      ms_data()
      incProgress(1/3)
      ms1_peaks()
      incProgress(1/3)
      ms2_peaks()
      incProgress(1/3)
    }, message = "Loading Data...")
  })
  
  
  
  output$spectrum_plot <- renderPlot({
    if (input$load_btn == 0) {
      return(NULL)
    }
    
    ms_lvl <- NA
    sel_peaks <- NA
    if (input$ms_lvl == "MS1") {
      ms_lvl <- 1
      sel_peaks <- ms1_peaks()
    } else {
      ms_lvl <- 2
      sel_peaks <- ms2_peaks()
    }
    
    spec_num <- input$spec_num
    if (spec_num > length(sel_peaks)) {
      spec_num <- 1
    }
    
    plot_spectrum(spec_num, ms_lvl, sel_peaks)
  })
  
  output$spec_num_slider <- renderUI({
    max_num <- ifelse(input$ms_lvl == "MS1", length(ms1_peaks()), length(ms2_peaks()))
    sliderInput("spec_num", 
                "Spectrum Number",
                min = 1,
                max = max_num,
                value = 1,
                step = 1,
                animate = TRUE)
  })
  
})
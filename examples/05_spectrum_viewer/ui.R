#
# spectrum_viewer UI
#

library(shiny)

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Spectrum Viewer: 20 Sample DBS Collection"),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(width = 4,
      selectInput("mzml_file",
                  "mzML File",
                  choices = mzml_names),
      actionButton("load_btn", "Load Data"),
      hr(),
      selectInput("ms_lvl",
                  "MS Level",
                  choices = c("MS1", "MS2")),
      
      uiOutput("spec_num_slider")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("spectrum_plot")
    )
  )
))
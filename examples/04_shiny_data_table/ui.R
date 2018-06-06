#
# Basic UI to show an interactive data table
#

library(shiny)

shinyUI(basicPage(
  h2("Experimental Data Table"),
  hr(),
  DT::dataTableOutput('exp_tbl')  
))

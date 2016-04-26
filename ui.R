library(shiny)
library(shinyFiles)
#library(gdata)
options(shiny.maxRequestSize=500*1024^2) 
# Define UI for slider demo application
shinyUI(pageWithSidebar(
  #  Application title
  headerPanel("DE-Visualization"),
  
  # Sidebar with sliders that demonstrate various available options
  sidebarPanel(width=12,height=20,
               # file
               fileInput("filename", label = "File input (support .csv, .txt, .tab)"),
               
               # grouping vector
               fileInput("ConditionVector", label = "Condition vector \n file name (e.g. collection time. support .csv, .txt, .tab)"),
               
               # List of key markers 
               fileInput("Markers", label = "List of DE genes \n file name (support .csv, .txt, .tab)"),
               
               column(4,
                      # Heatmap
                      radioButtons("heatmap_button",
                                   label = "Do you want heatmap?",
                                   choices = list("Yes" = 1,
                                                  "No" = 2),
                                   selected = 1),
			          # Violin plot
			          radioButtons("violin_button",
                                   label = "Do you want violin plot?",# with individual observations displayed with jitter
                                   choices = list("Yes" = 1,
                                                  "No"=2),
                                   selected = 1),
			          # Normalization
			          radioButtons("Norm_button",
                                   label = "Do you need normalization?",
                                   choices = list("Yes" = 1,
                                                  "No" = 2),
                                   selected = 2),
			          # Outlier
			          radioButtons("OL_whether",
                                   label = "Do you want to adjust outlier (top/bottom 5%)?",
                                   choices = list("Yes" = 1,
                                                  "No" = 2),
                                   selected = 2)
								          				
               ),
               
               column(width=4,
                     # For heatmap:
                     radioButtons("CluByRow_button",
                                  label = "Heatmap: Do you want to cluster by row?",
                                  choices = list("Yes" = 1,
                                                 "No" = 2),
                                  selected = 1),
                      # For heatmap:
                     radioButtons("scale_button",
                                  label = "Heatmap: Do you want to scale data within a row?",
                                  choices = list("Yes" = 1,
                                               "No" = 2),
                                  selected = 1),
                     # For heatmap: 
                     radioButtons("color_button",
                                   label = "Heatmap: Do you want to keep Red/Green theme?",
                                   choices = list("Yes" = 1,
                                                  "No" = 2),
                                   selected = 1)								       
               ),
               
               column(width=4,    
                      # Violin: plot log-exp or not
                      radioButtons("log_whether",
                                   label = "Violin: Plot in log scale?",
                                   choices = list("log2(expression + 1)" = 1,
                                                  "No" = 2),
                                   selected = 2),
                      
                      # output dir
                      shinyDirButton('Outdir', 'output folder select', 'Please select a folder'),
                      br(),
                      br(),
                      
                      # plot name
                      textInput("HeatmapName", 
                                label = "Export file name for the heatmap?", 
                                value = "PlotHeatmap"),
                      
                      textInput("ViolinPlotName", 
                                label = "Export file name for the violin plots?", 
                                value = "PlotViolin")

               ),
               br(),
			          br(),
               actionButton("Submit","Submit for processing")
  ),
  
  # Show a table summarizing the values entered
  mainPanel(
    h4(textOutput("print0")),
    #tableOutput("values")
    dataTableOutput("tab")
  )
))

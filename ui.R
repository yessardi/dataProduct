
shinyUI(navbarPage('My Shiny Application',

                   tabPanel('Introduction',
                           includeMarkdown('intro.Rmd')
                           #includeHTML('index.html')
                   ),

                   tabPanel('The GEO transcriptomics datasets explorer', 
                        
                            
                            fluidPage(
                                    titlePanel("ROC for 12 GSEs (studies) and 1260 GSMs (samples)"),
                                    sidebarLayout(position = "left",
                                                  sidebarPanel(h3("Control Panel"),
                                                               checkboxInput("doProcessed", "ROC for heterogeneous data", value = T),
                                                               checkboxInput("doRaw", "ROC for homogeneous data", value = T),
                                                               
                                                                                                 
                                                               selectizeInput(
                                                                       'geoID', 'Choose one or more GSEs',choices = tempGEOList, multiple = TRUE
                                                               ),
                                                               
                                                               textInput(inputId="setid", label = "Input a keyword for GSE-sample IDs"),
                                                               radioButtons("radio", label = h5("Heterogeneous or Homogeneous"),
                                                                            choices = list("Heterogeneous" = 1, "Homogeneous" = 2), 
                                                                            selected = 1),
                                                               
                                                               sliderInput("slider1", label = h6("Sensitivity"), min = 0, 
                                                                           max = 1, value = c(0, 1)),
                                                               sliderInput("slider2", label = h6("1-Specificity"), min = 0, 
                                                                           max = 1, value = c(0, 1)),
                                                               fileInput('file1', 'Choose a manually-curated list file',
                                                                         accept=c('text/csv',
                                                                                  'text/xlsx',
                                                                                  'text/comma-separated-values,text/plain', 
                                                                                  '.csv'))

                                                  ),

                                                  mainPanel(
                                                          tabsetPanel(type = "tabs", 
                                                                      tabPanel("Plot", 
                                                                               textOutput("caption"),
                                                                              
                                                                               fluidRow(title="Heterogeneous (left) versus Homogeneous (right)",
                                                                                        h2("Heterogeneous (left) versus Homogeneous (right)"),
                                                                                        splitLayout(cellWidths = c("50%", "50%"), 
                                                                                                    plotOutput("p_processed",
                                                                                                               # click = "plot_click",
                                                                                                               #                                                                                                                dblclick = dblclickOpts(
                                                                                                               #                                                                                                                        id = "plot_dblclick"
                                                                                                               #                                                                                                                ),
                                                                                                               hover = hoverOpts(
                                                                                                                       id = "plot_hover"
                                                                                                               ),
                                                                                                               brush = brushOpts(
                                                                                                                       id = "plot_brush"
                                                                                                               )
                                                                                                               
                                                                                                    ), 
                                                                                                    plotOutput("p_raw",
                                                                                                               hover = hoverOpts(
                                                                                                                       id = "plot_hover"
                                                                                                               ),
                                                                                                               brush = brushOpts(
                                                                                                                       id = "plot_brush"
                                                                                                               )
                                                                                                    ),
                                                                                                    style = "border: 1px solid silver;",
                                                                                                    cellArgs = list(style = "padding: 6px")
                                                                                        ),
                                                                                        
                                                                                        fluidRow(title='X-Y cooridinates',
                                                                                            
                                                                                                 column(width = 4,
                                                                                                        tableOutput("output_hover")
                                                                                                 ),
                                                                                                 column(width = 6,
                                                                                                        tableOutput("output_brush")
                                                                                                 )
                                                                                        )
                                                                                        
                
                                                                               ),
                                                                               
                                                                               fluidRow(title='Metadata table of the selected ROC curves', 
                                                                                        DT::dataTableOutput('selection')
                                                                               )
                                                                      ),
                                                                      tabPanel("Manually-currated list",tableOutput('dfAll') )
                                                             
                                                                     
                                                          )
  
                                                  ) # mainPanel
                                    )
                                    # tabPanel
                                    
                                    
                                    
                            ) # fluidPage
                            
                   ), # tabPanel('tab 1'
                   
                   tabPanel("About",
                            # mainPanel(
                            includeMarkdown("about.Rmd")
                            # includeMarkdown("about.Rmd")
                            # )
                   )
                   
                   
) # navbarPage

)
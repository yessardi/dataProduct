
shinyServer(
        function(input, output) {
   
        ### show what keywords you use:
                
                formulaText <- reactive({
                        paste("The key word you have input is: ",  input$setid)
                })

        ### control plots:
                
                gOutput_processed<-g_processed  # avoid manipulating the original variable
                gOutput_processed<-gOutput_processed+theme(legend.position="none")  
                
                gOutput_raw<-g_raw
                gOutput_raw<-gOutput_raw+theme(legend.position="none")  
                
                # choice menu
                selectedChoices <- reactive({
                        # for (i in 1:length(input$geoID)){
                                str<-paste0(input$geoID,collapse = '|')
                                str<-paste0('(',str,')')
                        # }
                        })
                # select menu
                selectedData <- reactive({
                        
                        # impose the choice 
                        iChoice<-ifelse(selectedChoices()=='','GSE',selectedChoices())
                        iSetid<-ifelse (input$setid=='','GSE',input$setid)

                                # impose the slider
                                ggData_processed<-g_processed$data[genList(),]
                                ggData_raw<-g_raw$data[genList(),]
                                
                                ggData_processed<-filter(ggData_processed,str_detect(group,iChoice)&str_detect(group,iSetid)) #&str_detect(group,input$setid)
                                ggData_raw<-filter(ggData_raw,str_detect(group,iChoice)&str_detect(group,iSetid)) #&str_detect(group,input$setid)
                                
                        output$caption <-renderText({formulaText()})
                        
                        return(list(ggData_processed,ggData_raw))
                        })
#                 output$caption <- reactiveText(function() {
#                         formulaText()
#                 })
                # output$geoid <- reactive(renderText({input$setid}))
                
                # 'GSE53987_GSM1305055'
                library(dplyr)
                library(stringr)
#                 gOutput_processed<-g_processed
#                 gOutput_raw<-g_raw
              
                       
             
                output$selection <-  DT::renderDataTable({
                        
#                         mychoice<-selectedData()
#                         IDmatched<-str_match(g_processed$data[[3]],paste0(selectedData(),'.*'))
#                         data.frame(GEO_samples=unique(g_processed$data[[3]][!is.na(IDmatched)]))
#                         
                        mychoice<-selectedData()[[2]][[3]] # selectedData() indicates that the references of raw data is used
                        
                        # mychoice<-ffff[[3]]
                        # [[2]], raw data
                        # [[3]], processed data
                        
                        #IDmatched<-str_match(g_processed$data[[3]],paste0(selectedData(),'.*'))
                        
                        GEOsampleList<-data.frame(GEO_samples=unique(mychoice))
                        keyphraseGSM<-str_extract(GEOsampleList[[1]],'GSM\\d+')
                        keyphraseGSMcombined<-paste(keyphraseGSM,collapse = '|')
                        
                        # GSEs usually contain fewer 
                        
                        keyphraseGSE<-unique(str_extract(GEOsampleList[[1]],'GSE\\d+')) 
                        keyphraseGSEcombined<-paste(keyphraseGSE,collapse = '|')
                        
                        # find all GSEs
                        
                        listGSEMetaData<-filter(GEOMetaDataList,str_detect(gse,keyphraseGSEcombined))

                        # find all GSMs
                        listGSMMetaData<-filter(listGSEMetaData,str_detect(gsm,keyphraseGSMcombined))
#                         }
                        listGSMMetaDataSelected<-select(listGSMMetaData,-characteristics_ch2)
                        # eeeee<-filter(GEOMetaDataList,str_detect(gsm,'GSM488113|GSM488114'))
                        DT::datatable(listGSMMetaDataSelected, extensions = c('Buttons','ColReorder','Responsive'),options = list(lengthMenu = list(c(5, 30, -1),
                                                                              list('5','30','All')), pageLength = 5,
                                                                              dom = 'Bfrtip',
                                                                              buttons = c('copy', 'print'),# 'csv','excel','pdf', 'print','colvis'),
                                                                              colReorder = TRUE
                                                                              ))

                       # return(listGSMMetaData)
                })
                
                genList <-reactive({ 
                        slide1Min<-input$slider1[[1]] 
                        slide1Max<-input$slider1[[2]]
                        
                        slide2Min<-input$slider2[[1]] 
                        slide2Max<-input$slider2[[2]]
                        
                        if (input$radio==1){
                                listID<-unique(g_processed$data$group[g_processed$data$Sensitivity>=slide1Min&g_processed$data$Sensitivity<=slide1Max&g_processed$data$Specificity>=slide2Min&g_processed$data$Specificity<=slide2Max])  # obtain the list 
                                selectedList<-g_processed$data$group %in% listID
                                
                        } else if  (input$radio==2){
                                listID<-unique(g_raw$data$group[g_raw$data$Sensitivity>=slide1Min&g_raw$data$Sensitivity<=slide1Max&g_raw$data$Specificity>=slide2Min&g_raw$data$Specificity<=slide2Max])

                                selectedList<-g_raw$data$group %in% listID  # contains a list of GSE_sample IDs
                                
                        }
                        return(selectedList)
                        
                })

                #                 output$processed= renderPlot({p1})
                #                 output$raw = renderPlot({p2})
                
                #                         print(gOutput_processed)
                #                         print(gOutput_raw)
                
                pt1 <- reactive({
                        input$doProcessed
                        if (input$doProcessed){
                                
                                #                         gOutput_processed$data<-filter(g_processed$data,str_detect(group,selectedData()))
                                #                         gOutput_processed<-gOutput_processed+theme(legend.position="none")  
                                #print(gOutput_processed)
                                gOutput_processed$data<-selectedData()[[1]]
                                gOutput_processed
                        } else {
                                return(NULL)
                        }
                })
                
                pt2<- reactive({
                        input$doRaw
                        if (input$doRaw){
                                
                                #print(gOutput_raw)
                                gOutput_raw$data<-selectedData()[[2]]
                                gOutput_raw
                        } else {
                                return(NULL)
                        }
                        
                })

                
# Tab 1              
                ## plots
                
                output$p_processed <- renderPlot({
                        withProgress(pt1(),
                                     message = 'The ROC curves for the Heterogeneous are being generated')
               
                        })
                
                output$p_raw <- renderPlot({
                        withProgress(pt2(),
                                     message = 'The ROCs curves for the Homogeneous data are being generated')
                        })
    
                output$output_hover <- renderTable({

                        hoverInfo<-data.frame("x_value"=input$plot_hover$x, "y_value"=input$plot_hover$y)

                }, include.rownames=FALSE)

                output$output_brush <- renderTable({

                        hoverInfo<-data.frame("min_x_value"=input$plot_brush$xmin, 
                                              "max_x_value"=input$plot_brush$xmax,
                                              "min_y_value"=input$plot_brush$ymin, 
                                              "max_y_value"=input$plot_brush$ymax
                                              )
                        # row.names(hoverInfo)<-'hoever_reading'
                },include.rownames=FALSE)
                
# Tab 2       
           ## tables of the manually curated list
                
                output$dfAll <- renderTable({
                        
                        # input$file1 will be NULL initially. After the user selects
                        # and uploads a file, it will be a data frame with 'name',
                        # 'size', 'type', and 'datapath' columns. The 'datapath'
                        # column will contain the local filenames where the data can
                        # be found.
                        
                        inFile <- input$file1
                        
                        if (is.null(inFile)){
  
                                path.manuallyCurated<-"/Users/longfeimao/work/sbgCloud/programReconstruction/results/reconstructionGeneralTests/excelFiles/manualCuration/geneLists/DN_active_inactive_Entrez_20160601.xlsx"
                                inFile$datapath<-path.manuallyCurated
                        }
                        tML<-tryCatch(readManualLists(inFile$datapath),error=function(e) e)
                        if (!inherits(tML,'error')){
                                df.all<-readManualLists(inFile$datapath)
                        }

                        data.frame(Type=df.all[[2]],EntrezID=as.character(df.all[[1]]))

                })

                
        })


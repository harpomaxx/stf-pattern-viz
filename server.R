library(shiny)
library(MASS)
library('plotly')
#global variales
# TODO:
# 1. Solo se consideran los primeros 300 parametros


#Global variables

nbar_column=15
nbar_row=20
max_number_bar=300

shinyServer(function(input, output,session) {
  
  get_data <- reactive ({
    data = read.csv(
      file = paste('data/ranking_with_leng_of_word_', input$size, '.txt', sep = ''),
      sep = '|'
    )
    
  })
  
  get_data_filtered <- reactive({
    data <- get_data()
    datafiltered=data[grep(input$filterpattern,data$label),]
  })
  
  plot_width <- reactive({
    session$clientData$output_barplot_width
  })
  
  plot_height <- reactive({
    session$clientData$output_barplot_height
  })
  
  pixelratio <- reactive({
    session$clientData$pixelratio
  })
  
  results <- reactiveValues(patt = c())
  
  output$legend <- renderPlot({
    
    op <- par(
      pin = c(40,20),
      oma = c(0,0,0,0)
    )
    plot(1, type="n", axes=FALSE, xlab="", ylab="")
    legend(
      x = 1,
      y = 1,
      legend = c("Botnet", "Normal"),
      col = c('orange', 'skyblue'),
      pch = 15,
      cex = 1,
      horiz = TRUE,
      box.lwd = 0
    )
  })
  output$barplot <- renderImage({
  #  Rprof(tmp <- tempfile())
    outfile <- tempfile(fileext='.png')
    # Generate the PNG
    png(outfile, width=plot_width()*pixelratio(), height=plot_height()*pixelratio(),res=72*pixelratio()
    )
    datafiltered <- get_data_filtered()
    op <- par(
      mfrow = c(nbar_row, nbar_column),
      mar = c(0, 0, 0.25, 0) + 0.0
    )
    
    patterns = unique(datafiltered$pattern)
    min_total_freq = input$total
    min_label_freq = input$connection
    
    results$patt=c()
    pattern_counter = 0
    for (pattern in patterns) {
         pattern_rows<-datafiltered[which(datafiltered$pattern==pattern),]
         
         cur_freq<-pattern_rows[,2][1]
         cur_label_freq <-length(pattern_rows[, 4])
         
      if (cur_freq >= min_total_freq &&
           cur_label_freq>= min_label_freq)
      {
        pattern2 = pattern_rows[, c(3, 4)]
        
#       DEPRECATED
#       pattern2 = cbind(pattern2, rep(0))
#       pattern2[grep('Normal', pattern2$label), 3] = 0
#       pattern2[grep('Botnet', pattern2$label), 3] = 1
#       colnames(pattern2)[3] = 'type'
        
        pattern2 = cbind(pattern2, rep(0))
        pattern2[, 4] = pattern2$label_frequency / sum(pattern2$label_frequency) * 100
        colnames(pattern2)[4] = 'percent'
        
        pattern2 = pattern2[order(pattern2$label), ]
    
        cols = c()
        cols='red'
        cols[grep('Normal', pattern2$label)] = 'skyblue'
        cols[grep('Botnet', pattern2$label)] = 'orange'
        
        barplot(
          cbind(pattern2$percent),
          col = cols,
          las = 1,
          names.arg = paste(pattern, " [", sum(pattern2$label_frequency), "]"),
          yaxt = 'n',
          xaxt = 'n',
          border = 'black',
          cex.names = 0.75
        )
        
        isolate(results$patt <- rbind(results$patt, c(pattern,cur_freq,cur_label_freq)))
        pattern_counter = pattern_counter + 1
        if (pattern_counter == max_number_bar)
          break
      }
    }
    #Rprof(NULL)  
    #print(summaryRprof(tmp))
    dev.off()
   
    list(src = outfile,
         contentType = 'image/png',
         width = plot_width(),
         height = plot_height(),
         alt = "No valid image generated. Try a different word length")

  },deleteFile=T)
  
  output$info <- renderDataTable ({
    colnames(results$patt)<-c('pattern','total_freq','stf_conn')
    as.table(results$patt)
  }, options = list(pageLength = 10))
  
  
  output$click_info <- renderPlotly({
    initial_offsety=(plot_height())/nbar_row/2.0
    initial_offsetx=(plot_width()/nbar_column)/2.0
    
    if (!is.null(input$plot_click)) {
      plotnumbery=((input$plot_click$y-initial_offsety)/(plot_height()) ) *nbar_row
      plotnumberx=((input$plot_click$x-initial_offsetx)/(plot_width()) ) *nbar_column
      plotnumberx=round(plotnumberx)
      plotnumbery=round(plotnumbery)
    }
    else{
      plotnumberx=0
      plotnumbery=0
    }
    
    if ((plotnumberx+plotnumbery*nbar_column)+1 <= nrow(results$patt)){
      plot_pattern=results$patt[(plotnumberx+plotnumbery*nbar_column)+1,1]
    }else{
      plot_pattern=nrow(results$patt)-1
    }
      datafiltered<-get_data_filtered() #FIX 
      ax <- list(
        title = "Cumulative Frequency",
        zeroline = F,
        showline = T,
        showticklabels = T,
        showgrid = FALSE
      )
      ay <- list(
        title = "",
        zeroline = F,
        showline = T,
        showticklabels = F,
        showgrid = FALSE
      )
      
      cols=c()
      
      pattern_rows=datafiltered[which(datafiltered$pattern==plot_pattern),]
      freq=pattern_rows[,4]
      label=pattern_rows[,3]
      total_freq=pattern_rows[,2]
      
      cols[grep('Botnet', label)] = 'orange'
      cols[grep('Normal', label)] = 'skyblue'
      
      plot_ly(y=label,
              x=freq,type='bar',
              orientation='h',marker=list(color=cols)
      )
      layout(xaxis = ax, yaxis = ay,
             title=paste("Pattern: ",plot_pattern, "Total freq.:",total_freq[1]
             ),
             hovermode='closest')
      config(displayModeBar = F)
  })
  
})

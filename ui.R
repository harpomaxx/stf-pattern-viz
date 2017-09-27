library(shiny)
library(shinyBS)
library('plotly')

shinyUI(fluidPage(
  
  
  titlePanel("Behavioral Models Explorer (beta)"),
     # imageOutput("barplot", width = "100%", height = "500px",

  imageOutput("barplot", 
                 click = clickOpts(id="plot_click",clip = F)
             ),
  fluidRow(
    
    column(3,
           
           sliderInput("connection", label = h5("Select the minimun number of STF connections"),
                       min = 1, max = 100, value = c(1)),
           sliderInput("total", label = h5("Select the minimun number of pattern repetition"),
                       min = 1, max = 100, value = c(1))
           ),
   # column(5,
   #         div(dataTableOutput("info"), style = "font-size:70%")
   #   ),       
  
    
    column(width = 6,
        #plotOutput("legend",width = "100%", height = "50"),   
        plotlyOutput("click_info", width = "100%", height = "300")
        #verbatimTextOutput("click_info")
    
    ),

   column(width = 3,
          sliderInput("size", label = h5("Select the number of flows in ST connection (e.g. Word length)"),
                      min = 5, max = 100, value = c(5)),
          textInput("filterpattern", label = h5("General Label Filter Pattern (e.g. TCP)") ,
                    value = '[a-zA-Z0-9]'),
          textInput("colorpattern1", label = h5("Color Filter Pattern (skyblue)"), 
                    value = 'Normal'),
          textInput("colorpattern2", label = h5("Color Filter Pattern (orang)e"), 
                    value = 'Botnet')
              )
   
     )
)
)
  



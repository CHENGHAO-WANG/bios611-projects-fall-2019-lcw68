library(shiny)
library(shinydashboard)
library(shinythemes)
#setwd("~/GitHub/bios611-projects-fall-2019-lcw68/project_2")
source("helper_functions.R")


# Define UI for application that draws three problems: Changing Trend of Different variables, Clients who rank the top n in times visiting UMD, and correlation among some specific variables
ui <- fluidPage(
  navbarPage(
    themeSelector(),
    #select the theme of page
    tabPanel("Problem 1",
             titlePanel("Changing Trend of Different Variables"),
             sidebarLayout(
               
               sidebarPanel(
                 # Input the variable you want to explore
                 selectInput(inputId = "var",
                             label = "Choose a variable to be y-axis",
                             choices = c("Food Provided for","Food Pounds","Clothing Items","School Kits","Diapers","Hygiene Kits"),
                             selected = "Food Provided for"),
                 
                 #Input the time unit base: It will give the average number
                 selectInput(inputId = "time",
                             label = "Choose a variable to be group based",
                             choices = c("year","month","weekday","Date"),
                             selected = "year"),
                 
                 # Input the period range of data you want to explore
                 sliderInput(inputId = "PeriodRange",
                             label = "Choose the year range of our plot",
                             min = 1980,
                             max = 2019,
                             value = c(1999,2019))
                            ),
                 mainPanel(
                   plotOutput(outputId = "TrendPlot")
                   #output plot
                 )
              )
            ),
    
    tabPanel("Problem 2",
            titlePanel("Clients who rank the top n in times visiting UMD"),
            # Find the client who has the nth most times in visiting UMD
             sidebarLayout(
               
               sidebarPanel(
                 numericInput(inputId = "Rank",
                              label = "Choose the rank of visiting times of the client to explore",
                              value = 1,
                              min = 1,
                              max = 1000),
                  br(),
                  textOutput(outputId = "comment")
               ),
               
               #The output results show the histogram of visiting times for selected Client and the time interval of the next two visits.
              mainPanel(
                plotOutput(outputId = "FreqPlot"),
                plotOutput(outputId = "Diffplot")
              )
              
            )
          ),
    tabPanel("Problem 3",
             titlePanel("Correlation Among Food Supply and Clothing Items and amount of people who receive the food"),
             
             # Explore the correlation among different variables in different time range
             sidebarLayout(
               
               sidebarPanel(
                 radioButtons(inputId = "x.axis",
                              label = "The variable we selected to be x axis",
                              choices = c("Food Pounds","Clothing Items","Food.average","Food Provided for","Diapers"),
                              selected = "Food Provided for"),
                 br(),
                 radioButtons(inputId = "y.axis",
                              label = "The variable we selected to be y axis",
                              choices = c("Food Pounds","Clothing Items","Food.average","Food Provided for","Diapers"),
                              selected = "Food Pounds"
                              ),
                 br(),
                 sliderInput(inputId = "range2",
                             label = "Choose the year range of our plot",
                             min = 1990,
                             max = 2019,
                             value = c(1999,2019))
               ),
               
               #The output results show the scatterplot and we grouped it by 4 quarters
               mainPanel(
                 plotOutput(outputId = "CorrPlot"),
                 helpText("The points are divided by quarters into 4 group and we want to see if there's some link between seasons and those data.",
                          "We do some filter work: Clear all the NA, remove the points whose 'Food Pounds' is greater than 500 and whose 'Food Provided for' <= 0")
               )
             )
    )
      )
      
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
  #Output the changing trend plot(some include both boxplot and scatterplot)
   output$TrendPlot <- renderPlot({
      
      fselect(input$var,input$time,input$PeriodRange)
   })
  
   #Output the frequency barplot
   output$FreqPlot <- renderPlot({
     n1 = clientamount(input$Rank)
     client.freq(n1[1])[[1]]
   })
   
   #Output the time interval plot
   output$Diffplot <- renderPlot({
     n1 = clientamount(input$Rank)
     client.difference(n1[1])[[1]]
   })
   
   #In the comment, we states the average times per client visiting UMD per year, and the average time lag
   output$comment <- renderText({
     n2 = clientamount(input$Rank)
     mean.p = client.difference(n2[1])[[2]]
     aveyear.p = client.freq(n2[1])[[2]]
     paste("Client",n2[1],"has",n2[2],"times visits to UMD, the average times visiting per year is",round(aveyear.p,3),"and the average time lag is",round(mean.p,3))
   })
   
   #For Problem 3, it shows the association between selected 2 variables
   output$CorrPlot <- renderPlot({
     Corr(input$x.axis,input$y.axis,input$range2)
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

# I will give explanation and conclusions in final project


library(rprojroot)
library(shiny)
library(shinyjs)
library(tidyverse)

#setwd(find_root_file(criterion = is_git_root, path = "."))

# import the tax rates, county and twp names:
twpRatesAndCodes <- readRDS(file.path(".", "inputs", "twpRatesAndCodes.rds"))
countyList <- unique(twpRatesAndCodes$county.rates)[c(2:14, 16:20)]

# Create selectInput(county), selectInput(township based on county), and textOutput from twp
selectTwp <- function(inputID, choiceID, outputID){
  list( selectInput(inputID, "Choose a County:", countyList),
        uiOutput(choiceID),
        textOutput(outputID))
}

ui <- fluidPage(
  useShinyjs(),
  
  titlePanel("Compare predicted township taxes for homes at different price points in New Jersey:"),
  fluidRow(
    column(12, 
           tags$p("Taxes depend on the assessed value of the property, which often differs from the sale price."),
           #tags$br(),
           tags$p("Use this utility to estimate assessment values and township taxes at different locations and price points. It accounts for aggregate trends in assessment, but in practice, the details of the specific property play a significant role. So please don't use this tool to make financial decisions :)"))
  ),
  fluidRow(
    column(12,
    numericInput("price", "How much will you spend to buy the property?", value = 150000)
  )),
  fluidRow(
    column(4,
           selectTwp(inputID = "county1", choiceID = "secondSelection1", outputID = "tax1")
            ),
    column(4,
           selectTwp(inputID = "county2", choiceID = "secondSelection2", outputID = "tax2")
    ),
    column(4,
           selectTwp(inputID = "county3", choiceID = "secondSelection3", outputID = "tax3")
    )
  ),
  fluidRow(
    column(12,
    tags$br(),
    tags$p("This tool uses the effective township tax rate from 2020. If you have more recent tax rates for all NJ townships, please let me know!"))
  )
)



server <- function(input, output, session) {
  source("tax-predictor-code.R")


  
  # Accepts a county name and returns a list of township names:
  twpChoices1 <- reactive(choice_func(input$county1))
  
  # Lets user choose a township off the correct list:
  output$secondSelection1 <- renderUI({
    selectInput("twp1", "Choose a Township:", choices = twpChoices1())
  })

  # Same as above, county and twp choice in column 2:
  twpChoices2 <- reactive(choice_func(input$county2))
  output$secondSelection2 <- renderUI({
    selectInput("twp2", "Choose a Township:", choices = twpChoices2())
  })

  # Same as above, county and twp choice in column 3:
  twpChoices3 <- reactive(choice_func(input$county3))
  
  output$secondSelection3 <- renderUI({
    selectInput("twp3", "Choose a Township:", choices = twpChoices3())
  })
  
  
  
  
#############
  # Get the data set for the first county's Sales Ratios
  countyTBL1 <- reactive({
    countyFile <- file.path(".", "inputs", "tidy_county",
                        gsub(" ", "", stringr::str_to_lower(as.character(input$county1))))
    read_csv(countyFile)
  })
  # Calculate the predicted tax
  delay(500,
        output$tax1 <- renderText({
          taxPredictor(countyTBL1(), input$twp1, input$price)
        })
        )

  
  # Second county:
  countyTBL2 <- reactive({
    countyFile <- file.path(".", "inputs", "tidy_county",
                        gsub(" ", "", stringr::str_to_lower(as.character(input$county2))))
    read_csv(countyFile)
  })
  delay(500,
        output$tax2 <- renderText({
          taxPredictor(countyTBL2(), input$twp2, input$price)
        })
        )

  
  # Third county:
  countyTBL3 <- reactive({
    countyFile <- file.path(".", "inputs", "tidy_county",
                       gsub(" ", "", stringr::str_to_lower(as.character(input$county3))))
    read_csv(countyFile)
  })
  delay(500, 
        output$tax3 <- renderText({
          taxPredictor(countyTBL3(), input$twp3, input$price)
        })
        )

  
}

shinyApp(ui, server)


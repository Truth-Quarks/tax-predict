library(shiny)
library(tidyverse)

# NOTE: DATA SHOULD BE EDITED TO EXCLUDE NON-RESIDENTIAL

# import the tax rates, county and twp names:
twpRatesAndCodes <- readRDS(file.path("~", "R", "taxPredict", "twpRatesAndCodes.rds"))
countyList <- unique(twpRatesAndCodes$county.rates)[2:20]


# Create selectInput(county), selectInput(township based on county), and textOutput from twp
selectTwp <- function(inputID, choiceID, outputID){
  list( selectInput(inputID, "Choose a County:", countyList),
        uiOutput(choiceID),
        textOutput(outputID))
}

ui <- fluidPage(
  
  
  titlePanel("Predict taxes for homes in New Jersey:"),
  fluidRow(
    numericInput("price", "How much would you like to spend?", value = 150000)
  ),
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
  )
)



server <- function(input, output, session) {
  # source("taxPredictor.R")
  # A function that accepts a county name and returns a list of twp names:
  choice_func <- function(inputVal){
    filterCo <- twpRatesAndCodes %>% 
      filter(county.rates == inputVal)
    unique(filterCo$town.codes)
  }
  
  # Estimate the sales ratio based on township and price, then estimate assessment 
  # and last year's tax
  # df is the tidied county data frame sent to countyTBL, twpChoice and priceChoice
  # are passed inputs
  taxPredictor <- function(df, twpChoice, priceChoice){
    # filter the county data by twp
    dfSub <- df %>%
      filter(twp == as.character(twpChoice))
    # If there are 30+ values, plot a trend line to adjust sales ratio for price
    if (nrow(dfSub) > 29){
      priceBiasTrend <- lm(adjSR ~ price, dfSub)
      SR_hat <- predict(priceBiasTrend, data.frame(price = priceChoice))
      # otherwise
    } else if(nrow(dfSub) > 0){
      SR_hat <- mean(dfSub$adjSR)
    } else stop("no data")
    
    assess_pred <- SR_hat * priceChoice
    last_yrs_tax <- assess_pred * (0.01*dfSub$General_Rate[1])
    as.character(last_yrs_tax)
    
  }
  
  
  
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
  # Get the data set fot the first county SRs
  countyTBL1 <- reactive({
    countyFile <- paste("~/R/taxPredict/", 
                        stringr::str_to_lower(as.character(input$county1)), sep = "")
    read_csv(countyFile)
  })
  # Calculate the predicted tax
  output$tax1 <- renderText({
    taxPredictor(countyTBL1(), input$twp1, input$price)
  })
  
  # Second county:
  countyTBL2 <- reactive({
    countyFile <- paste("~/R/taxPredict/", 
                        stringr::str_to_lower(as.character(input$county2)), sep = "")
    read_csv(countyFile)
  })
  output$tax2 <- renderText({
    taxPredictor(countyTBL2(), input$twp2, input$price)
  })
  
  # Third county:
  countyTBL3 <- reactive({
    countyFile <- paste("~/R/taxPredict/", 
                        stringr::str_to_lower(as.character(input$county3)), sep = "")
    read_csv(countyFile)
  })
  output$tax3 <- renderText({
    taxPredictor(countyTBL3(), input$twp3, input$price)
  })

  
}

shinyApp(ui, server)


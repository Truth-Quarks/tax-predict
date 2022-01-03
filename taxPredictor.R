
# import the tax rates, county and twp names:
twpRatesAndCodes <- readRDS(file.path("~", "inputs", "twpRatesAndCodes.rds"))
countyList <- unique(twpRatesAndCodes$county.rates)[2:20]


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
  } else {SR_hat <- mean(dfSub$adjSR)}
  
  assess_pred <- SR_hat * priceChoice  
  last_yrs_tax <- assess_pred * (0.01*dfSub$General_Rate[1])
  txt_assess_pred <- paste("The predicted assessment is $", round(assess_pred, digits = 2), sep = "")
  txt_last_yrs_tax <- paste("Last year's tax would have been $", round(last_yrs_tax, digits = 2), sep = "")
  paste0(txt_assess_pred, ". \n", txt_last_yrs_tax, ".", sep = "")
}

testFunc <- function(df){
  return(df[3,3])
}







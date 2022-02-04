
# import the tax rates, county and twp names:
#setwd(find_root_file(criterion = is_git_root, path = "."))
twpRatesAndCodes <- readRDS(file.path(".", "inputs", "twpRatesAndCodes.rds"))
countyList <- unique(twpRatesAndCodes$county.rates)[c(2:14, 16:20)]

# A function that accepts a county name and returns a list of township names:
choice_func <- function(inputVal) {
  filterCo <- twpRatesAndCodes %>% 
    filter(county.rates == inputVal)
  unique(filterCo$town.codes)
}

# Estimate the sales ratio based on township and price, then estimate assessment 
# and last year's tax
# df is the tidied county data frame sent to countyTBL, twpChoice and priceChoice
# are passed inputs
taxPredictor <- function(df, twpChoice, priceChoice) {
  # filter the county data by twp
  dfSub <- df %>%
    filter(twp == as.character(twpChoice))
  # If there are 30+ values, plot a trend line to adjust sales ratio for price
  if (nrow(dfSub) > 29){
    # Check if priceChoice is in the historical price range for that twp
    lowest <- min(dfSub$price)
    highest <- max(dfSub$price)
    if (priceChoice > highest | priceChoice < lowest) {
      extrapolation_notice <<- "This sale price is outside the range of data we have for this township. Results may get wonky!"
    } else {extrapolation_notice <<- ""}
    priceBiasTrend <- lm(adjSR ~ price, dfSub)
    SR_hat <- predict(priceBiasTrend, data.frame(price = priceChoice))
    # otherwise
  } else if (nrow(dfSub > 0)){
      SR_hat <- mean(dfSub$adjSR) 
  } else { #if a township has no data, use the county mean
      SR_hat <- mean(df$adjSR)
    }
  
  
  assess_pred <- SR_hat * priceChoice  
  last_yrs_tax <- assess_pred * (0.01*dfSub$General_Rate[1])
  txt_assess_pred <- paste("The predicted assessment is $", round(assess_pred, digits = 2), sep = "")
  txt_last_yrs_tax <- paste("Last year's tax would have been $", round(last_yrs_tax, digits = 2), sep = "")
  paste0(extrapolation_notice, "\n", txt_assess_pred, ". \n", txt_last_yrs_tax, ".", sep = "")
}

testFunc <- function(df) {
  return(df[3,3])
}







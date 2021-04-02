# tax-predict
Use sales ratios and market trends to predict taxes for NJ properties, given a specific township and the amount paid for the property.

In broad strokes, it will:
  * use a tibble with columns: municipality, property class, assessment, price, naive_Sales_Ratio, and adj_Sales_Ratio; created in advance from public records.
  * take as an input a choice of either naive or adjusted sales ratio
  * calculate a predicted sales ratio SR_pred for a given price by:
    * using a linear model to model the way sales ratio varies by price within the township
    * using the mean sales ratio if there are too few data points for a linear model
    * using a linear model with county-wide data instead if there are no data points (and print a notice)
    * predicting an assessment = SR_pred * input$price
    * predicting an annual tax = assessment * twpTaxRate 
    * And adjusting by average annual tax increase (calculated separately)

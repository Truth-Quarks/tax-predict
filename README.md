# Tax Predicion Utility
A tool that uses sales ratios and market trends to predict taxes for NJ properties, given a specific township and the amount paid for the property. It contains code that generates the front and back ends using Shiny in R (tax-prediction-utility.R), the functions that do the actual calculations (tax-predictor-code.R), and a folder of input data. To use, clone the repo, open tax-prediction-utility.R in an IDE, and run the code.

### What it does:
When a county is selected, the utility pulls up the correct property sale data from the inputs folder. It filters the observations based on the selected township, and checks whether there are enough observations in the table to justify applying a linear trend line. Linear regression is used to model the way sales ratio varies by price within the township. This is necessary to account for price-related bias: more expensive properties often have different sales ratios than cheaper ones. If there are too few observations to model price-related bias, the mean sales ratio for the township is applied. The tool then predicts an assessment based on the price of the house, and an estimate of the annual tax for the township (using 2021 numbers).

### Inputs:
#### Tax Rate Data and Documentation
Includes a csv containing township names and their numeric codes(twpCode.csv), a text file with township tax rates (twpTaxRates.txt), the code to wrangle and join them (toJoinRatesAndCodes.R), and the result of that wrangling (twpRatesAndCodes.Rds)
#### Location, Price, and Sales Ratio Data
The tidy_county folder contains binary files of tables created in advance from public records. Each has the following columns: 

          county: string, county name
          code: string, county code
          class: string, property class (2=residential)
          price: int, property price in dollars
          naive_SR: double, naive sales ratio
          adj_SR: double, adjusted sales ratio 
          outlier: bool, whether this sale represents an outlier
          twp: string, township name
          General_Rate: double, township tax rate
          
The raw sales records, tidied versions, the transformed tibbles used here, and all the code used to create the tidy data and final tibbles are available in the sales-ratio repo.


Possible future adjustments include:

    * updating the tax rates 
    * adjusting by average annual tax increase (calculated separately)  
    * using a linear model with county-wide data instead if there are no data points in a particular township (and printing a notice)

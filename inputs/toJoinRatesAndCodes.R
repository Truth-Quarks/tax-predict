## TAX RATE SOURCES ##
# https://joeshimkus.com/NJ-Tax-Rates.aspx
# https://www.state.nj.us/treasury/taxation/lpt/taxrate.shtml

## MUNICIPALITY CODE SOURCE ##
# https://www.state.nj.us/treasury/taxation/pdf/current/county-muni-codes.pdf

library(rprojroot)
library(tidyverse)
library(fuzzyjoin)

setwd(find_root_file(is_git_root, path = "."))

# Read in the files
codes <- (read_csv(file.path("~", "inputs", "twpCode.csv"),
                   col_names = TRUE))
# Match up the column names
colnames(codes) <- c("code", "town", "county")
# trim the codes twp names
codes$town <- str_replace(codes$town, "(�)$", "")
codes$town <- str_replace(codes$town, "\\s(Twp[.]|Bor[.])", "")


rates <- read_csv(file.path("~", "inputs", "twpTaxRates.txt"))
# general tax rate is used to calculate taxes
rates <- rename(rates, county = County, town = Town)


(tester <- codes[1:10,])


#fuzzy-match as much as we can automatically:
my_str_detect <- function(x,y){str_detect(x, regex(y))}
twpJoin <- fuzzy_left_join(rates, codes, match_fun = my_str_detect,
                           by = c("county", "town"))


#get a list of matches:
matched <- codes$town %in% rates$town
# Unmatched towns from Rates table have a value for town.x; town.y == NA
unmatched_towns_from_rates <- twpJoin$town.x[which(is.na(twpJoin$town.y))]
# Unmatched towns from Codes table are not in the "matched" vector:
unmatched_towns_from_codes <- codes$town[!matched]



# Pick one town at a time from one list of the unmatched towns:
(unmatched_town <- unmatched_towns_from_rates[159])
# Find a fuzzy match for it on the other list of unmatched towns:
(codes_index <- agrep(pattern = unmatched_town, codes$town,
                      max.distance = 2))
# Check the content by hand:
(possible_match <- codes$town[codes_index[1]])
(codes_index <- which(codes$town == possible_match))
(join_index <- which(twpJoin$town.x == unmatched_town))

fixUp()
#
## repeat for all unmatched. Must be done by hand.


fixUp2(154, 138)
#
#
# Dover Twp Ocean has no code in codes, row 456 of twpJoin
# West Paterson, Passaic has no code in codes, row 496 of twpJoin
#
# If a match, replace the name in Codes with the exact name in Rates:
fixUp <- function(){
  twpJoin$code[join_index] <<- codes$code[codes_index]
  twpJoin$town.y[join_index] <<- codes$town[codes_index]
  twpJoin$county.y[join_index] <<- codes$county[codes_index]
}

fixUp2 <- function(empty, new){
  twpJoin$code[empty] <<- codes$code[new]
  twpJoin$town.y[empty] <<- codes$town[new]
  twpJoin$county.y[empty] <<- codes$county[new]
}




write_rds(twpJoin, file.path("~", "inputs", "twpRatesAndCodes.rds"))




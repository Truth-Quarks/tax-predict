message("Hi, Rachel! Here is your fortune:")

if(interactive()) 
  try(fortunes::fortune(), silent = TRUE)
options(prompt = "R> ", continue = "  ")

.Last = function() {
  cond = suppressWarnings(!require(fortunes, quietly = TRUE))
  if(cond) 
    try(install.packages("fortunes"), silent = TRUE)
  message("Goodbye at ", date(), "\n")
}
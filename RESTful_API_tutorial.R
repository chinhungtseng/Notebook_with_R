# reference: https://www.programmableweb.com/news/how-to-access-any-restful-api-using-r-language/how-to/2017/07/21

# basic steps:

# - Install the "httr" and "jsonlite" packages
# - Make a "GET" request to the API to pull raw data into your environment
# - "Parse" that data from its raw form through JavaScript Object Notification (JSON) into a usable format
# - Write a loop to "page" through that data and retrieve the full data set 
# - Apply the same mehodology to other APIs

library(httr)
library(jsonlite)

base <- "https://api-v2.intrinio.com/companies/AAPL?api_key="
keys <- "OjJlZmM1YjM4OWZjMWZkMjQyNjI5ODNjZWQzYjE0Yzcy"

request_url <- str_c(base, keys)
response <- GET(request_url)




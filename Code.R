# load libraries
library(RSelenium)
library(rvest)
library(data.table)
library(magrittr)

rm(list = ls())

# parent url
parent_url <- "https://market.yandex.ru/"

# sections
category_url <- "catalog/"

# category id
cat_id <- 54726 # mobile phones

# generate url for catergory
url <- paste0(parent_url, category_url, cat_id)

# load web-page
# start RSelenium
rD <- rsDriver()
remDr <- rD[["client"]]

# navigate to page
remDr$navigate(url)

# get page html
page_source <- read_html(remDr$getPageSource()[[1]])

# close RSelenium
remDr$close()
rD[["server"]]$stop()
rm(rD)

# main nodes with product details
nodes <- html_nodes(page_source, ".n-snippet-cell2")

# load data from web-page
Data <- data.table(
  # product identifiers
  ID = gsub("model-", "", html_attr(nodes, "data-id")),
  # product titles
  Title = html_nodes(nodes, ".n-snippet-cell2__title") %>% html_text(),
  # product main prices
  Main_Price = as.numeric(gsub(
    "[^0-9]", "", html_nodes(nodes, ".n-snippet-cell2__main-price") %>% html_text()
    )),
  # product lowest prices
  Best_Price = as.numeric(gsub(
    "[^0-9]", "", html_nodes(nodes, ".n-snippet-cell2__more-prices-link") %>% html_nodes(".price") %>% html_text()
    )),
  # product number of quotes
  Quotes = as.numeric(gsub(
    "[^0-9]", "", html_nodes(nodes, ".n-snippet-cell2__more-prices-link") %>% html_nodes(".link_type_prices") %>% html_text
    )),
  # product rating
  Rating = as.numeric(
    html_nodes(nodes, ".rating__value") %>% html_text()
    ),
  # product number of votes
  Votes = as.numeric(gsub(
    "[^0-9]", "", html_nodes(nodes, ".n-snippet-card2__rating") %>% html_nodes("span") %>% html_text()
    ))
)
     
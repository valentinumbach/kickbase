library(rvest)
library(dplyr)
# requires phantomjs in path

scrape_html <- function(url) {
  writeLines(sprintf("var page = require('webpage').create();
                      page.open('%s', function () {
                          console.log(page.content);
                          phantom.exit();
                      });", 
                     url), 
             con = "scrape.js")
  system("phantomjs scrape.js > scrape.html")
  page_html <- read_html("scrape.html")
  system("rm scrape.js scrape.html")
  return(page_html)
}
  
bundesliga <- scrape_html("https://www.whoscored.com/Regions/81/Tournaments/3/Germany-Bundesliga")

team_links <- bundesliga %>%
  html_nodes("tbody.standings .team-link") %>%
  html_attr("href") %>%
  unique() %>%
  paste0("https://www.whoscored.com", .)

for (t in 1:length(team_links)) {
  cat("Fetching team", t, "of", length(team_links), "\n")
  team <- scrape_html(team_links[t])
  
  player_links <- team %>%
    html_nodes(".player-link") %>%
    html_attr("href") %>%
    unique() %>%
    paste0("https://www.whoscored.com", .)
}


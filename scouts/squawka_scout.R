library(rvest)
library(httr)
library(jsonlite)
library(stringr)

bundesliga <- read_html("http://www.squawka.com/football-stats/german-bundesliga-season-2016-2017")

team_links <- bundesliga %>%
  html_nodes("#rd-league-standings .fsclt-club-link") %>%
  html_attr("href") %>%
  str_replace("stats", "squad")

for (t in 1:length(team_links)) {
  cat("Fetching team", t, "of", length(team_links), "\n")
  team <- read_html(team_links[t])
  team_name <- team %>%
    html_nodes(".team-name") %>%
    html_text()
  # get team players
  players <- team %>%
    html_nodes(".squad_playerphoto")
  player_ids <- players %>%
    html_nodes("img") %>%
    html_attr("src") %>%
    str_extract("(?<=players\\/p)[0-9]*") %>%
    as.numeric()
  player_names <- players %>%
    html_nodes("div") %>%
    html_text()
  players <- data.frame(player_id = player_ids, 
                        player_name = player_names,
                        team_name = team_name,
                        stringsAsFactors = F)
  players <- na.omit(players)
  if (t == 1) {
    all_players <- players
  } else {
    all_players <- rbind(all_players, players)
  }
}


# season 15/16 = 169
# season 16/17 = 682
# season 17/18 = 846

# full statistics
r <- GET("http://www.squawka.com/wp-content/themes/squawka_web/stats_process.php",
         query = list(player_id = 124,
                      competition_id = 682,
                      min = 1,
                      max = 34,
                      cub_id = 99))
c <- content(r, "text")
j <- fromJSON(c)

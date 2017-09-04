library(rvest)
library(dplyr)
library(stringr)

bundesliga <- read_html("https://www.ligainsider.de")
team_links <- bundesliga %>%
  html_nodes("#teamlogos .wappen") %>%
  html_attr("href") %>%
  paste0("https://www.ligainsider.de", ., "kader")

players <- data.frame(team_name = NULL, player_id = NULL, player_link = NULL)
for (t in 1:length(team_links)) {
  cat("Fetching team", t, "of", length(team_links), "\n")
  team <- read_html(team_links[t])
  team_name <- team %>%
    html_node("title") %>%
    html_text() %>%
    str_replace(" \\|.*", "")
  player_link <- team %>%
    html_nodes(".pic a") %>%
    html_attr("href") %>%
    paste0("https://www.ligainsider.de/", ., "note")
  player_id <- player_link %>%
    str_extract("(?<=_).*(?=\\/)") %>%
    as.integer()
  players <- rbind.data.frame(players,
                              cbind.data.frame(team_name, player_id, player_link,
                                               stringsAsFactors = F))
}

performance <- data.frame(player_id = NULL, player_name = NULL,
                          match_day = NULL, note = NULL)
for (p in 446:nrow(players)) {
  cat("Fetching player", p, "of", nrow(players), "\n")
  player <- read_html(players$player_link[p])
  player_name <- player %>%
    html_node("title") %>%
    html_text() %>%
    str_replace(" \\|.*", "")
  match_day <- player %>%
    html_nodes(".check_1 td:nth-child(1)") %>%
    html_text() %>%
    str_replace("\\.", "") %>%
    as.integer()
  note <- player %>%
    html_nodes(".note") %>%
    html_text() %>%
    str_replace(",", ".") %>%
    as.double()
  if (length(match_day) > 0 & length(note) > 0) {
    performance <- rbind.data.frame(performance,
                                    cbind.data.frame(player_id = players$player_id[p], 
                                                     player_name, match_day, note,
                                                     stringsAsFactors = F))
  }
}

performance <- performance %>%
  left_join(players) %>%
  select(player_id, player_name, team_name, match_day, note)

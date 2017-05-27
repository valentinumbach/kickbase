library(rvest)
library(dplyr)
library(stringr)
library(crayon)

# get bundesliga teams
bundesliga <- read_html("https://sofifa.com/teams?lg=19")

tmp <- xml_find_all(bundesliga, xpath = "//a[contains(@href,'/team/')]")
teams <- data.frame(team_id = rep(0, length(tmp)), team_name = NA)
teams$team_id <- tmp %>%
  html_attr("href") %>%
  str_replace("/team/", "") %>%
  as.numeric()
teams$team_name <- html_text(tmp)

for (t in 1:nrow(teams)) {
  # get team players
  cat("Fetching team", t, "of", nrow(teams), "\n")
  team <- read_html(paste0("https://sofifa.com/team/", teams$team_id[t]))
  
  tmp <- xml_find_all(team, xpath = "//a[contains(@href,'/player/')]")
  players <- data.frame(player_id = rep(0, length(tmp)), player_name = NA)
  players$player_id <- tmp %>%
    html_attr("href") %>%
    str_replace("/player/", "") %>%
    as.numeric()
  players$player_name <- html_attr(tmp, "title")
  if (t == 1) {
    all_players <- players
  } else {
    all_players <- rbind(all_players, players)
  }
}
all_players <- distinct(all_players)


score_labels <- c("Overall rating", "Potential",
                  "Crossing", "Finishing", "Heading accuracy", "Short passing", "Volleys",
                  "Dribbling", "Curve", "Free kick accuracy", "Long passing", "Ball control",
                  "Acceleration", "Sprint speed", "Agility", "Reactions", "Balance",
                  "Shot power", "Jumping", "Stamina", "Strength", "Long shots",
                  "Aggression", "Interceptions", "Positioning", "Vision", "Penalties", "Composure",
                  "Marking", "Standing tackle", "Sliding tackle",
                  "GK diving", "GK handling", "GK kicking", "GK positioning", "GK reflexes")
for (p in 1:nrow(all_players)) {
  # get player scores
  cat("Fetching player", p, "of", nrow(all_players), ":", all_players$player_name[p], "\n")
  player <- read_html(paste0("https://sofifa.com/player/", all_players$player_id[p]))
  
  team_name <- player %>%
    xml_find_first(xpath = "//a[contains(@href,'/team/')]") %>%
    html_text()
  
  scores <- rep(0, length(score_labels))
  for (s in 1:length(scores)) {
    tmp <- player %>%
      html_nodes(xpath = paste0("//*[not(self::script)][text()[contains(.,'", score_labels[s], "')]]")) %>%
      html_children()
    if (length(tmp) == 1) {
      scores[s] <- tmp %>%
        html_text() %>%
        as.numeric()
    } else if (length(tmp) > 1) {
      cat(yellow("Warning: player has multiple values for", score_labels[s]), "\n")
      scores[s] <- tmp[1] %>%
        html_text() %>%
        as.numeric()
    } else {
      cat(red("Error: player has no value for", score_labels[s]), "\n")
      scores[s] <- NA
    }
  }
  scores <- as.data.frame(t(scores))
  colnames(scores) <- score_labels
  scores$player_id <- all_players$player_id[p]
  scores$team_name <- team_name
  if (p == 1) {
    all_scores <- scores
  } else {
    all_scores <- rbind(all_scores, scores)
  }
}

player_scores <- left_join(all_players, all_scores, by = "player_id")

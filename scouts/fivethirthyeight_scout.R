library(rvest)
library(dplyr)
library(stringr)

bundesliga <- read_html("https://projects.fivethirtyeight.com/soccer-predictions/bundesliga/")

team_names <- bundesliga %>%
  html_nodes("#matches .team .name") %>%
  html_text() %>%
  head(18)

team_probs <- bundesliga %>%
  html_nodes("#matches .prob") %>%
  html_text() %>%
  head(27) %>%
  str_replace("%", "") %>%
  as.numeric() %>%
  "/"(100)

team_idx <- seq(1, 18, 2)
prob_idx <- seq(1, 27, 3)
fivethirtyeight_probs <- data.frame(home_team = team_names[team_idx],
                                    away_team = team_names[team_idx + 1],
                                    home_prob = team_probs[prob_idx],
                                    draw_prob = team_probs[prob_idx + 1],
                                    away_prob = team_probs[prob_idx + 2])

home <- fivethirtyeight_probs %>%
  select(team_name = home_team,
         fte_win = home_prob,
         fte_draw = draw_prob)
away <- fivethirtyeight_probs %>%
  select(team_name = away_team,
         fte_win = away_prob,
         fte_draw = draw_prob)
fivethirtyeight_teams <- home %>%
  union(away)

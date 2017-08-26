library(dplyr)
library(stringdist)
library(fuzzyjoin)

squawka <- readRDS("scouts/squawka.RDS")
sofifa <- readRDS("scouts/sofifa.RDS")

squawka_teams <- unique(squawka$team_name)
sofifa_teams <- sofifa %>%
  group_by(team_name) %>%
  summarize(players = n()) %>%
  filter(players > 11) %>%
  .$team_name

m <- stringdistmatrix(squawka_teams, sofifa_teams, 
                      method = "lcs", useNames = "strings")

am <- amatch(squawka_teams, sofifa_teams, method = "lcs", maxDist = 10)

match_teams <- cbind(squawka_teams[order(am)], sofifa_teams)

j <- stringdist_join(squawka, sofifa, by = "team_name", method = "lcs", max_dist = 10)

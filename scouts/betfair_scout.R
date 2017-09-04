library("abettor")
require("RCurl")
require("jsonlite")
library(dplyr)

loginBF(username = '***REMOVED***', password = '***REMOVED***', applicationKey = '***REMOVED***')

mc <- listMarketCatalogue(eventTypeIds = c('1'), competitionIds = c('59'), toDate = Sys.Date() + 21, marketTypeCodes = c('MATCH_ODDS'))

odds <- data.frame(tname = rep(NA, 27), odds = 0)
tcount <- 0
for (m in 1:length(mc$marketId)) {
  mb <- listMarketBook(marketIds = mc$marketId[m], priceData = 'EX_BEST_OFFERS')
  for (s in 1:3) {
    tcount <- tcount + 1
    sid <- mc$runners[[m]]$selectionId[s]
    odds$tname[tcount] <- mc$runners[[m]]$runnerName[s]
    odds$odds[tcount] <- mb$runners[[1]]$ex$availableToBack[[s]]$price[1]
  }
}

odds$probs <- round(1 / odds$odds, 2)

odds_idx <- seq(1, 27, 3)
betfair_odds <- data.frame(home_team = odds$tname[odds_idx],
                      away_team = odds$tname[odds_idx + 1],
                      home_prob = odds$probs[odds_idx],
                      draw_prob = odds$probs[odds_idx + 2],
                      away_prob = odds$probs[odds_idx + 1])

home <- betfair_odds %>%
  select(team_name = home_team,
         bf_win = home_prob,
         bf_draw = draw_prob)
away <- betfair_odds %>%
  select(team_name = away_team,
         bf_win = away_prob,
         bf_draw = draw_prob)
betfair_teams <- home %>%
  union(away)

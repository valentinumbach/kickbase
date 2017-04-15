library(jsonlite)
library(httr)
library(plyr)
library(dplyr)

# set up connection
set_kickbase_connection <- function(kickbase_user_agent) {
  host <- 'api.kkstr.com'
  headers <- add_headers(
    `user-agent` = kickbase_user_agent,
    `connection` = 'Keep-Alive',
    `accept-encoding` = 'gzip'
  )
  list(host = host, headers = headers)
}

# log in to get authentication cookie and ids
kickbase_login <- function(user, password, host = 'api.kkstr.com') {
  credentials <- list(email = kickbase_user,
                      password = kickbase_password,
                      ext = 'false')
  credentials_json <- toJSON(credentials, auto_unbox = T)
  url <- paste0(host, '/user/login')
  r <- POST(url, body = credentials_json, content_type_json(), encode = 'json')
  ck <- cookies(r)
  cookie <- set_cookies(kkstrauth = ck$value)
  c <- content(r)
  user_id <- c$user$id
  league_id <- c$leagues[[1]]$id
  list(cookie = cookie, user_id = user_id, league_id = league_id)
}

get_teams <- function(headers, cookie, host = 'api.kkstr.com') {
  url <- paste0(host, '/competition/table')
  r <- GET(url, headers, cookie)
  c <- content(r)
  teams <- ldply(c$t, data.frame)
}

get_players <- function(team_ids, headers, cookie, host = 'api.kkstr.com') {
  for (t in team_ids) {
    url <- paste0(host, '/competition/teams/', t, '/players')
    r <- GET(url, headers)
    c <- content(r)
    if(!exists('players')) {
      players <- ldply(c$p, data.frame, stringsAsFactors = F)
    } else {
      players <- union_all(players, ldply(c$p, data.frame, stringsAsFactors = F))
    }
  }
  return(players)
}

get_performance <- function(player_ids, league_id, match_days = 20, headers, cookie, host = 'api.kkstr.com') {
  for (p in player_ids) {
    url <- paste0(host, '/leagues/', league_id, '/players/', p, '/feed?start=0&filter=10')
    r <- GET(url, headers)
    c <- content(r)
    if(!exists('performance')) {
      performance <- ldply(c$items, data.frame, stringsAsFactors = F)
    } else {
      performance <- union_all(performance, ldply(c$items, data.frame, stringsAsFactors = F))
    }
  }
  colnames(performance) <- gsub('meta.', '', colnames(performance))
  return(performance)
}

get_market_values <- function(player_ids, league_id, days = 90, headers, cookie, host = 'api.kkstr.com') {
  for (p in player_ids) {
    url <- paste0(host, '/leagues/', league_id, '/players/', p, '/stats')
    r <- GET(url, headers)
    c <- content(r)
    market_values0 <- ldply(c$marketValues, data.frame, stringsAsFactors = F)
    if (nrow(market_values0) > days) {
      s <- nrow(market_values0) - days + 1
    } else {
      s <- 1
    }
    market_values0 <- market_values0[s:nrow(market_values0), ]
    market_values0$pid <- p
    if(!exists('market_values')) {
      market_values <- market_values0
    } else {
      market_values <- union_all(market_values, market_values0)
    }
    ### additional data returned from API call, currently not handled:
    # seasons <- ldply(c$seasons, data.frame, stringsAsFactors = F)
    # nextMatches <- ldply(c$nm, data.frame, stringsAsFactors = F)
    # leaguePlayer <- data.frame(c$leaguePlayer, stringsAsFactors = F)
    # mvHigh, mvHighDate, mvLow, mvLowDate
  }
  return(market_values)
}

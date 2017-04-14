source('get_kickbase_data.R')

kickbase_login()
teams <- get_teams()
players <- get_players(teams$tid)
performance <- get_performance(players$id)
market_values <- get_market_values(players$id)

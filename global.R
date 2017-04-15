source('config.R')
source('get_kickbase_data.R')

c <- set_kickbase_connection(kickbase_user_agent)
u <- kickbase_login(kickbase_user, kickbase_password)
teams <- get_teams(c$headers, u$cookie)
players <- get_players(teams$tid, c$headers, u$cookie)
performance <- get_performance(players$id, c$headers, u$cookie)
market_values <- get_market_values(players$id, c$headers, u$cookie)

source('~/git/kickbase/config.R')
source('~/git/kickbase/get_kickbase_data.R')
source('~/git/kickbase/bigquery.R')
source('~/git/kickbase/email_report.R')

# collect data from Kickbase API
c <- set_kickbase_connection(kickbase_user_agent)
u <- kickbase_login(kickbase_user, kickbase_password)
teams <- get_teams(headers =c$headers, 
                   cookie = u$cookie)
players <- get_players(team_ids = teams$tid, 
                       headers = c$headers, 
                       cookie =u$cookie)
performance <- get_performance(player_ids = players$id, 
                               league_id = u$league_id,
                               headers = c$headers, 
                               cookie =u$cookie)
market_values <- get_market_values(player_ids = players$id, 
                                   league_id = u$league_id,
                                   headers = c$headers, 
                                   cookie =u$cookie)

# store data in Google BigQuery
e <- set_bigquery_environment('kickbase')
write_bigquery_table(e$project_id, e$dataset_id, 'teams', teams)
write_bigquery_table(e$project_id, e$dataset_id, 'players', players)
write_bigquery_table(e$project_id, e$dataset_id, 'performance', performance)
write_bigquery_table(e$project_id, e$dataset_id, 'market_values', market_values)

# send report by email
email_report(market_values,
             send_to = send_to_email,
             send_from = send_from_email)

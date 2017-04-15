library(gmailr)

email_report <- function(market_values, send_to, send_from) {
  market_values$dt <- as.Date(market_values$d)
  today <- max(market_values$dt)
  yesterday <- max(market_values$dt) - 1
  mv <- market_values[which(market_values$dt == today), ]
  mv$m0 <- market_values$m[which(market_values$dt == yesterday)]
  mv$delta <- mv$m - mv$m0
  winner_value <- paste0(format(max(mv$delta), big.mark = '.'), '€')
  winner_id <- mv$pid[which.max(mv$delta)]
  winner_name <- paste(players$firstName[players$id == winner_id],
                       players$lastName[players$id == winner_id])
  loser_value <- paste0(format(min(mv$delta), big.mark = '.'), '€')
  loser_id <- mv$pid[which.min(mv$delta)]
  loser_name <- paste(players$firstName[players$id == loser_id],
                      players$lastName[players$id == loser_id])
  
  subject_line <- 'Kickbase Marktwerte: Gewinner und Verlierer'
  body_text <- paste('Gewinner des Tages:', winner_name, winner_value, '///',
                     'Verlierer des Tages:', loser_name, loser_value)
  
  daily_email <- mime(
    To = send_to,
    From = send_from,
    Subject = subject_line,
    body = body_text)
  send_message(daily_email)
}

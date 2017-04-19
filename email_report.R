library(gmailr)
library(knitr)

email_report <- function(market_values, send_to, send_from, tdiff) {
  market_values$dt <- as.Date(market_values$d)
  mv_today <- market_values %>%
    filter(dt == max(dt)) %>%
    select(pid, dt, mv_today = m)
  mv_yesterday <- market_values %>%
    filter(dt == max(dt) - 1) %>%
    select(pid, dt, mv_yesterday = m)
  mv_change <- mv_today %>%
    left_join(mv_yesterday, by = 'pid') %>%
    mutate(mv_diff = mv_today - mv_yesterday) 
  mv_change_players <- mv_change %>%
    left_join(players, by = c('pid' = 'id')) %>%
    mutate(name = paste(firstName, lastName)) %>%
    mutate(name = ifelse(is.na(knownName), name, knownName)) %>%
    select(Spieler = name, 
           MW_Neu = mv_today, 
           MW_Alt = mv_yesterday, 
           MW_Differenz = mv_diff)
  top5 <- mv_change_players %>%
    top_n(5, MW_Differenz) %>%
    arrange(desc(MW_Differenz)) %>%
    kable(format = 'html', format.args = list(big.mark = '.'))
  bottom5 <- mv_change_players %>%
    top_n(-5, MW_Differenz) %>%
    arrange(MW_Differenz) %>%
    kable(format = 'html', format.args = list(big.mark = '.'))
  winner <- mv_change_players$Spieler[which.max(mv_change_players$MW_Differenz)]
  loser <- mv_change_players$Spieler[which.min(mv_change_players$MW_Differenz)]
  
  subject_line <- paste('Marktwert Update:', loser, 'verliert,', winner, 'gewinnt')
  body_part1 <- paste('Hallo Manager, <br><br> die Marktwerte wurden aktualisiert. <br><br>',
                      'Das sind die Gewinner des Tages:')
  body_part2 <- '<br> Und das sind die Verlierer:'
  body_part3 <- paste('<br> Du erhältst diese E-Mail als exklusives Fördermitglied ',
                      'von Kickbase Insider. ',
                      'Wenn du kein Interesse mehr an derartigen Benachrichtigungen hast, ',
                      'dann wende dich bitte an deinen Administrator.')
  email_body <- paste(body_part1, top5, body_part2, bottom5, body_part3)
  
  daily_email <- mime() %>%
    from(send_from) %>%
    to(send_to) %>%
    subject(subject_line) %>%
    html_body(email_body)
  send_message(daily_email)
}

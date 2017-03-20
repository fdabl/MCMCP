# exclude pilot data
d1 <- read.csv('data_mcmcp1.csv')
d2 <- read.csv('data_mcmcp2.csv')

uniq1 <- unique(d1$id)
uniq2 <- unique(d2$id)
cut_out <- which(sapply(uniq2, function(id) id %in% uniq1))

d <- d2 %>% 
  mutate(
    id_int = rep(seq(uniq2), each = 160),
    time_minutes = time / 60000,
    language = tolower(language),
    quantifier = as.character(quantifier),
    quantifier_num = as.numeric(factor(quantifier)),
    clicked_left = ifelse(clicked_left == 'left', 1, 0),
    language = ifelse(language == 'engish', 'english', language),
    chose_higher = as.numeric(number_chosen > number_not_chosen),
    higher = ifelse(number_chosen > number_not_chosen, number_chosen, number_not_chosen),
    lower = ifelse(number_chosen < number_not_chosen, number_chosen, number_not_chosen)
  ) %>% 
  filter(
    trial > 10,
    !(id_int %in% cut_out),
    language == 'english'
  )

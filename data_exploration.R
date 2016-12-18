library('VGAM')
library('dplyr')
library('ggplot2')
library('reshape2')


ggplot(d, aes(x = time_minutes)) +
    geom_histogram(fill = 'red', alpha = 1/2) +
    xlab('Time in Minutes') + 
    # scale_x_continuous(breaks = seq(0, max(d$time_minutes), 2)) +
    scale_x_continuous(breaks = scales::pretty_breaks(n = 10)) +
    ggtitle('Distribution of Reaction Time')


# should we exclude the participant with the long reaction time?
ggplot(filter(d, time_minutes < 20), aes(x = time_minutes)) +
    geom_histogram(fill = 'red', alpha = 1/2) +
    xlab('Time in Minutes') + 
    # scale_x_continuous(breaks = seq(0, max(d$time_minutes), 2)) +
    scale_x_continuous(breaks = scales::pretty_breaks(n = 10)) +
    ggtitle('Distribution of Reaction Time')


# SAMPLES = 'samples_barker.RDS' # a[3] and b[3] seem to have not converged
# SAMPLES = 'samples_closer.RDS' # ab[1], ab[4], ab[5], ab[8] did not converge!
SAMPLES = 'samples_distance.RDS' # all converged!

d = tbl_df(read.csv("all_data.csv", sep = ",")) %>%
    select(number_chosen, quantifier) %>%
    filter(quantifier != 'All', quantifier != 'Hardly Any') %>% 
    mutate(data = 'empirical')

# empirical data
ggplot(d, aes(x = number_chosen)) +
  geom_histogram(bins = 40) + facet_wrap(~ quantifier)

samples = tbl_df(readRDS(SAMPLES))

samples_mean = samples %>% 
  group_by(quantifier) %>% 
  summarize(a = mean(a), b = mean(b))


# create a data frame based on the a and b values from the closer_mean table
N = 1000
res = apply(samples_mean, 1, function(row) {
  a = as.numeric(row[2])
  b = as.numeric(row[3])
  quantifier = row[1]
  
  # should be closed form
  data = rbetabinom.ab(n = N, size = 432, shape1 = a, shape2 = b)
  data.frame(quantifier = rep(quantifier, N), number_chosen = data)
})


plot_data = tbl_df(do.call('rbind', res)) %>% mutate(data = 'predicted') 

dat = rbind(d, plot_data)

ggplot(dat, aes(x = number_chosen, y = ..count.. / sum(..count..), fill = data)) +
  geom_histogram(alpha = 1/2, position = 'identity', binwidth = 30) +
  facet_wrap(~ quantifier) + ylab('Proportions') + ggtitle('Model: Barker')


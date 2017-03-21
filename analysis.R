library('coda')
library('dplyr')
library('jagsUI') # for parallel computing
library('ggmcmc')
library('rjags')
library('rstan')
library('reshape2')
library('VGAM') # dbetabinom.ab

load.module('mix')
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())


run_model <- function(model_name = 'barker', save = TRUE, iter = 20000, burnin = 5000) {
  
  dat <- read.csv('data/all_data_cleaned.csv')
  MODEL <- paste0('models/model.jags_', model_name, '.R')
  
  # based on visual inspection of the traceplots, these participants were removed
  # to_remove = read.csv('exploring/ids.csv') %>% filter(number %in% c(10, 11, 15, 22, 34))
  # dat = filter(dat, !(id %in% to_remove$id))
  
  nr_trials <- as.vector(table(dat$quantifier))
  names(nr_trials) <- levels(factor(dat$quantifier))
  
  lower <- matrix(NA, max(nr_trials), 10)
  higher <- matrix(NA, max(nr_trials), 10)
  y.chose_higher <- matrix(NA, max(nr_trials), 10)
  
  for (i in 1:10) {
    chose_higher <- filter(dat, quantifier_num == i) %>% select(chose_higher) %>% unlist() %>% as.numeric()
    quant_lower <- filter(dat, quantifier_num == i) %>% select(lower) %>% unlist() %>% as.numeric()
    quant_higher <- filter(dat, quantifier_num == i) %>% select(higher) %>% unlist() %>% as.numeric()
    
    lower[1:length(quant_lower), i] <- quant_lower
    higher[1:length(quant_higher), i] <- quant_higher
    y.chose_higher[1:max(length(quant_lower), length(quant_higher)), i] <- chose_higher
  }
  
  jags_dat <- list('nr_quantifiers' = 10, 'N' = 432,
                  'lower' = lower + 1,
                  'higher' = higher + 1,
                  'nr_trials' = nr_trials,
                  'y.chose_higher' = y.chose_higher)
  
  params <- c('a', 'b', 'c')
  
  # use "rjags"
  model <- jags.model(file = MODEL, data = jags_dat, n.chains = 1)
  samples <- coda.samples(model, variable.names = params, n.iter = iter)
  
  out <- jags(
    data = jags_dat,
    inits = NULL,
    parameters.to.save = params,
    model.file = MODEL,
    n.chains = parallel::detectCores(),
    n.adapt = 1000,
    n.iter = iter + burnin,
    n.burnin = burnin,
    n.thin = 10,
    modules = c("mix"),
    DIC = TRUE,
    parallel = TRUE,
    verbose = TRUE
  )
  
  # # 
  # # stop()
  # # 
  if (save) {
    saveRDS(out, paste0('samples/samples_', model_name, '.RDS'))
  }
}

run_model(model_name = 'barker', iter = 5000)
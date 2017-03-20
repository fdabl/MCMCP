library('VGAM')
library('dplyr')
library('shiny')
library('ggplot2')
library('reshape2')
library('RColorBrewer')

d = read.csv('../data/all_data_cleaned.csv')

### PREPARE (MEAN OF) MODEL POSTERIOR PARAMETERS
get_model_params = function(model = 'distance') {
    file_dir = paste0('../samples/samples_', model, '.RDS')
    out = readRDS(file_dir)
    params = out$sims.list
    
    mean_a = apply(params$a, 2, mean)
    mean_b = apply(params$b, 2, mean)
    mean_c = mean(params$c)
    list('a' = mean_a, 'b' = mean_b, 'c' = mean_c, 'dic' = out$DIC)
}


# returns the likelihood, a, b, and the mode
model_specs = function(params, dat, model = 'distance') {
    a = params$a
    b = params$b
    c = params$c
    
    N = 432
    lower = dat$lower
    higher = dat$higher
    y.chose_higher = dat$chose_higher
    i = dat$quantifier_num # quantifier as a numeric value
    
    modeFl = ifelse(a[i] > 1 & b[i] > 1, (a[i] - 1) / (a[i] + b[i] + 2),
                    ifelse(a[i] > 1 & b[i] < 1, 1, 0)) * N
    
    mode = ifelse(modeFl - trunc(modeFl) > .5, round(modeFl), trunc(modeFl))
    
    # likelihood of the distance model
    if (model == 'distance') {
        
        hi = (432 - abs(higher - mode)) / N
        lo = (432 - abs(lower - mode)) / N
        prob = exp(c * hi) / (exp(c * hi) + exp(c * lo))
        
    } else if (model == 'closer') {
        
        hi = ifelse(abs(mode - lower) > abs(mode - higher), 1, 0)
        lo = ifelse(abs(mode - lower) < abs(mode - higher), 1, 0)
        prob1 = exp(c * (1 + lo - hi))
        prob2 = exp(c * (1 + hi - lo))
        prob = prob2 / (prob1 + prob2)
        
    } else if (model == 'barker') {
        
        # fixed argument order
        p_hi = dbetabinom.ab(higher - 1, N, a[i], b[i]) + .00001
        p_lo = dbetabinom.ab(lower - 1, N, a[i], b[i])  + .00001
        prob = p_hi^c / (p_hi^c + p_lo^c)
        
    } else {
        stop('Model unspecified!')
    }
    
    y.pred = dbinom(x = y.chose_higher, size = 1, prob = prob)
    res = list('y.pred' = y.pred, 'a' = a[i], 'b' = b[i], 'mode' = mode)
    lapply(res, round, 3)
}

# everything converged
params_barker = get_model_params(model = 'barker')  
params_closer = get_model_params(model = 'closer')
params_distance = get_model_params(model = 'distance')

# predictions for chose_higher
barker_specs = model_specs(params_barker, d, model = 'barker')
distance_specs = model_specs(params_distance, d, model = 'distance')
closer_specs = model_specs(params_closer, d, model = 'closer')

pred_barker = barker_specs$y.pred
pred_distance = distance_specs$y.pred
pred_closer = closer_specs$y.pred

## Add the predictions
d = d %>% 
    mutate(pred_barker = pred_barker,
           pred_barker_chosen = ifelse(chose_higher, pred_barker, 1 - pred_barker),
           pred_barker_not_chosen = ifelse(chose_higher, 1 - pred_barker, pred_barker),
           
           pred_distance = pred_distance,
           pred_distance_chosen = ifelse(chose_higher, pred_distance, 1 - pred_distance),
           pred_distance_not_chosen = ifelse(chose_higher, 1 - pred_distance, pred_distance),
           
           pred_closer = pred_closer,
           pred_closer_chosen = ifelse(chose_higher, pred_closer, 1 - pred_closer),
           pred_closer_not_chosen = ifelse(chose_higher, 1 - pred_closer, pred_closer),
           
           mode_barker = barker_specs[['mode']],
           mode_distance = distance_specs[['mode']],
           mode_closer = closer_specs[['mode']],
           
           a_barker = barker_specs[['a']],
           a_distance = distance_specs[['a']],
           a_closer = closer_specs[['a']],
           
           b_barker = barker_specs[['b']],
           b_distance = distance_specs[['b']],
           b_closer = closer_specs[['b']]
    )

# likelihood
d %>% select(pred_barker, pred_distance, pred_closer) %>% apply(., 2, sum)
## => Barker is the worst, followed by the closer model; the distance model faires best

# DIC
cbind(params_barker$dic, params_distance$dic, params_closer$dic)
## => Barker is the worst, followed by the closer model; the distance model faires best

d %>% select(trial, chose_higher, number_chosen, number_not_chosen, starts_with('pred')) %>% head

# make the summary table
melt_data = function(d, args, what = 'id') {
    
    if (what == 'id') {
        d = filter(d, id %in% args)
    } else {
        d = filter(d, quantifier %in% args)
    }
    
    d %>%
        select(id, id_int, trial, number_chosen, number_not_chosen, chose_higher,
               quantifier, starts_with('pred'), starts_with('mode')) %>% 
    
        melt(data = ., id.vars = c('id', 'id_int', 'trial', 'quantifier', 'chose_higher',
                                   'pred_barker', 'pred_closer', 'pred_distance',
                                   'mode_barker', 'mode_closer', 'mode_distance'),
             measure.vars = c('number_chosen', 'number_not_chosen'),
             variable.name = 'choice') %>% 
        
        # add the predictions
        mutate(pred_barker = ifelse(choice == 'number_chosen',
                                    ifelse(chose_higher, pred_barker, 1 - pred_barker),
                                    ifelse(chose_higher, 1 - pred_barker, pred_barker)),
               
               pred_closer = ifelse(choice == 'number_chosen',
                                    ifelse(chose_higher, pred_closer, 1 - pred_closer),
                                    ifelse(chose_higher, 1 - pred_closer, pred_closer)),
               
               pred_distance = ifelse(choice == 'number_chosen',
                                    ifelse(chose_higher, pred_distance, 1 - pred_distance),
                                    ifelse(chose_higher, 1 - pred_distance, pred_distance))
        )
}

# check if everything is correct
melt_data(d, d$id[1], what = 'id') %>% 
    select(choice, value, chose_higher, pred_barker) -> x

dsel = d %>%
    filter(id == d$id[1]) %>% 
    select(number_chosen, pred_barker_chosen, number_not_chosen, pred_barker_not_chosen, chose_higher)

(filter(x, choice == 'number_chosen') %>% select(pred_barker) ==
 top_n(dsel, 160) %>% select(pred_barker_chosen)) %>% all
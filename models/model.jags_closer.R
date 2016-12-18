model {
  
  # population-level distribution; parameterize as a beta-binomial
  for (i in 1:nr_quantifiers) {

    a[i] ~ dunif(0, 100)
    b[i] ~ dunif(0, 100)

    modeFl[i] <- ifelse(a[i] > 1 && b[i] > 1, (a[i] - 1) / (a[i] + b[i] + 2),
                        ifelse(a[i] > 1 && b[i] < 1, 1, 0)) * N
    
    mode[i] <- ifelse(modeFl[i] - trunc(modeFl[i]) > .5, round(modeFl[i]), trunc(modeFl[i]))
    
    # likelihood of selecting the higher number for quantifier i in trial k
    for (k in 1:nr_trials[i]) {
      hi[i, k] <- ifelse(abs(mode[i] - lower[k, i]) > abs(mode[i] - higher[k, i]), 1, 0)
      lo[i, k] <- ifelse(abs(mode[i] - lower[k, i]) < abs(mode[i] - higher[k, i]), 1, 0)
      probT[i, k, 1] <- exp(c * (1 + lo[i, k] - hi[i, k]))
      probT[i, k, 2] <- exp(c * (1 + hi[i, k] - lo[i, k]))
      prob[i, k] <- probT[i, k, 2] / sum(probT[i, k, 1:2])
      y.chose_higher[k, i] ~ dbern(prob[i, k])
    }
  }
  c ~ dgamma(2, 1)
}
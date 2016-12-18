model {
  
  for (i in 1:nr_quantifiers) {
    a[i] ~ dunif(0, 100)
    b[i] ~ dunif(0, 100)
    
    modeFl[i] <- ifelse(a[i] > 1 && b[i] > 1, (a[i] - 1) / (a[i] + b[i] + 2),
                        ifelse(a[i] > 1 && b[i] < 1, 1, 0)) * N
    
    mode[i] <- ifelse(modeFl[i] - trunc(modeFl[i]) > .5, round(modeFl[i]), trunc(modeFl[i]))
    
    for (k in 1:nr_trials[i]) {
      hi[i, k] <- (432 - abs(higher[k, i] - mode[i])) / 432
      lo[i, k] <- (432 - abs(lower[k, i] - mode[i])) / 432
      probT[i, k, 1] <- exp(c * hi[i, k])
      probT[i, k, 2] <- exp(c * lo[i, k])
      prob[i, k] <- probT[i, k, 1] / sum(probT[i, k, 1:2])
      y.chose_higher[k, i] ~ dbern(prob[i, k])
    }
    
  }
  c ~ dgamma(2, 1)
}
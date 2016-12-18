model {
  
  for (i in 1:nr_quantifiers) {
    a[i] ~ dunif(0, 100)
    b[i] ~ dunif(0, 100)
    
    for (k in 1:nr_trials[i]) {
      # Laplace smoothing
      p_hi[i, k] <- dbetabin(higher[k, i] - 1, a[i], b[i], N) + .00001
      p_lo[i, k] <- dbetabin(lower[k, i] - 1, a[i], b[i], N)  + .00001
      prob[i, k] <- p_hi[i, k]^c / (p_hi[i, k]^c + p_lo[i, k]^c)
      y.chose_higher[k, i] ~ dbern(prob[i, k])
    }
  }
    
  c <- 1
}
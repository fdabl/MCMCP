# Humans as Bayesian samplers?

Are humans Bayesian samplers in the domain of quantifier interpretation? We utilize a Markov chain Monte Carlo with People (MCMCP) experiment in which participants' responses are viewed as states in a Markov chain with the posterior distribution over values under specific quantifiers as stationary distribution.

Previous research used the Barker acceptance function (power-law) in a Metropolis-Hastings algorithm to model participants' response patterns. We compared three Bayesian models of the data generating process and found that the Barker model does not capture the necessary regularities in the data and is inferior to models assuming that participants utilize the mode of the posterior distribution in their decision making.

However, it can be argued that both the Distance and the Barker model implement the Barker decision rule, operating on the same underlying mental representation; the Closer model, in contrast, requires a two-dimensional underlying representation because the choices are compared with respect to each other, not with respect towards a function of the posterior distribution (i.e., the mode or the likelihood).

Therefore, several steps need to be taken.

## Further research
To get things going, we need

  * [ ] More participants
  * [ ] Fix the convergence issues in the Barker model
  * [ ] Use informative beta priors for the quantifiers
  * [ ] Use a softmax and power-law for all three models
  * [ ] Fit the six resulting models in Stan and compare them using the WAIC
  
## This repository
This repository contains the analysis code, the code for the experiment, the raw data, a shiny app to interactively explore the data (see also [here](https://fdabl.shinyapps.io/MCMCP/)) as well as the manuscript.
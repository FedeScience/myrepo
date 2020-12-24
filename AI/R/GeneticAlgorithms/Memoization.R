#@ https://cran.r-project.org/web/packages/GA/vignettes/GA.html
library(GA)
#Memoization
#In certain circumstances, particularly with binary GAs, memoization can be used to speed up calculations by using cached results. This is easily obtained using the memoise package.
data(fat, package = "UsingR")
mod <- lm(body.fat.siri ~ age + weight + height + neck + chest + abdomen +
            hip + thigh + knee + ankle + bicep + forearm + wrist, data = fat)
summary(mod)
x <- model.matrix(mod)[,-1]
y <- model.response(mod$model)

fitness <- function(string)
{ 
  mod <- lm(y ~ x[,string==1])
  -BIC(mod)
}

library(memoise)
mfitness <- memoise(fitness)
is.memoised(fitness)
## [1] FALSE
is.memoised(mfitness)
## [1] TRUE

library(rbenchmark)
tab <- benchmark(
  GA1 = ga("binary", fitness = fitness, nBits = ncol(x), 
           popSize = 100, maxiter = 100, seed = 1, monitor = FALSE),
  GA2 = ga("binary", fitness = mfitness, nBits = ncol(x), 
           popSize = 100, maxiter = 100, seed = 1, monitor = FALSE),
  columns = c("test", "replications", "elapsed", "relative"), 
  replications = 10)
tab$average <- with(tab, elapsed/replications)
tab

forget(mfitness)
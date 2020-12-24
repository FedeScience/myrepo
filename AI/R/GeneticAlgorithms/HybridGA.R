#@ https://cran.r-project.org/web/packages/GA/vignettes/GA.html
library(GA)
#Function optimisation in two dimensions
Rastrigin <- function(x1, x2)
{
  20 + x1^2 + x2^2 - 10*(cos(2*pi*x1) + cos(2*pi*x2))
}
#Hybrid GAs
optimArgs = list(method = "L-BFGS-B", 
                 poptim = 0.05,
                 pressel = 0.5,
                 control = list(fnscale = -1, maxit = 100))
GA <- ga(type = "real-valued", 
         fitness =  function(x) -Rastrigin(x[1], x[2]),
         lower = c(-5.12, -5.12), upper = c(5.12, 5.12), 
         popSize = 50, maxiter = 1000, run = 100,
         optim = TRUE)
summary(GA)
plot(GA)
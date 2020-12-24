#@ https://cran.r-project.org/web/packages/GA/vignettes/GA.html
library(GA)
#Function optimisation in two dimensions
Rastrigin <- function(x1, x2)
{
  20 + x1^2 + x2^2 - 10*(cos(2*pi*x1) + cos(2*pi*x2))
}
#Setting some members of the initial population
suggestedSol <- matrix(c(0.2,1.5,-1.5,0.5), nrow = 2, ncol = 2, byrow = TRUE)
GA1 <- ga(type = "real-valued", 
          fitness =  function(x) -Rastrigin(x[1], x[2]),
          lower = c(-5.12, -5.12), upper = c(5.12, 5.12), 
          suggestions = suggestedSol,
          popSize = 50, maxiter = 1)
head(GA1@population)

GA <- ga(type = "real-valued", 
         fitness =  function(x) -Rastrigin(x[1], x[2]),
         lower = c(-5.12, -5.12), upper = c(5.12, 5.12), 
         suggestions = suggestedSol,
         popSize = 50, maxiter = 100)
summary(GA)
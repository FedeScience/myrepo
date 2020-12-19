#@ https://cran.r-project.org/web/packages/GA/vignettes/GA.html
library(GA)
# Function optimisation in one dimension
f <- function(x)  (x^2+x)*cos(x)

#Function optimisation in two dimensions
Rastrigin <- function(x1, x2)
{
  20 + x1^2 + x2^2 - 10*(cos(2*pi*x1) + cos(2*pi*x2))
}
#Island evolution
GA <- gaisl(type = "real-valued", 
            fitness =  function(x) -Rastrigin(x[1], x[2]),
            lower = c(-5.12, -5.12), upper = c(5.12, 5.12), 
            popSize = 100, 
            maxiter = 1000, run = 100,
            numIslands = 4, 
            migrationRate = 0.2,
            migrationInterval = 50)

summary(GA)
plot(GA, log = "x")

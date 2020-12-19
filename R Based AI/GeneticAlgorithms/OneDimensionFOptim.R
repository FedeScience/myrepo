#@ https://cran.r-project.org/web/packages/GA/vignettes/GA.html
library(GA)
# Function optimisation in one dimension
f <- function(x)  (x^2+x)*cos(x)
lbound <- -10; ubound <- 10
#The GA search process can be visualised by defining a monitoring function as follows:
monitor <- function(obj) 
{ 
  curve(f, from = lbound, to = ubound, n = 1000, drawlabels = FALSE, col = grey(0.5))
  title(paste("iteration =", obj@iter), font.main = 1)
  points(obj@population, pch = 20, col = 2)
  Sys.sleep(0.2)
}
GA <- ga(type = "real-valued", fitness = f, lower = c(th = lbound), upper = ubound,monitor = monitor)

summary(GA)
plot(GA)

curve(f, from = lbound, to = ubound, n = 1000)
points(GA@solution, GA@fitnessValue, col = 2, pch = 19)

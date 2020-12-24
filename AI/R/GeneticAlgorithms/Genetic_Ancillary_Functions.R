#@ https://cran.r-project.org/web/packages/GA/vignettes/GA.html
# Function optimisation in one dimension
f <- function(x)  (x^2+x)*cos(x)

#Function optimisation in two dimensions
Rastrigin <- function(x1, x2)
{
  20 + x1^2 + x2^2 - 10*(cos(2*pi*x1) + cos(2*pi*x2))
}

#Constrained optimisation
f <- function(x)
{ 100 * (x[1]^2 - x[2])^2 + (1 - x[1])^2 }

c1 <- function(x) 
{ x[1]*x[2] + x[1] - x[2] + 1.5 }

c2 <- function(x) 
{ 10 - x[1]*x[2] }

#A GA solution can be obtained by defining a penalised fitness function:
Fitness <- function(x) 
{ 
  f <- -f(x)                         # we need to maximise -f(x)
  pen <- sqrt(.Machine$double.xmax)  # penalty term
  penalty1 <- max(c1(x),0)*pen       # penalisation for 1st inequality constraint
  penalty2 <- max(c2(x),0)*pen       # penalisation for 2nd inequality constraint
  f - penalty1 - penalty2            # fitness function value
}

#Binary search solution
Binary <- function(x)
{ 
  x <- gray2binary(x)
  n <- binary2decimal(x[1:l1])
  c <- min(n, binary2decimal(x[(l1+1):(l1+l2)]))
  out <- structure(c(n,c), names = c("n", "c"))
  return(out)
}

Fitness_Binary <- function(x) 
{ 
  par <- Binary(x)
  n <- par[1]  # sample size
  c <- par[2]  # acceptance number
  Pa1 <- pbinom(c, n, AQL)
  Pa2 <- pbinom(c, n, LTPD)
  Loss <- (Pa1-(1-alpha))^2 + (Pa2-beta)^2
  -Loss
}

#Real-valued search solution
RealValued <- function(x)
{ 
  n <- floor(x[1])         # sample size
  c <- min(n, floor(x[2])) # acceptance number
  out <- structure(c(n,c), names = c("n", "c"))
  return(out)
}

Fitness_RealValued <- function(x) 
{ 
  x <- Real-valued(x)
  n <- x[1]  # sample size
  c <- x[2]  # acceptance number
  Pa1 <- pbinom(c, n, AQL)
  Pa2 <- pbinom(c, n, LTPD)
  Loss <- (Pa1-(1-alpha))^2 + (Pa2-beta)^2
  return(-Loss)
}

#The GA search process can be visualised by defining a monitoring function as follows:
Monitor <- function(obj) 
{ 
  contour(x1, x2, f, drawlabels = FALSE, col = grey(0.5))
  title(paste("iteration =", obj@iter), font.main = 1)
  points(obj@population, pch = 20, col = 2)
  Sys.sleep(0.2)
}
#@ https://cran.r-project.org/web/packages/GA/vignettes/GA.html
library(GA)
#Integer optimisation
AQL   <- 0.01; alpha <- 0.05
LTPD  <- 0.06; beta  <- 0.10
plot(0, 0, type="n", xlim=c(0,0.2), ylim=c(0,1), bty="l", xaxs="i", yaxs="i", 
     ylab="Prob. of acceptance", xlab=expression(p))
lines(c(0,AQL), rep(1-alpha,2), lty=2, col="grey")
lines(rep(AQL,2), c(1-alpha,0), lty=2, col="grey")
lines(c(0,LTPD), rep(beta,2), lty=2, col="grey")
lines(rep(LTPD,2), c(beta,0), lty=2, col="grey")
points(c(AQL, LTPD), c(1-alpha, beta), pch=16)
text(AQL, 1-alpha, labels=expression(paste("(", AQL, ", ", 1-alpha, ")")), pos=4)
text(LTPD, beta, labels=expression(paste("(", LTPD, ", ", beta, ")")), pos=4)

#Real-valued search solution
decode2 <- function(x)
{ 
  n <- floor(x[1])         # sample size
  c <- min(n, floor(x[2])) # acceptance number
  out <- structure(c(n,c), names = c("n", "c"))
  return(out)
}

fitness2 <- function(x) 
{ 
  x <- decode2(x)
  n <- x[1]  # sample size
  c <- x[2]  # acceptance number
  Pa1 <- pbinom(c, n, AQL)
  Pa2 <- pbinom(c, n, LTPD)
  Loss <- (Pa1-(1-alpha))^2 + (Pa2-beta)^2
  return(-Loss)
}

GA2 <- ga(type = "real-valued", fitness = fitness2, 
          lower = c(2,0), upper = c(200,20)+1,
          popSize = 100, maxiter = 1000, run = 100)
summary(GA2)
t(apply(GA2@solution, 1, decode2))

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

#Binary search solution
decode1 <- function(x)
{ 
  x <- gray2binary(x)
  n <- binary2decimal(x[1:l1])
  c <- min(n, binary2decimal(x[(l1+1):(l1+l2)]))
  out <- structure(c(n,c), names = c("n", "c"))
  return(out)
}

fitness1 <- function(x) 
{ 
  par <- decode1(x)
  n <- par[1]  # sample size
  c <- par[2]  # acceptance number
  Pa1 <- pbinom(c, n, AQL)
  Pa2 <- pbinom(c, n, LTPD)
  Loss <- (Pa1-(1-alpha))^2 + (Pa2-beta)^2
  -Loss
}

n  <- 2:200                  # range of values to search
b1 <- decimal2binary(max(n)) # max number of bits requires
l1 <- length(b1)             # length of bits needed for encoding
c  <- 0:20                   # range of values to search
b2 <- decimal2binary(max(c)) # max number of bits requires
l2 <- length(b2)             # length of bits needed for encoding

GA1 <- ga(type = "binary", fitness = fitness1, 
          nBits = l1+l2, 
          popSize = 100, maxiter = 1000, run = 100)
summary(GA1)
decode1(GA1@solution)

plot(0,0,type="n", xlim=c(0,0.2), ylim=c(0,1), bty="l", xaxs="i", yaxs="i", 
     ylab=expression(P[a]), xlab=expression(p))
lines(c(0,AQL), rep(1-alpha,2), lty=2, col="grey")
lines(rep(AQL,2), c(1-alpha,0), lty=2, col="grey")
lines(c(0,LTPD), rep(beta,2), lty=2, col="grey")
lines(rep(LTPD,2), c(beta,0), lty=2, col="grey")
points(c(AQL, LTPD), c(1-alpha, beta), pch=16)
text(AQL, 1-alpha, labels=expression(paste("(", AQL, ", ", 1-alpha, ")")), pos=4)
text(LTPD, beta, labels=expression(paste("(", LTPD, ", ", beta, ")")), pos=4)
n <- 87; c <- 2
p <- seq(0, 0.2, by = 0.001)
Pa <- pbinom(2, 87, p)
lines(p, Pa, col = 2)

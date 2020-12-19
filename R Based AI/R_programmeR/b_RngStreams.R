#/usr/bin/R
#RNG_stream
# Sun Apr 26 22:11:38 2020 ------------------------------
library(parallel)
#Implementation of Pierre L'Ecuyer's RngStreams
RNGkind("L'Ecuyer-CMRG")
set.seed(123)
(s <- .Random.seed)
## do some work involving random numbers.
nextRNGStream(s)
nextRNGSubStream(s)


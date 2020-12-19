#!/usr/bin/R
#sudo apt install libxml2-dev libssl-dev libcurl4-openssl-dev libgit2-dev libv8-dev

install.packages("devtools")
devtools::install_github("sgreben/caretStack")
as.data.frame(installed.packages(lib.loc = "/home/fede/R/x86_64-pc-linux-gnu-library/4.0"))[,1]

#remove.packages(as.data.frame(installed.packages(lib.loc = "/home/fede/R/x86_64-pc-linux-gnu-library/4.0"))[,1],lib = "/home/fede/R/x86_64-pc-linux-gnu-library/4.0")

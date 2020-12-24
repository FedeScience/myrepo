#@ https://www.datanovia.com/en/blog/types-of-clustering-methods-overview-and-quick-start-r-code/
# Compute PAM
library(cluster)
library(factoextra)
library(magrittr)
# Load  and prepare the data
data("USArrests")
pam.res <- pam(my_data, 3)
# Visualize
fviz_cluster(pam.res)
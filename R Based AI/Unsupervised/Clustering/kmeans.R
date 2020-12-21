#@ https://www.datanovia.com/en/blog/types-of-clustering-methods-overview-and-quick-start-r-code/
library(cluster)
library(factoextra)
library(magrittr)
# Load  and prepare the data
data("USArrests")

my_data <- USArrests %>%
  na.omit() %>%          # Remove missing values (NA)
  scale()                # Scale variables

res.dist <- get_dist(USArrests, stand = TRUE, method = "pearson")

#Partitioning clustering
fviz_nbclust(my_data, kmeans, method = "gap_stat")
set.seed(123)
km.res <- kmeans(my_data, 3, nstart = 25)
# Visualize
fviz_cluster(km.res, data = my_data,
             ellipse.type = "convex",
             palette = "jco",
             ggtheme = theme_minimal())

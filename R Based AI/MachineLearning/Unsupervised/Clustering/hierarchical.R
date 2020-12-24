#@ https://www.datanovia.com/en/blog/types-of-clustering-methods-overview-and-quick-start-r-code/
#Hierarchical clustering
library(cluster)
library(factoextra)
library(magrittr)
# Load  and prepare the data
data("USArrests")
# Compute hierarchical clustering
res.hc <- USArrests %>%
  scale() %>%                    # Scale the data
  dist(method = "euclidean") %>% # Compute dissimilarity matrix
  hclust(method = "ward.D2")     # Compute hierachical clustering

# Cut in 4 groups and color by groups
fviz_dend(res.hc, k = 4, # Cut in four groups
          cex = 0.5, # label size
          k_colors = c("#2E9FDF", "#00AFBB", "#E7B800", "#FC4E07"),
          color_labels_by_k = TRUE, # color labels by groups
          rect = TRUE # Add rectangle around groups
)

#Determining the optimal number of clusters
set.seed(123)

# Compute
library("NbClust")
res.nbclust <- USArrests %>%
  scale() %>%
  NbClust(distance = "euclidean",
          min.nc = 2, max.nc = 10, 
          method = "complete", index ="all") 

# Visualize
fviz_nbclust(res.nbclust, ggtheme = theme_minimal())
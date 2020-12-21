#@ https://www.datanovia.com/en/blog/types-of-clustering-methods-overview-and-quick-start-r-code/
library(magrittr)
library(cluster)
library(factoextra)
#Clustering validation statistics
set.seed(123)
# Enhanced hierarchical clustering, cut in 3 groups
res.hc <- iris[, -5] %>%
  scale() %>%
  eclust("hclust", k = 3, graph = FALSE)

# Visualize with factoextra
fviz_dend(res.hc, palette = "jco",
          rect = TRUE, show_labels = FALSE)

fviz_silhouette(res.hc)

# Silhouette width of observations
sil <- res.hc$silinfo$widths[, 1:3]

# Objects with negative silhouette
neg_sil_index <- which(sil[, 'sil_width'] < 0)
sil[neg_sil_index, , drop = FALSE]
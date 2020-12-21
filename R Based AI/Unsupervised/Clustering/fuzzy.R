#@ https://www.datanovia.com/en/lessons/fuzzy-clustering-essentials/
library(cluster)
library(factoextra)
df <- scale(USArrests)     # Standardize the data
res.fanny <- fanny(df, 2)  # Compute fuzzy clustering with k = 2

head(res.fanny$membership, 3) # Membership coefficients

res.fanny$coeff # Dunn's partition coefficient

head(res.fanny$clustering) # Observation groups

fviz_cluster(res.fanny, ellipse.type = "norm", repel = TRUE,
             palette = "jco", ggtheme = theme_minimal(),
             legend = "right")

fviz_silhouette(res.fanny, palette = "jco",
                ggtheme = theme_minimal())

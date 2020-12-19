#@ https://www.datanovia.com/en/blog/types-of-clustering-methods-overview-and-quick-start-r-code/
library("cluster")
library("factoextra")
library("magrittr")

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
library("factoextra")
fviz_cluster(km.res, data = my_data,
             ellipse.type = "convex",
             palette = "jco",
             ggtheme = theme_minimal())

# Compute PAM
library("cluster")
pam.res <- pam(my_data, 3)
# Visualize
fviz_cluster(pam.res)

#Hierarchical clustering
# Compute hierarchical clustering
res.hc <- USArrests %>%
  scale() %>%                    # Scale the data
  dist(method = "euclidean") %>% # Compute dissimilarity matrix
  hclust(method = "ward.D2")     # Compute hierachical clustering

# Visualize using factoextra
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
library(factoextra)
fviz_nbclust(res.nbclust, ggtheme = theme_minimal())

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

#@ https://www.datanovia.com/en/lessons/fuzzy-clustering-essentials/
library(cluster)
df <- scale(USArrests)     # Standardize the data
res.fanny <- fanny(df, 2)  # Compute fuzzy clustering with k = 2

head(res.fanny$membership, 3) # Membership coefficients

res.fanny$coeff # Dunn's partition coefficient

head(res.fanny$clustering) # Observation groups

library(factoextra)
fviz_cluster(res.fanny, ellipse.type = "norm", repel = TRUE,
             palette = "jco", ggtheme = theme_minimal(),
             legend = "right")

fviz_silhouette(res.fanny, palette = "jco",
                ggtheme = theme_minimal())

#@ https://www.datanovia.com/en/lessons/model-based-clustering-essentials/
# Load the data
library("MASS")
data("geyser")

# Scatter plot
library("ggpubr")
ggscatter(geyser, x = "duration", y = "waiting")+
  geom_density2d() # Add 2D density

library("mclust")
data("diabetes")
head(diabetes, 3)

library(mclust)
df <- scale(diabetes[, -1]) # Standardize the data
mc <- Mclust(df)            # Model-based-clustering

summary(mc)                 # Print a summary

#Visualizing model-based clustering
library(factoextra)
# BIC values used for choosing the number of clusters
fviz_mclust(mc, "BIC", palette = "jco")
# Classification: plot showing the clustering
fviz_mclust(mc, "classification", geom = "point", 
            pointsize = 1.5, palette = "jco")
# Classification uncertainty
fviz_mclust(mc, "uncertainty", palette = "jco")

#@https://www.datanovia.com/en/lessons/dbscan-density-based-clustering-essentials/
library(factoextra)
data("multishapes")
df <- multishapes[, 1:2]
set.seed(123)
km.res <- kmeans(df, 5, nstart = 25)
fviz_cluster(km.res, df,  geom = "point", 
             ellipse= FALSE, show.clust.cent = FALSE,
             palette = "jco", ggtheme = theme_classic())

install.packages("fpc")
install.packages("dbscan")
install.packages("factoextra")

# Load the data 
data("multishapes", package = "factoextra")
df <- multishapes[, 1:2]

# Compute DBSCAN using fpc package
library("fpc")
set.seed(123)
db <- fpc::dbscan(df, eps = 0.15, MinPts = 5)

# Plot DBSCAN results
library("factoextra")
fviz_cluster(db, data = df, stand = FALSE,
             ellipse = FALSE, show.clust.cent = FALSE,
             geom = "point",palette = "jco", ggtheme = theme_classic())

print(db)
# Cluster membership. Noise/outlier observations are coded as 0
# A random subset is shown
db$cluster[sample(1:1089, 20)]

dbscan::kNNdistplot(df, k =  5)
abline(h = 0.15, lty = 2)



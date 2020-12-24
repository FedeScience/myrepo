#@ https://www.datanovia.com/en/lessons/model-based-clustering-essentials/
library("MASS")
library("ggpubr")
library(mclust)
library(factoextra)
# Load the data
data("diabetes")
head(diabetes, 3)

df <- scale(diabetes[, -1]) # Standardize the data
mc <- Mclust(df)            # Model-based-clustering

summary(mc)                 # Print a summary

#Visualizing model-based clustering
# BIC values used for choosing the number of clusters
fviz_mclust(mc, "BIC", palette = "jco")
# Classification: plot showing the clustering
fviz_mclust(mc, "classification", geom = "point", 
            pointsize = 1.5, palette = "jco")
# Classification uncertainty
fviz_mclust(mc, "uncertainty", palette = "jco")

#@ https://topepo.github.io/caret/models-clustered-by-tag-similarity.html
library(caret)
tag <- read.csv("R Based AI/Supervised/tag_data.csv", row.names = 1)
tag <- as.matrix(tag)

## Select only models for regression
clasModels <- tag[tag[,"Classification"] == 1,]
all <- 1:nrow(clasModels)

## Seed the analysis with the SVM model
startclasModels <- grep("(svmRadial)", rownames(clasModels), fixed = TRUE)
pool <- all[all != startclasModels]

## Select 4 model models by maximizing the Jaccard
## dissimilarity between sets of models
nextModsClas <- maxDissim(clasModels[startclasModels,,drop = FALSE], 
                      clasModels[pool, ], 
                      method = "Jaccard",
                      n = 4)

rownames(clasModels)[c(startclasModels, nextModsClas)]

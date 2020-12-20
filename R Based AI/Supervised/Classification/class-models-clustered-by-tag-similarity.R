#@ https://topepo.github.io/caret/models-clustered-by-tag-similarity.html
library(caret)
tag <- read.csv("R Based AI/Supervised/tag_data.csv", row.names = 1)
tag <- as.matrix(tag)

## Select only models for regression
classModels <- tag[tag[,"Classification"] == 1,]
all <- 1:nrow(regModels)

## Seed the analysis with the SVM model
start <- grep("(svmRadial)", rownames(classModels), fixed = TRUE)
pool <- all[all != start]

## Select 4 model models by maximizing the Jaccard
## dissimilarity between sets of models
nextMods <- maxDissim(classModels[start,,drop = FALSE], 
                      classModels[pool, ], 
                      method = "Jaccard",
                      n = 4)

rownames(classModels)[c(start, nextMods)]

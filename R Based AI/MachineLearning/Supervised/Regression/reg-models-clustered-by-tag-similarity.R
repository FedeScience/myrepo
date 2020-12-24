#@ https://topepo.github.io/caret/models-clustered-by-tag-similarity.html
library(caret)
tag <- read.csv("R Based AI/Supervised/tag_data.csv", row.names = 1)
tag <- as.matrix(tag)

## Select only models for regression
regModels <- tag[tag[,"Regression"] == 1,]
all <- 1:nrow(regModels)

## Seed the analysis with the SVM model
startregModels <- grep("(svmRadial)", rownames(regModels), fixed = TRUE)
pool <- all[all != startregModels]

## Select 4 model models by maximizing the Jaccard
## dissimilarity between sets of models
nextModsReg <- maxDissim(regModels[startregModels,,drop = FALSE], 
                      regModels[pool, ], 
                      method = "Jaccard",
                      n = 4)

rownames(regModels)[c(startregModels, nextModsReg)]

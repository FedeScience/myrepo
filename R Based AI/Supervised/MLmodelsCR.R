require(caret)

cla <- unique(modelLookup()[modelLookup()$forClass,c(1)])
reg <- unique(modelLookup()[modelLookup()$forReg,c(1)])
m <- intersect(cla,reg)

# slow classification models ("rbf" crashes; "dwdLinear", "ownn", "snn" have issues)
# all others may have just failed and are not listed here
ToFixModels <- c("AdaBoost.M1","pda2","dwdRadial","rbf","dwdLinear", "dwdPoly",
                 "gaussprLinear","gaussprPoly","rFerns","sddaLDA", "smda", "sddaQDA",
                 "xgbLinear", "mlpKerasDropout", "bartMachine", "blackboost", "bag",
                 "elm", "extraTrees", "gamboost", "glmboost", "glm", "gbm_h2o" ,
                 "logreg", "mlpKerasDecay", "plsRglm", "nodeHarvest", "glmnet_h2o",
                 "glmStepAIC", "msaenet", "logicBag", "mlpSGD", "mxnet", "mxnetAdam",
                 "null", "randomGLM", "xgbDART", "bam")

#remove all slow and failed models from model list
m <- m[!m %in% ToFixModels]

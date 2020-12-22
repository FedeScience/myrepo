library(mlbench)
library(caret)
library(caretEnsemble)
require(DT)
# register parallel front-end
library(doParallel); cl <- makeCluster(detectCores()); registerDoParallel(cl)

data(Ionosphere)
dataset = Ionosphere
# Convert first column to numeric from factor
dataset$V1 = as.numeric(dataset$V1)

# Drop the 2nd column as it's all 0's
dataset[,2] = NULL

# Set the control parameters
control = trainControl(method='repeatedcv',
                       number=10, repeats=3,
                       savePredictions = TRUE,
                       classProbs = TRUE,
                       verbose=TRUE)

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

# pre-load all packages (does not really work due to other dependencies)
suppressPackageStartupMessages(ll <-lapply(m, require, character.only = TRUE))

# Set the control parameters
control = trainControl(method = 'repeatedcv',
                       number = 10,
                       repeats = 5,
                       verbose=TRUE)

# Create the mmodels
trainCall <- function(i) 
{
  cat("----------------------------------------------------","\n");
  set.seed(123); cat(i," <- loaded\n");
  return(tryCatch(
    t2 <- caretList(Class ~ ., data=dataset, trControl = control, methodList = m),
    error=function(e) NULL))
}

# use lapply/loop to run everything, required for try/catch error function to work
t2 <- lapply(m, trainCall)

#remove NULL values, we only allow succesful methods, provenance is deleted.
t2 <- t2[!sapply(t2, is.null)]

# Stack the models using Random Forest
stackControl = trainControl(method='repeatedcv', 
                            number=10, repeats=3,
                            savePredictions = TRUE,
                            classProbs = TRUE,
                            verbose=TRUE)

trainCall <- function(i) 
{
  cat("----------------------------------------------------","\n");
  set.seed(123); cat(i," <- loaded\n");
  return(tryCatch(
    tstack <- caretStack(t2, method='rf', metric='Accuracy', trControl = stackControl),
    error=function(e) NULL))
}
# use lapply/loop to run everything, required for try/catch error function to work
tstack <- lapply(m, trainCall)

#remove NULL values, we only allow succesful methods, provenance is deleted.
tstack <- tstack[!sapply(tstack, is.null)]

# this setup extracts the results with minimal error handling 
# TrainKappa can be sometimes zero, but Accuracy SD can be still available
# see Kappa value http://epiville.ccnmtl.columbia.edu/popup/how_to_calculate_kappa.html
printCall <- function(i) 
{
  return(tryCatch(
    {
      cat(sprintf("%-22s",(m[i])))
      cat(round(getTrainPerf(tstack[[i]])$TrainAccuracy,4),"\t")
      cat(round(getTrainPerf(tstack[[i]])$TrainKappa,4),"\t")
      cat(tstack[[i]]$times$everything[3],"\n")},
    error=function(e) NULL))
}

r2 <- lapply(1:length(tstack), printCall)

# stop cluster and register sequntial front end
stopCluster(cl); registerDoSEQ();

# preallocate data types
i = 1; MAX = length(tstack);
x1 <- character() # Name
x2 <- numeric()   # R2
x3 <- numeric()   # RMSE
x4 <- numeric()   # time [s]
x5 <- character() # long model name

# fill data and check indexes and NA with loop/lapply 
for (i in 1:length(tstack)) {
  x1[i] <- tstack[[i]]$method
  x2[i] <- as.numeric(round(getTrainPerf(tstack[[i]])$TrainAccuracy,4))
  x3[i] <- as.numeric(round(getTrainPerf(tstack[[i]])$TrainKappa,4))
  x4[i] <- as.numeric(tstack[[i]]$times$everything[3])
  x5[i] <- tstack[[i]]$modelInfo$label
}

# coerce to data frame
df1 <- data.frame(x1,x2,x3,x4,x5, stringsAsFactors=FALSE)

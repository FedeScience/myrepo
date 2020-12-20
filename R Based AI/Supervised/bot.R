
require(caret)
require(mlbench)
require(DT)

data(iris) 
(cla <- unique(modelLookup()[modelLookup()$forClass,c(1)]))
(reg <- unique(modelLookup()[modelLookup()$forReg,c(1)]))
(m <- intersect(cla,reg))

# slow classification models ("rbf" crashes; "dwdLinear", "ownn", "snn" have issues)
# all others may have just failed and are not listed here
ToFixModels <- c("AdaBoost.M1","pda2","dwdRadial","rbf","dwdLinear", "dwdPoly",
                 "gaussprLinear","gaussprPoly","rFerns","sddaLDA", "smda", "sddaQDA",
                 "xgbLinear", "mlpKerasDropout", "bartMachine", "blackboost", "bag",
                 "elm", "extraTrees", "gamboost", "glmboost", "glm", "gbm_h2o" ,
                 "logreg", "mlpKerasDecay", "plsRglm", "nodeHarvest", "glmnet_h2o",
                 "glmStepAIC", "msaenet", "logicBag", "mlpSGD", "mxnet", "mxnetAdam",
                 "null", "randomGLM")

#remove all slow and failed models from model list
(m <- m[!m %in% ToFixModels])

# pre-load all packages (does not really work due to other dependencies)
suppressPackageStartupMessages(ll <-lapply(m, require, character.only = TRUE))

# load X and Y (this will be transferred to to train function)
X = iris[,1:3]
Y = iris$Species

# register parallel front-end
library(doParallel); cl <- makeCluster(detectCores()); registerDoParallel(cl)

# this setup actually calls the caret::train function, in order to provide
# minimal error handling this type of construct is needed.
trainCall <- function(i) 
{
  cat("----------------------------------------------------","\n");
  set.seed(123); cat(i," <- loaded\n");
  return(tryCatch(
    t2 <- train(y=Y, x=X, (i), trControl = trainControl(method = "boot632")),
    error=function(e) NULL))
}

# use lapply/loop to run everything, required for try/catch error function to work
t2 <- lapply(m, trainCall)

#remove NULL values, we only allow succesful methods, provenance is deleted.
t2 <- t2[!sapply(t2, is.null)]

# this setup extracts the results with minimal error handling 
# TrainKappa can be sometimes zero, but Accuracy SD can be still available
# see Kappa value http://epiville.ccnmtl.columbia.edu/popup/how_to_calculate_kappa.html
printCall <- function(i) 
{
  return(tryCatch(
    {
      cat(sprintf("%-22s",(m[i])))
      cat(round(getTrainPerf(t2[[i]])$TrainAccuracy,4),"\t")
      cat(round(getTrainPerf(t2[[i]])$TrainKappa,4),"\t")
      cat(t2[[i]]$times$everything[3],"\n")},
    error=function(e) NULL))
}

r2 <- lapply(1:length(t2), printCall)

# stop cluster and register sequntial front end
stopCluster(cl); registerDoSEQ();

# preallocate data types
i = 1; MAX = length(t2);
x1 <- character() # Name
x2 <- numeric()   # R2
x3 <- numeric()   # RMSE
x4 <- numeric()   # time [s]
x5 <- character() # long model name

# fill data and check indexes and NA with loop/lapply 
for (i in 1:length(t2)) {
  x1[i] <- t2[[i]]$method
  x2[i] <- as.numeric(round(getTrainPerf(t2[[i]])$TrainAccuracy,4))
  x3[i] <- as.numeric(round(getTrainPerf(t2[[i]])$TrainKappa,4))
  x4[i] <- as.numeric(t2[[i]]$times$everything[3])
  x5[i] <- t2[[i]]$modelInfo$label
}

# coerce to data frame
df1 <- data.frame(x1,x2,x3,x4,x5, stringsAsFactors=FALSE)

# print all results to R-GUI
df1

# plot models, just as example
# ggplot(t2[[1]])
# ggplot(t2[[1]])

# call web output with correct column names
datatable(df1,  options = list(
  columnDefs = list(list(className = 'dt-left', targets = c(0,1,2,3,4,5))),
  pageLength = MAX,
  order = list(list(2, 'desc'))),
  colnames = c('Num', 'Name', 'Accuracy', 'Kappa', 'time [s]', 'Model name'),
  caption = paste('Classification results from caret models',Sys.time()),
  class = 'cell-border stripe')  %>% 	       
  formatRound('x2', 3) %>%  
  formatRound('x3', 3) %>%
  formatRound('x4', 3) %>%
  formatStyle(2,
              background = styleColorBar(x2, 'steelblue'),
              backgroundSize = '100% 90%',
              backgroundRepeat = 'no-repeat',
              backgroundPosition = 'center'
  )

# print confusion matrix example
caret::confusionMatrix(t2[[1]])


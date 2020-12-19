# Get all caret models for regression and classification
# https://github.com/tobigithub/caret-machine-learning
# Tobias Kind (2015)

# -----------------------------------------------------------
# get all caret models for regression

require(caret)
modNamesforReg <- unique(modelLookup()[modelLookup()$forReg,c(1)])
length(modNamesforReg); modNamesforReg;

# -----------------------------------------------------------
# get all caret models for classification

require(caret)
modNamesforClass <- unique(modelLookup()[modelLookup()$forClass,c(1)])
length(modNamesforClass); modNamesforClass
 
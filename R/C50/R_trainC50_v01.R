# Need installing following packages
library(jsonlite)
library(caret)
library(C50)
# train C50 model
# data retrieval
gs1df <- fromJSON("F:/GoogleDrive_005/matlab_program/IHC_v2/R/C50/C50_train_temp.json")
gs1df <- gs1df$annotations
# select corresponding columns
gs1df <- gs1df[,c(65,20,21,22,23,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49)]
gs1df$C50 <- as.factor(gs1df$C50)
model_gsdf <- C5.0(C50 ~., data=gs1df, trials = 100)
save(model_gsdf,file="F:/GoogleDrive_005/matlab_program/IHC_v2/R/C50/C50_v01_test20231212chhGT.RData")

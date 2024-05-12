# Need installing following packages
library(jsonlite)
library(caret)
library(C50)
if (file.exists("F:/StainAIMicroglia_v1//R/C50/C50_v01.RData")) {
  model_gsdf<-get(load("F:/StainAIMicroglia_v1//R/C50/C50_v01.RData"))
} else {
# train C50 model
}
test1df <- fromJSON("F:/data/CR1/CR1 slide 1/cocoJson/CR1 slide 1__Yolo512_Unet_256x256__result__netC4b1_ML__V04regp11.json")
test1df <- test1df$annotations
test1df <- test1df[,c(16,17,18,19,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45)]
test1df_results <- predict(object=model_gsdf, newdata=test1df, type="class")
# write to Json files
cr1df <- fromJSON("F:/data/CR1/CR1 slide 1/cocoJson/CR1 slide 1__Yolo512_Unet_256x256__result__netC4b1_ML__V04regp11.json")
cr1df$annotations$C50 <- test1df_results
write(toJSON(cr1df), "F:/data/CR1/CR1 slide 1/cocoJson/CR1 slide 1__Yolo512_Unet_256x256__result__netC4b1_ML__V04regp11__C50v1.json")

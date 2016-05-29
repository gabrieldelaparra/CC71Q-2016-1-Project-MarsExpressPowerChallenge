setwd("C:/Users/clgadel/Desktop/DCC/4 - 2016.01/CC71Q-1 Introducción a la Mineria de Datos/Tareas/Mars Express")
library(dplyr)
library(zoo)
library(miscTools)
library(randomForest)
library(ggplot2)

ltdata1 <- read.csv("Data\\train_set\\context--2008-08-22_2010-07-10--ltdata.csv")
saaf1 <- read.csv("Data\\train_set\\context--2008-08-22_2010-07-10--saaf.csv")
power1 <- read.csv("Data\\train_set\\power--2008-08-22_2010-07-10.csv")

saaf1DT <- saaf1
saaf1DT$ut_ms <- as.POSIXct((((saaf1['ut_ms'])/1000)[,]), origin="1970-01-01")

ltdata1DT <- ltdata1
ltdata1DT$ut_ms <- as.POSIXct((((ltdata1['ut_ms'])/1000)[,]), origin="1970-01-01")

power1DT <- power1
power1DT$ut_ms <- as.POSIXct((((power1['ut_ms'])/1000)[,]), origin="1970-01-01")

power1DT$ut_ms <- cut(power1DT$ut_ms, breaks="hour")
power1DTHourMean <- power1DT %>% group_by(ut_ms) %>% summarise_each(funs(mean))

saaf1DT$ut_ms <- cut(saaf1DT$ut_ms, breaks="hour")
saaf1DTHourMean <- saaf1DT %>% group_by(ut_ms) %>% summarise_each(funs(mean))

ltdata1DT$ut_ms <- cut(ltdata1DT$ut_ms, breaks="hour")
ltdata1DTHourMean <- ltdata1DT %>% group_by(ut_ms) %>% summarise_each(funs(mean))

power1DTHourMeanMS <- power1DTHourMean$ut_ms

for (i in 1:nrow(ltdata1DTHourMean)) {
  ltdata1DTHourMean$ut_ms[i] <- power1DTHourMeanMS[findInterval(ltdata1DTHourMean$ut_ms[i],power1DTHourMeanMS)]
}

for (i in 1:nrow(saaf1DTHourMean)) {
  saaf1DTHourMean$ut_ms[i] <- power1DTHourMeanMS[findInterval(saaf1DTHourMean$ut_ms[i],power1DTHourMeanMS)]
}

power1DTHourMean<-merge(x=power1DTHourMean, y=ltdata1DTHourMean, by="ut_ms", all.x=TRUE)
power1DTHourMean<-merge(x=power1DTHourMean, y=saaf1DTHourMean, by="ut_ms", all.x=TRUE)

power1DTHourMean$sunmars_km <- na.spline(power1DTHourMean[,grep("sunmars_km", colnames(power1DTHourMean))],na.rm = FALSE)
power1DTHourMean$earthmars_km <- na.spline(power1DTHourMean[,grep("earthmars_km", colnames(power1DTHourMean))],na.rm = FALSE)
power1DTHourMean$sunmarsearthangle_deg <- na.spline(power1DTHourMean[,grep("sunmarsearthangle_deg", colnames(power1DTHourMean))],na.rm = FALSE)
power1DTHourMean$solarconstantmars <- na.spline(power1DTHourMean[,grep("solarconstantmars", colnames(power1DTHourMean))],na.rm = FALSE)
power1DTHourMean$occultationduration_min <- na.spline(power1DTHourMean[,grep("occultationduration_min", colnames(power1DTHourMean))],na.rm = FALSE)
power1DTHourMean$eclipseduration_min <- na.approx(power1DTHourMean[,grep("eclipseduration_min", colnames(power1DTHourMean))],na.rm = FALSE, rule=2)

RMSE = function(predicted, reference){
  sqrt(mean((predicted - reference)^2))
}

predictCols = colnames(power1DT[,-1])

train <- power1DTHourMean[1:8000,-1]
test <- power1DTHourMean[8001:16000,-1]

colName <- predictCols[5]
X<-train[predictCols]
rf <- randomForest(as.formula(paste(colName," ~ .")) ,data=train, ntree=10)
predicted <- predict(rf, test)
predCol <- test[,c(colName)]
r2 <- RMSE(predCol, predicted)
p <- ggplot(aes(x=actual, y=pred), data=data.frame(actual=predCol, pred=predict(rf, test)))
p + geom_point() +  geom_abline(color="red") + ggtitle(paste("RandomForest Regression RMSE=", r2, sep=""))


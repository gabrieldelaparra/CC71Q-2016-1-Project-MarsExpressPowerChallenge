#Lectura de los archivos de entrenamiento:
setwd("C:/Users/clgadel/Desktop/DCC/4 - 2016.01/CC71Q-1 Introducción a la Mineria de Datos/Tareas/Mars Express")

dmop1 <- read.csv("Data\\train_set\\context--2008-08-22_2010-07-10--dmop.csv")
evtf1 <- read.csv("Data\\train_set\\context--2008-08-22_2010-07-10--evtf.csv")
ftl1 <- read.csv("Data\\train_set\\context--2008-08-22_2010-07-10--ftl.csv")
ltdata1 <- read.csv("Data\\train_set\\context--2008-08-22_2010-07-10--ltdata.csv")
saaf1 <- read.csv("Data\\train_set\\context--2008-08-22_2010-07-10--saaf.csv")
power1 <- read.csv("Data\\train_set\\power--2008-08-22_2010-07-10.csv")

dmop2 <- read.csv("Data\\train_set\\context--2010-07-10_2012-05-27--dmop.csv")
evtf2 <- read.csv("Data\\train_set\\context--2010-07-10_2012-05-27--evtf.csv")
ftl2 <- read.csv("Data\\train_set\\context--2010-07-10_2012-05-27--ftl.csv")
ltdata2 <- read.csv("Data\\train_set\\context--2010-07-10_2012-05-27--ltdata.csv")
saaf2 <- read.csv("Data\\train_set\\context--2010-07-10_2012-05-27--saaf.csv")
power2 <- read.csv("Data\\train_set\\power--2010-07-10_2012-05-27.csv")

dmop3 <- read.csv("Data\\train_set\\context--2012-05-27_2014-04-14--dmop.csv")
evtf3 <- read.csv("Data\\train_set\\context--2012-05-27_2014-04-14--evtf.csv")
ftl3 <- read.csv("Data\\train_set\\context--2012-05-27_2014-04-14--ftl.csv")
ltdata3 <- read.csv("Data\\train_set\\context--2012-05-27_2014-04-14--ltdata.csv")
saaf3 <- read.csv("Data\\train_set\\context--2012-05-27_2014-04-14--saaf.csv")
power3 <- read.csv("Data\\train_set\\power--2012-05-27_2014-04-14.csv")

#Lectura de los datos del set de pruebas:
dmopTest <- read.csv("Data\\test_set\\context--2014-04-14_2016-03-01--dmop.csv")
evtfTest <- read.csv("Data\\test_set\\context--2014-04-14_2016-03-01--evtf.csv")
ftlTest <- read.csv("Data\\test_set\\context--2014-04-14_2016-03-01--ftl.csv")
ltdataTest <- read.csv("Data\\test_set\\context--2014-04-14_2016-03-01--ltdata.csv")
saafTest <- read.csv("Data\\test_set\\context--2014-04-14_2016-03-01--saaf.csv")

#Los valores predichos de salida debe quedar en el siguiente archivo:
powerTest <- read.csv("power-prediction-sample-2014-04-14_2016-03-01.csv")
#Notar que los valores que hay que predecir están dados cada 1 hora.
#Se colocarán los datos de entrada en el mismo formato, es decir, cada 1 hora. 
#Se tomara el promedio de los valores. Esto para los valores de potencia.

#Melts
power1Melt <- melt(power1, id=ut_ms)
saaf1Melt <- melt(saaf1, id=ut_ms)
ltdata1Melt <- melt(ltdata1, id=ut_ms)

#Vector de suma de potencias:
sum <- rowSums(power1[,c(2:34)])
ut_ms<-power1$ut_ms
power1Sum <- data.frame(ut_ms,sum)


#Para convertir los tiempos en ms a tiempo se usa el siguiente código:
ms <- ltdata1['ut_ms']
msD <- ms/1000
msV <- msD[,]
msDT <- as.POSIXct(msV, origin="1970-01-01")
head(msDT)


#Conversión de ms a DateTime POSIXct:
saaf1DT <- saaf1
saaf1DT$ut_ms <- as.POSIXct((((saaf1['ut_ms'])/1000)[,]), origin="1970-01-01")

ltdata1DT <- ltdata1
ltdata1DT$ut_ms <- as.POSIXct((((ltdata1['ut_ms'])/1000)[,]), origin="1970-01-01")

power1DT <- power1
power1DT$ut_ms <- as.POSIXct((((power1['ut_ms'])/1000)[,]), origin="1970-01-01")

dmop1DT <- dmop1
dmop1DT$ut_ms <- as.POSIXct((((dmop1['ut_ms'])/1000)[,]), origin="1970-01-01")

evtf1DT <- evtf1
evtf1DT$ut_ms <- as.POSIXct((((evtf1['ut_ms'])/1000)[,]), origin="1970-01-01")

ftl1DT <- ftl1
ftl1DT$ute_ms <- as.POSIXct((((ftl1['ute_ms'])/1000)[,]), origin="1970-01-01")
ftl1DT$utb_ms <- as.POSIXct((((ftl1['utb_ms'])/1000)[,]), origin="1970-01-01")

#Para sacar el promedio por hora de los valores
#Primero se redondea el valor a la hora que corresponde y se agrupan:
library(dplyr)
power1DT$ut_ms <- cut(power1DT$ut_ms, breaks="hour")
power1DTHourMean <- power1DT %>% group_by(ut_ms) %>% summarise_each(funs(mean))

saaf1DT$ut_ms <- cut(saaf1DT$ut_ms, breaks="hour")
saaf1DTHourMean <- saaf1DT %>% group_by(ut_ms) %>% summarise_each(funs(mean))


#power2DT <- power2
#power2DT$ut_ms <- as.POSIXct((((power2['ut_ms'])/1000)[,]), origin="1970-01-01")

#Vector de tiempo comun para todos:
power1DTHourMeanMS <- power1DTHourMean$ut_ms

#Buscar el valor más cercano de los vectores a los valores de potencia:
#for (i in 1:nrow(ltdata1Copy)) {
#  oldMS <- ltdata1Copy$ut_ms[i]
#  newMS<-power1ms[which.min(abs(power1ms - ltdata1Copy$ut_ms[i]))]
#  #print(paste("i:", i, " ltdata1MS:",oldMS," power1MS:",newMS))
#  ltdata1Copy$ut_ms[i] <- newMS
#}

#for (i in 1:nrow(saaf1Copy)) {
#  oldMS <- saaf1Copy$ut_ms[i]
#  newMS<-power1ms[which.min(abs(power1ms - saaf1Copy$ut_ms[i]))]
#  #print(paste("i:", i, " saaf1MS:",oldMS," power1MS:",newMS))
#  saaf1Copy$ut_ms[i] <- newMS
#}

#findInterval(4.5, c(1,2,4,5,6))
for (i in 1:nrow(ltdata1DT)) {
  ltdata1DT$ut_ms[i] <- power1DTHourMeanMS[findInterval(ltdata1DT$ut_ms[i],power1DTHourMeanMS)]
}

for (i in 1:nrow(saaf1DTHourMean)) {
  saaf1DTHourMean$ut_ms[i] <- power1DTHourMeanMS[findInterval(saaf1DTHourMean$ut_ms[i],power1DTHourMeanMS)]
}

#Es necesario juntar las tablas de los valores que tenga, en este caso, voy a crear un nuevo dataFrame para
#juntar los valores
power1DTHourMean<-merge(x=power1DTHourMean, y=ltdata1DT, by="ut_ms", all.x=TRUE)
power1DTHourMean<-merge(x=power1DTHourMean, y=saaf1DTHourMean, by="ut_ms", all.x=TRUE)

#Ahora es necesario entrenar el sistema:



#Para sacar el promedio por hora de los valores
#Primero se redondea el valor a la hora que corresponde y se agrupan:
library(dplyr)
power1DTCopy <- power1DT
power1DTCopy$ut_ms <- cut(power1DTCopy$ut_ms, breaks="hour")
power1DTCopyGrouped <- power1DTCopy %>% group_by(ut_ms) %>% summarise_each(funs(mean))

#power2DTCopy <- power2DT
#power2DTCopy$ut_ms <- cut(power2DTCopy$ut_ms, breaks="hour")
#power2DTCopyGrouped <- power2DTCopy %>% group_by(ut_ms) %>% summarise_each(funs(mean))

#Para evaluar el modelo se utilizará RMSE:
RMSE = function(m, o){
  sqrt(mean((m - o)^2))
}

#A modo prueba, se pueden comparar los datos del año 1 con los del año 2:
RMSE(power1DTCopyGrouped[1:16000,-1],power2DTCopyGrouped[1:16000,-1])


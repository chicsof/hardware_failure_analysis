
getwd()
setwd("/n_mon")

#import merged data set
cpuDataSet <- read.table("cpu.csv",fill = TRUE,header=TRUE, sep=",",  stringsAsFactors=FALSE)

head(cpuDataSet)

#combine date and time for a new column, tranform from char to date
cpuDataSet$CPU.Total.klf <- as.POSIXct(paste(cpuDataSet$date, cpuDataSet$CPU.Total.klf), format = "%d/%m/%Y %H:%M:%S")
colnames(cpuDataSet)[colnames(cpuDataSet)=="CPU.Total.klf"] <- "timestamp"

#calculate percentage usge of total CPU from 64 cores
cpuDataSet$totalCPUUsage <- cpuDataSet$CPU.*100/64

#remove unwanted columns
cpuDataSet$date <- NULL
cpuDataSet$CPU. <- NULL
cpuDataSet$CPUs <- NULL

#avarege time to 15 mins to make data for each day uniform
cpuDataSet$timestamp <-as.POSIXlt(round(as.double(cpuDataSet$timestamp)/(15*60))*(15*60),origin=(as.POSIXlt('1970-01-01')))


#create date and time as seperate fileds for the next step
cpuDataSet$Date <- as.Date(cpuDataSet$timestamp)
cpuDataSet$Time <- format(cpuDataSet$timestamp, "%H:%M:%S")

#create a new field to distinguese between dates where server went unrisponsive. That means that less than
#(24*60/15+1)= 97 total samples were colected as comfired by
cpuDataSet$Date <- as.factor(cpuDataSet$Date)
frTable <- table(cpuDataSet$Date)
plot(frTable)
max(frTable)

#see how are data looks:
plot(cpuDataSet$timestamp, cpuDataSet$totalCPUUsage)
#threshold for desired range
abline(h=75, col="red")

#return all points above threshold
busyTimes <- subset(cpuDataSet, cpuDataSet$totalCPUUsage >= 75);

#get a range
max(busyTimes$Time)
min(busyTimes$Time)

#get an avarage
library(chron)
mean(times(busyTimes$Time))

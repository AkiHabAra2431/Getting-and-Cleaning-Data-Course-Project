install.packages("reshape2")
library(reshape2)

#Download data
packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "getdata_dataset.zip"))
unzip(zipfile = "getdata_dataset.zip")

#Activity Labels + features
ActivityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
ActivityLabels[,2] <- as.character(ActivityLabels[,2])
Features <- read.table("UCI HAR Dataset/features.txt")
Features[,2] <- as.character(Features[,2])

#Data on mean and standar desviation
FeaturesWantd <- grep(".*mean.*|.*std.*", Features[,2])
FeaturesWantd.names <- Features[FeaturesWantd,2]
FeaturesWantd.names = gsub('-mean', 'Mean', FeaturesWantd.names)
FeaturesWantd.names = gsub('-std', 'Std', FeaturesWantd.names)
FeaturesWantd.names <- gsub('[-()]', '', FeaturesWantd.names)

#Train
Train <- read.table("UCI HAR Dataset/train/X_train.txt")[FeaturesWantd]
TrainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
TrainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
Train <- cbind(TrainSubjects, TrainActivities, Train)

#Test
Test <- read.table("UCI HAR Dataset/test/X_test.txt")[FeaturesWantd]
TestActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
TestSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
Test <- cbind(TestSubjects, TestActivities, Test)

#Merge
AllData <- rbind(Train, Test)
colnames(allData) <- c("subject", "activity", FeaturesWantd.names)

#Convert
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- reshape2::melt(allData, id = c("subject", "activity"))
allData.mean <- reshape2::dcast(allData.melted, subject + activity ~ variable, fun.aggregate = mean)


#Result
write.table(allData.mean, "project.txt", row.names = FALSE, quote = FALSE)


library(reshape2)

filename <- "getdata_dataset.zip"

## Download and unzip data
if (!file.exists(filename)){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
        download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
        unzip(filename) 
}

# Activity labels and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extracts only the measurements on the mean and standard deviation for each measurement.
featuresSub <- grep(".*mean.*|.*std.*", features[,2])
featuresSub.names <- features[featuresSub,2]
featuresSub.names = gsub('-mean', 'Mean', featuresSub.names)
featuresSub.names = gsub('-std', 'Std', featuresSub.names)
featuresSub.names <- gsub('[-()]', '', featuresSub.names)

# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresSub]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresSub]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresSub.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

allDatamelt <- melt(allData, id = c("subject", "activity"))
allDatamean <- dcast(allDatamelt, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
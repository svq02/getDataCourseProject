
# This script demonstrates techniques for making data tidy using functions from the dplyr
# package and regular expressions. The original data on smartphone signal analysis is
# manipulated here such that:
#
#1. The training and the test data sets are merged to create one data set.
#2. Only the measurements on the mean and standard deviation for each measurement are extracted. 
#3. Descriptive activity names to name the activities in the data set are used.
#4. Descriptive variable names are used to label the data set.
#5. A new, tidy data set is created containing the mean value for each activity and subject in the
#   experiment.
# The orginal readme file describing the original data structures can be found in the file
# README-UCI.txt

require(data.table)
require(dplyr)

# Main function, that executes the five steps described above.
main <- function() {
  fn1 <- 'UCI HAR Dataset/train/X_train.txt'
  fn2 <- 'UCI HAR Dataset/test/X_test.txt'
  afn1<- 'UCI HAR Dataset/train/y_train.txt'
  afn2<- 'UCI HAR Dataset/test/y_test.txt'
  sfn1<- 'UCI HAR Dataset/train/subject_train.txt'
  sfn2<- 'UCI HAR Dataset/test/subject_test.txt'
  print('Merging test and training datasets...')
  d <- joinDatasets(fn1, afn1, sfn1, fn2, afn2, sfn2)
  print('...done')
  print('Extracting variables that are measurements on the mean or standard deviation...')
  featuresListName <- 'UCI HAR Dataset/features.txt'
  d <- d[,meanOrStdVariables(featuresListName)]
  print('...done')
  print('Generating descriptive variable names based on abbreviated feature names...')
  d <- generateDescriptiveActivities(d)
  names(d) <- c(generateFeatureDescriptions(featuresListName), 'Subject', 'Activity')
  print('...done')
  print('Creating tidy dataset with mean value for each activity and subject...')
  tidyDataset <- createTidyDataset(d)
  print('...done')
  print('Writing tidy dataset to file...')
  ofn = 'tidyData.txt'
  write.table(tidyDataset, ofn, row.name=F)
  print('...done')
}

## Function to create the final dataset. First the intermediate data table is grouped
#  by activity type and subject number. Finally the mean values for each feature is
#  computed for each activity type and subject number.
#  @param tdf an intermediate dplyr tbl
#  @return tidy the final dplyr tble with the mean values
##
createTidyDataset <- function(tdf) {
  tidy <- NULL
  byActivityAndSubject <- group_by(tdf, Activity, Subject)
  tidy <- summarise_each(byActivityAndSubject,funs(mean))
  tidy
}

## Function to detect whether a feature is a measurement on the mean or standard deviation
#  based on the feature name. Only features with "-mean()" or "-std()" are included as
#  explained in the code book.
#  @param fnl the path and file name of the table describing the features
#  @return a logical vector indicating whether each feature is a measurement on the mean or 
#  standard deviation
##
meanOrStdVariables <- function(fnl='') {
  if (fnl == '') {
    print('[run_analysis::meanOrStdVariables] No file specified. Aborting Mission.')
  } else {
    features <- tbl_df(read.table(fnl))
    names(features) <- c('cn', 'Feature')
# Need to double escape parenthesis in grep or use fixed=True
    features <- mutate(features, isMeanVariable=grepl('-mean\\(\\)',features$Feature),
                                 isStdVariable=grepl('-std\\(\\)',features$Feature),
                                 isMeanOrStdVariable=(isMeanVariable | isStdVariable))

  }
  features$isMeanOrStdVariable
}

## Function to replace a column that has activity labels with descriptive names for
#  those activities.
#  @param tdf an intermediate dplyr tbl
#  @return tdf a dplyr tbl with the numeric values for activities replaced with descriptive
#  string values
##
generateDescriptiveActivities <- function(tdf) {
  tdf$Activity[tdf$Activity_Label == 1] <- 'Walking'
  tdf$Activity[tdf$Activity_Label == 2] <- 'Walking_Upstairs'
  tdf$Activity[tdf$Activity_Label == 3] <- 'Walking_Downstairs'
  tdf$Activity[tdf$Activity_Label == 4] <- 'Sitting'
  tdf$Activity[tdf$Activity_Label == 5] <- 'Standing'
  tdf$Activity[tdf$Activity_Label == 6] <- 'Laying'
  tdf <- select(tdf, -Activity_Label)
  tdf
}

## Function to generate descriptive names for feature variables, based on the abbreviated
#  feature names found in features.txt. Uses regular expressions to expand and replace
#  character values in the feature names.
#  @param fnl the path and file name of the table describing the features
#  @return f a vector of descriptive feature names for each feature that is a measurement
#  on the mean or standard deviation that can be used as column headings in the tidy dataset.
##
generateFeatureDescriptions <- function(fnl='') {
  if (fnl == '') {
    print('[run_analysis::generateFeatureDescriptions] No file specified. Aborting Mission.')
  } else {
    features <- read.table(fnl)
    names(features) <- c('cn', 'Feature')
    f <- as.character(features[,2])
    f <- f[meanOrStdVariables(fnl)]
    for (i in 1:length(f)) {
      ifelse((substring(f[i], 1, 1) == 't'), f[i] <- sub('t', 'Time Domain ', f[i]),
                                             f[i] <- sub('f', 'Frequency Domain ', f[i]))
    }
    f <- sub('-std\\(\\)', 'Standard Deviation ', f)
    f <- sub('-mean\\(\\)', 'Mean ', f)
    f <- gsub('Body', 'Body ', f)
    f <- sub('Gravity', 'Gravity ', f)
    f <- sub('Gyro', 'Gyroscope ', f)
    f <- sub('Acc', 'Acceleration ', f)
    f <- sub('Mag', 'Magnitude ', f)
    f <- sub('Jerk', 'Jerk ', f)
    f <- sub('-X', 'X-Direction', f)
    f <- sub('-Y', 'Y-Direction', f)
    f <- sub('-Z', 'Z-Direction', f)
    f
  }
}

# Function to merge data sets. First the activity labels and subject identifiers are added
# to each of the test and training datasets
#  @param fn1 the file name of the training dataset
#  @param fn2 the file name of the test dataset
#  @param afn1 the file name of the training activites dataset
#  @param afn2 the file name of the test activites dataset
#  @param sfn1 the file name of the training subject identifier dataset
#  @param sfn2 the file name of the test subject identifier dataset
#  @return d a dplyr tbl that contains the merged training and test datasets
##

joinDatasets <- function(fn1, afn1, sfn1, fn2, afn2, sfn2) {
  d1 <- read.table(fn1, header=FALSE)
  d2 <- read.table(fn2, header=FALSE)
  a1 <- read.table(afn1, header=FALSE)
  a2 <- read.table(afn2, header=FALSE)
  s1 <- read.table(sfn1, header=FALSE)
  s2 <- read.table(sfn2, header=FALSE)
# Add activity labels to data
  names(a1) = 'Activity_Label'
  names(a2) = 'Activity_Label'
# Add subject labels to data
  names(s1) = 'Subject'
  names(s2) = 'Subject'
  d1 <- cbind(d1, a1, s1)
  d2 <- cbind(d2, a2, s2)
  d <- tbl_df(merge(d1, d2, all=TRUE))
# The following command is much faster than a merge, and will have the same information,
# but the observations will be in a different order.
#  d <- tbl_df(rbind(d1, d2))
}

# Actually run the main function when the file is sourced.
main()


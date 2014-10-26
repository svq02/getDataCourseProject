
# Code Book describing the data, variables, and transformations utilized in run\_analysis.R

This analysis code uses the UCI HAR smartphone dataset. The original code book for this dataset is included in this repo in the file README-UCI.txt. This dataset contains measurments of smartphone and body movement for 30 subjects while performing 6 different activities. The dataset is split up into two sets, with 21 subject as part of the training set and the remaining 9 in the test set. 

## Data

The following data is taken from the original dataset and manipulated here:

* X_train.txt : The feature measurement data set for the training group.
* X_test.txt : The feature measurement data set for the test group.
* y_train.txt : The dataset indicating which activity was being performed for each measurement for the training group.
* y_test.txt : The dataset indicating which activity was being performed for each measurement for the test group.
* subject_train.txt : The dataset indicating which subject was being tested for each measurement for the training group.
* subject_test.txt : The dataset indicating which subject was being tested for each measurement for the test group.

## Variables

There are 561 variables in this dataset, in addition to the activity and the subject identifier. Of those variables (referred to as features), 66 features are considered to be measurements on the mean or standard deviation, based on the existence of the strings "-mean()" or "-std()" in the feature descriptions, included in the original UCI code book. There are additional variables with the words "mean" and "std" in them, but they are not actually computed as a statistical quantity on a set of independent measurements, and so are not included in the cleaned data.

In addition to these variables, I create new variables corresponding to the activity being performed and subject identifier that is included in the tidy dataset.

## Transformations

The following transformations of the original data are performed in the script run\_analysis.R in order to produce a tidy data table:

* The training and test datasets are merged to create a single dataset. Prior to this, the activity labels and subject identifier datasets are added so that they correspond to the measurement data correctly.

* Measurements on the mean and standard deviation are extracted from the original data set. Only variables that have the mean or standard deviation computed from a set of measurements are included in this transformation.

* The numeric activitly labels in the original dataset are replaced with descriptive names taken from file "UCI\ HAR\ Dataset/activity_labels.txt".

* Descriptive variable names for all of the feature measurement variables are expanded and replace the abbreviated names given in the file UCI\ HAR\ Dataset/features.txt 

* The dataset is grouped by activity and subject identifier and the mean value of each measurement is computed. A new, tidy dataset is constructed from this and is written to a text file.



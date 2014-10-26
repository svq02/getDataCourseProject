getDataCourseProject
====================

# Repo for demonstrating techniques of creating tidy data.

This repo contains the following scripts:

1. run\_analysis.R : R script that manipulates UCI smartphone data and creates tidy dataset
2. README-UCI.txt : The original code book for the UCI smartphone data
3. CodeBook.md : The code book for the run\_analysis.R script that describes the variables, data, and transformations that are performed on the original data in order to produce tidy data.
4. README.md : This file.

## How the run\_analysis.R script works:

The run\analysis.R script performs five tasks on the original UCI smartphone data, as is described in the comments in the script. It assumes that the "UCI HAR Dataset" directory containing the original data is in the same directory as the script.

1. The script for reads in testing and training data for each feature, adds columns to each of these datasets for the activity labels and subject identifiers from the appropriate datasets, and merges the datasets together into a single, dplyr data table.

2. The features are read in from the 'UCI HAR Dataset/features.txt' dataset, and all of the features that are measurements on the mean or standard deviation are extracted.

3. The numeric activity labels that indicate the activity being performed for each measurement are replaced with descriptive text in the table using the mapping in 'UCI HAR Dataset/activity\_labels.tx'.

4. The column names for each feature measurement are expanded using regular expressions from their abbreviated values in the original data. So for instance, the string 'Acc' is replaced with 'Acceleration'. The descriptive names 'Activity' and 'Subject' are used to label the activity and subject columns respectively.

5. The intermediate data table is groups by activity and subject, and the mean value is computed for each feature measurement. A new table is created with this data, and it is written out to a text file. This file can be read in to R using the read.table() function.


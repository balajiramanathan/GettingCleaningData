
##  This code uses the library "plyr".  If this package is not already
##  installed, please uncomment the line below to install that package
##  install,package("plyr")
library(plyr)

##  First read the features list.  This will provide us with
##  the variable names we will use when we read the raw data
feature_info <- read.table("features.txt")

##  Next we read the activity labels file.  Note that we name
##  the first column of this file "ActivityLabel".  This will
##  come in handy when we merge the contents of this file with
##  the raw data
activity_info <- read.table("activity_labels.txt",
                            col.names = c("ActivityLabel", "Activity"))

##  Now, we read the test data.  Note that the test data consists of
##  three separate files, one containing the X values (the observations
##  from the smartphones), one containing the subject id's and the
##  third containing the activity labels (y values) of the activity 
##  the subject was performing when the data was produced
##  Note that we use check.names = FALSE so that R does not mangle the
##  variable names which have parentheses in them
test_dataX <- read.table("./test/X_test.txt", 
                         colClasses = rep("numeric", 561), 
                         col.names = feature_info[,2],
                         check.names = FALSE)
test_dataY <- read.table("./test/y_test.txt", col.names = "ActivityLabel")
test_dataS <- read.table("./test/subject_test.txt", col.names = "Subject")

##  We then use cbind() to make one single dataframe out of the test data
##  by combining the subject data, y values and x values
test_data <- cbind(test_dataS, test_dataY, test_dataX)

##  The same logic as above is applied to the training dataset
train_dataX <- read.table("./train/X_train.txt", 
                          colClasses = rep("numeric", 561), 
                          col.names = feature_info[,2],
                          check.names = FALSE)
train_dataY <- read.table("./train/y_train.txt", col.names = "ActivityLabel")
train_dataS <- read.table("./train/subject_train.txt", col.names = "Subject")

train_data <- cbind(train_dataS, train_dataY, train_dataX)

##  We now combine the test and training datasets into one large dataset
##  using rbind()
all_data <- rbind(test_data, train_data)

##  Note that the activity in our data is represented by a label rather
##  than the name of the activity.  We add the activity name to our dataset
##  by merging the data with the activity_info dataframe that we created
##  earlier.  Note that because of our naming convention, we do not have to
##  specify the merge field.  If the variables names are changed, the code
##  below will have to be changed to accommodate that
all_data_with_activity <- merge(all_data, activity_info)

##  Extract all the variable names from our dataframe
variable_names <- names(all_data_with_activity)

##  Find the indices of the variables that represent the means and
##  standard deviations of various measurements
mean_vars <- grep("mean()", variable_names, value = FALSE)
std_vars <- grep("std()", variable_names, value = FALSE)

##  Now, find the indices of the variables that represent the Subject
##  and the Activity
activity_var <- match("Activity", variable_names)
subject_var <- match("Subject", variable_names)

##  Combine all of these indices into a single vector
all_needed_vars <- c(subject_var, activity_var, mean_vars, std_vars)

##  Use that vector to subset the dataframe that contains all the data
all_needed_data <- all_data_with_activity[, all_needed_vars]

##  We now use ddply to get the mean of our data variables, grouped by
##  Subject and Activity.  This step produces our tidy dataset
final_tidy_data <- ddply(all_needed_data, 
                         .(Subject, Activity), 
                         numcolwise(mean,na.rm = TRUE))

##  The tidy dataset is written to the hard disk.  Please change the name
##  as appropriate.  We remove the row numbers using row.names = FALSE
write.table(final_tidy_data, "TidyData.txt", row.names = FALSE)

##  You can read the tidy dataset back into R using the command below
##  Uncomment it if you need to read the data back in.  Change the filename
##  as appropriate
##TidyData <- read.table("TidyData.txt", header = TRUE, check.names = FALSE)
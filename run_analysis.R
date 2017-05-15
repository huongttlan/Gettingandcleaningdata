library(rstudioapi)
library(data.table)
library(dplyr)
#Change the working directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# Read in the data for training set
subject_train=fread("train/subject_train.txt")
X_train=fread("train/X_train.txt")
y_train=fread("train/y_train.txt")
# Read in the data for testing set
subject_test=fread("test/subject_test.txt")
X_test=fread("test/X_test.txt")
y_test=fread("test/y_test.txt")
#Now combine
X_dataset<-tbl_df(rbind(X_train,X_test))
y_dataset<-tbl_df(rbind(y_train,y_test))
subject_dataset<-tbl_df(rbind(subject_train, subject_test))
names(subject_dataset)<-"Subject"
#Read feature names for X_dataset: Keep only mean and std
X_dataset_mean_std <- X_dataset[, grep("-(mean|std)\\(\\)", read.table("features.txt")[, 2])]
names(X_dataset_mean_std) <- read.table("features.txt")[grep("-(mean|std)\\(\\)", read.table("features.txt")[, 2]), 2] 
#Translate Activity Labels for Y_dataset:
k<-read.table("activity_labels.txt")
y_dataset<-select(left_join(y_dataset,k, by="V1"),V2)
names(y_dataset) <- "Activity"
#Ok, combine all to one dataset and make the name easier to read
Combine_dataset<-cbind(subject_dataset, X_dataset_mean_std, y_dataset)
#names(Combine_dataset) <- make.names(names(Combine_dataset))
names(Combine_dataset) <- gsub('Acc',"Acceleration",names(Combine_dataset))
names(Combine_dataset) <- gsub('GyroJerk',"AngularAcceleration",names(Combine_dataset))
names(Combine_dataset) <- gsub('Gyro',"AngularSpeed",names(Combine_dataset))
names(Combine_dataset) <- gsub('Mag',"Magnitude",names(Combine_dataset))
names(Combine_dataset) <- gsub('^t',"Time",names(Combine_dataset))
names(Combine_dataset) <- gsub('^f',"Frequency",names(Combine_dataset))
names(Combine_dataset) <- gsub('\\.mean',".Mean",names(Combine_dataset))
names(Combine_dataset) <- gsub('\\.std',".Std",names(Combine_dataset))
names(Combine_dataset) <- gsub('Freq\\.',"Frequency",names(Combine_dataset))
names(Combine_dataset) <- gsub('Freq$',"Frequency",names(Combine_dataset))
write.table(Combine_dataset, "Combine_dataset.txt")
#Now let's create a tidy dataset
Combine_dataset_groupby<-group_by(Combine_dataset,Subject, Activity)
finaltidy_dataset<- summarise_each(Combine_dataset_groupby,funs(mean))
write.table(finaltidy_dataset, "finaltidy_dataset.txt")
#write.table(names(finaltidy_dataset),"codebook.txt")
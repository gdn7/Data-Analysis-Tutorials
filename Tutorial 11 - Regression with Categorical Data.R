#############################################
#=============Read in Libraries=============#
# Read in the necessary libraries. Note,    #
# the commented code for installing		    #
# packages. Remove the "#" and run the	    #
# script to install them. You must be	    #
# connected to the internet to download	    #
# them.						                #
#############################################

library(psych)
library(car) #Used for Durbin-Watson test, VIF scores, binning
library(dummies) #Used to create dummy variables


#########################################################
#==============Setup the Working Directory==============#
# Set the working directory to the project folder by    #
# running the appropriate script below. Note, you can 	#
# run the data off of your OneDrive or DropBox.		    #
#########################################################

workingdirectory = "C:\\Users\\bryan\\OneDrive - Oklahoma State University\\Teaching\\MSIS 5223\\In-Class Exercises\\Data"
setwd(workingdirectory)


#############################################
#===============Read in data================#
# Read in the experiment data.	            #
#############################################

temptable = paste(workingdirectory, "\\reduction_data_new.txt", sep = "")
reduction_data = read.table(temptable, sep = '\t', header = TRUE)

colnames(reduction_data)

reduction_data$educ_level = as.factor(reduction_data$educ_level)
reduction_data$gender = as.factor(reduction_data$gender)

#############################################
#======= Data Cleaning and Analysis ========#
# Ensure data is clean. Ensure participants	#
# correctly answerd validation questions.	#
#############################################

#==========================
# Remove columns and save
# as new dataframe
#==========================
red_data = reduction_data[, c('peruse01', 'intent01', 'gender', 'educ_level', 'age')]

#======================================
# Rename columns in the new dataframe
#======================================
colnames(red_data) = c('usefulness', 'intent', 'gender', 'education', 'age')

#=======================
# Missing Data Removal
#=======================
complete.cases(red_data)

red_data = na.omit(red_data)

#==========================
# Perform binning for age
#==========================
range(red_data$age)
# Min: 18 -> Max: 48
# A total of 31 years

hist(red_data$age)
# The data is skewed, with a greater number
# of individuals with an age closer to 20

# Create non-overlapping sub-intervals (i.e. the bins).
# Select an arbitrary number to start out.
bin_interval = seq(18, 48, by = 5)

bin_interval
# 18, 23, 28, 33, 38, 43, 48

# View the binning in a table
table(cut(red_data$age, bin_interval, right = FALSE))
# Result: Due to the skewness of the data, the two bins
# on the left hold the most data. This is not an even
# distribution of the data. Perhaps bin by 2 years, not 5

bin_interval = seq(18, 48, by = 2)
table(cut(red_data$age, bin_interval, right = TRUE))
# Bin 18-20 includes 3 years, not two when 'right=TRUE'

table(cut(red_data$age, bin_interval, right = FALSE))
# Bin 18-20 includes only 2 years when 'right=FALSE'
# Notice, though, that bin 46-48 is empty; it should
# have a single value, but does not.

bin_interval = seq(18, 50, by = 2)
table(cut(red_data$age, bin_interval, right = FALSE))
# By changing the sequence from 18-48 to 18-50, the last
# bin captures the illusive record with age 48 while
# still retaining counts only for 2 years (i.e. bin 18-20)

#### Results: The first four bins contain the majority of 
#### the data. Take the last twelve bins and combine them
#### into a single bin.
bin_interval = c(18, 20, 22, 24, 26, 50)
table(cut(red_data$age, bin_interval, right = FALSE))

# Recode the values in the age column based on the binning
age_vector = recode(red_data$age, "18:19='18-19'; 20:21='20-21'; 
                    22:23='22-23'; 24:25='24-25'; 26:48='26-48'")

# Take the binning data and add it as a column to the dataframe
red_data$age_categ = age_vector

# Compare the original age column to the age_categ
red_data[, c('age', 'age_categ')]

#=================================
# Create dummy variables for the
# column age_categ
#=================================
red_dummy1 = dummy(red_data$age_categ, sep = '_')
colnames(red_dummy1)

colnames(red_dummy1) = c('age_18_19', 'age_20_21', 'age_22_23', 'age_24_25', 'age_26_48')

red_dummy1 = as.data.frame(red_dummy1)

red_data = data.frame(red_data, red_dummy1)

#=================================
# Create dummy variables for the
# column education
#=================================
red_dummy2 = dummy(red_data[, c('education')], sep = '_')
colnames(red_dummy2)

#Change the column names
colnames(red_dummy2) = c('educ_2', 'educ_3', 'educ_4', 'educ_5', 'educ_6')

#Convert the dummy variables into a dataframe
red_dummy2 = as.data.frame(red_dummy2)

#Add back into the dataframe
red_data = data.frame(red_data, red_dummy2)


#################################################
#==============Regression Analysis==============#
# Create the regression equations to assess the #
# model and ANOVA. This means to only include   #
# the categorical data.                         #
#################################################

#=====================
# Regression Model 1
#=====================
red_reg1 = lm(red_data$intent ~ red_data$gender + red_data$age_18_19 + red_data$age_20_21 + red_data$age_22_23 + red_data$age_24_25)
summary(red_reg1)

#=====================
# Regression Model 2
#=====================
red_reg2 = lm(red_data$intent ~ red_data$gender + red_data$age_18_19 + red_data$age_20_21 + red_data$age_22_23 + 
            red_data$age_24_25 + red_data$educ_2 + red_data$educ_3 + red_data$educ_4 + red_data$educ_5)
summary(red_reg2)

#=====================
# Regression Model 3
#=====================
red_reg3 = lm(red_data$intent ~ red_data$gender + red_data$age_18_19 + red_data$age_20_21 + red_data$age_22_23 +
            red_data$age_24_25 + red_data$usefulness)
summary(red_reg3)

plot(red_reg3)
#############################################
#=============Read in Libraries=============#
# Read in the necessary libraries.          #
#############################################

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os

#Binning of data
from scipy.stats import binned_statistic

#Regression output
from sklearn.linear_model import LinearRegression
import statsmodels.formula.api as smf


#####################################################
#============Setup the Working Directory============#
# Set the working directory to the project folder by#
# running the appropriate code below.               #
#####################################################

os.chdir('C:\\Users\\bryan\\OneDrive - Oklahoma State University\\Teaching\\MSIS 5223\\In-Class Exercises\\Data')


#############################################
#===============Read in data================#
#Read in the data for both data sets.	    #
#############################################

reduction_data = pd.read_table('reduction_data_new.txt')
reduction_data.columns

reduction_data.dtypes

reduction_data['gender'] = reduction_data['gender'].astype('category')
reduction_data['educ_level'] = reduction_data['educ_level'].astype('category')


#############################################
#======= Data Cleaning and Analysis ========#
# Ensure data is clean. Ensure participants	#
# correctly answerd validation questions.	#
#############################################

#==========================
# Remove columns and save
# as new dataframe
#==========================
red_data = reduction_data[['peruse01', 'intent01', 'gender', 'educ_level', 'age']]

#======================================
# Rename columns in the new dataframe
#======================================
red_data.columns = ['usefulness', 'intent', 'gender', 'education', 'age']

#=======================
# Missing Data Removal
#=======================
red_data.notnull()

red_data = red_data.dropna()

red_data.reset_index(inplace=True)

#==========================
# Perform binning for age
#==========================
red_data['age'].max()
# Max: 48

red_data['age'].min()
# Min: 18
# A total of 31 years

red_data['age'].plot.hist(alpha=0.5)
# The data is skewed, with a greater number
# of individuals with an age closer to 20

# Create non-overlapping sub-intervals (i.e. the bins).
# Select an arbitrary number to start out. 6 bins total
bin_counts,bin_edges,binnum = binned_statistic(red_data['age'], 
                                               red_data['age'], 
                                               statistic='count', 
                                               bins=6)

# Counts within each bin
bin_counts

# Bin Values (only shows left value, not right)
bin_edges

# Result: Due to the skewness of the data, the two bins
# on the left hold the most data. This is not an even
# distribution of the data. Perhaps bin by 2 years, not 5

bin_counts,bin_edges,binnum = binned_statistic(red_data['age'], 
                                               red_data['age'], 
                                               statistic='count', 
                                               bins=15)

bin_counts
# Unlike R, the last bin actually includes the value of 48

bin_edges

#### Results: The first four bins contain the majority of 
#### the data. Take the last twelve bins and combine them
#### into a single bin.

bin_interval = [18, 20, 22, 24, 26, 50]

bin_counts, bin_edges, binnum = binned_statistic(red_data['age'], 
                                                 red_data['age'], 
                                                 statistic='count', 
                                                 bins=bin_interval)

bin_counts

bin_edges

# Recode the values in the age column based on the binning
binlabels = ['age_18_19', 'age_20_21', 'age_22_23', 'age_24_25', 'age_26_48']
age_categ = pd.cut(red_data['age'], bin_interval, right=False, retbins=False, labels=binlabels)

age_categ.name = 'age_categ'

# Take the binning data and add it as a column to the dataframe
red_data = red_data.join(pd.DataFrame(age_categ))

# Compare the original age column to the age_categ
red_data[['age', 'age_categ']].sort_values(by='age')

#=================================
# Create dummy variables for the
# column age_categ
#=================================
red_dummy1 = pd.get_dummies(red_data['age_categ'])

red_dummy1.head()

red_data = red_data.join(red_dummy1)


#=================================
# Create dummy variables for the
# column education
#=================================
red_dummy2 = pd.get_dummies(red_data['education'], prefix='educ')

red_dummy2.head()

red_dummy2.columns = ['educ_2','educ_3','educ_4','educ_5','educ_6']

red_data = red_data.join(red_dummy2)


#################################################
#==============Regression Analysis==============#
# Create the regression equations to be used to	#
# obtain the VIF for the models. Also, you can 	#
# obtain the predicted values and residuals 	#
# from the regression model to assess constant 	#
# variance.							            #
#################################################

#=====================
# Regression Model 1
#=====================
red_reg1 = smf.ols('intent ~ gender + age_18_19 + age_20_21 + age_22_23 + age_24_25', red_data).fit()
red_reg1.summary()

#=====================
# Regression Model 2
#=====================
red_reg2 = smf.ols('intent ~ gender + age_18_19 + age_20_21 + age_22_23 + age_24_25 + educ_2 + educ_3 + educ_4 + educ_5', red_data).fit()
red_reg2.summary()

#=====================
# Regression Model 3
#=====================
red_reg3 = smf.ols('intent ~ gender + age_18_19 + age_20_21 + age_22_23 + age_24_25 + usefulness', red_data).fit()
red_reg3.summary()

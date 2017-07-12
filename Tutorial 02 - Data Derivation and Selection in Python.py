#############################################
#=============Read in Libraries=============#
# Read in the necessary libraries.          #
#############################################

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os

from sklearn.cross_validation import KFold


#####################################################
#============Setup the Working Directory============#
# Set the working directory to the project folder by#
# running the appropriate code below.               #
#####################################################

os.getcwd()

os.chdir('C:\\Users\\bryan\\OneDrive - Oklahoma State University\\Teaching\\MSIS 5223\\In-Class Exercises\\Data')
os.getcwd()


#############################################
#===============Read in data================#
#Read in the data for both data sets.	    #
#############################################

ozone_data = pd.read_table('ozone.data.txt', sep='\t')
ozone_data
ozone_data.columns
ozone_data.rad
ozone_data.head(5)

car_data = pd.read_table('car.test.frame.txt', sep='\t')
car_data.columns

car_data.drop(['Mileage', 'Type', 'Weight'], axis=1, inplace=True)
car_data.columns

car_data = pd.read_table('car.test.frame.txt', sep='\t')
car_data.drop(car_data.columns[[3,4,5]], axis=1, inplace=True)
car_data.columns

car_data = pd.read_table('car.test.frame.txt', sep='\t')

#Rename Mileage to Total_Mileage
car_data.columns = ['Price', 'Country', 'Reliability', 'Total_Mileage', 'Type'
, 'Weight', 'Disp.', 'HP']
car_data.columns

#Change the name of Mileage back
car_data.rename(columns={'Total_Mileage':'Mileage'}, inplace=True)
car_data.columns

seedlings_data = pd.read_table('seedlings.txt')

#Convert to categorical datatype
seedlings_data['cohort'] = seedlings_data['cohort'].astype('category')

#Select categorical columns
seedlings_data.select_dtypes(include=['category'])


#################################################
#=========Working with Data (Indices)===========#
# Indices (or subscripts) are the specific cell	#
# within the dataframe. It looks like this:	    #
# 	[1,2]							            #
#################################################

car_data.ix[36,:]
car_data.ix[:,4]

#Method 1
car_data.ix[56,1:4]
#Method 2b
car_data.ix[56,[1,2,3]]
#Method 2b
car_data.ix[56,['Country', 'Reliability', 'Mileage']]

car_data.ix[56,[1,3]]
car_data.ix[56,['Country', 'Mileage']]

mileage_data = car_data.ix[:,3]
mileage_data = car_data.ix[:,['Mileage']]

pd.unique(car_data.Country)

car_data.shape
len(car_data.index)
len(car_data.columns)

#=================
# Sorting data
#=================

car_data.sort_values(by='Reliability')

car_data.sort_values(by='Reliability',na_position='first')

car_data.nlargest(6,'Reliability')

car_data.nlargest(6,['Reliability','Mileage'])

car_data.sort_values(by=['Reliability','Mileage'])

car_data.sort_values(by=['Mileage','Reliability'])

#====================================
# Subsampling from a dataframe
# Select 60% of the data at random
#===================================

#=== First Method
splitnum = np.round((len(ozone_data.index) * 0.6), 0).astype(int)
splitnum
ozone_data_sample = ozone_data.sample(n=splitnum, replace=False)
len(ozone_data_sample.index)

#=== Second Method
ozone_data_sample = ozone_data.sample(frac=0.6, replace=False)
len(ozone_data_sample.index)


#===================================
# Select rows based on conditions
# Use seedlings data for example
#===================================

seedlings_data.head()

seedlings_data.columns

seedlings_data.cohort.unique()

#Select September data
seedlings_data[seedlings_data.cohort=='September']
seedlings_data[seedlings_data.cohort!='October']

seedlings_data[(seedlings_data.cohort=='September')&(seedlings_data.death<=10)]

seedlings_data[(seedlings_data.cohort=='September')|(seedlings_data.cohort=='October')]

pd.notnull(seedlings_data)

pd.isnull(seedlings_data)

#================================
# Subsampling from a dataframe
# k-fold cross validation sets
#================================

kf = KFold(len(car_data.index), n_folds=2)

for train, test in kf:
    print("%s %s" % (train, test))

car_data.ix[train]

#==========================
# Adding rows and columns
#==========================

#Simple example to add 3 new rows
newrows = [{'cohort':'November', 'death':333, 'gapsize':0.333},
           {'cohort':'November', 'death':444, 'gapsize':0.444},
           {'cohort':'December', 'death':5555, 'gapsize':0.555}]

seedlings_data2 = seedlings_data.append(newrows, ignore_index=True)

len(seedlings_data.index.values)

len(seedlings_data2.index.values)

#Adding an existing dataframe containing 5 records
newrows2 = pd.DataFrame({'cohort':['July', 'December', 'January', 'April', 'December'],
                         'death':[1,2,3,4,4],
                         'gapsize':[0.4216,0.1532,0.5434,0.6843,0.8531]},
                        index=[63,64,65,66,67])

seedlings_data3 = pd.concat([seedlings_data2, newrows2])

#Appending a dataframe column
newcols = pd.DataFrame({'daylight': range(490,558)})

seedlings_data4 = pd.concat([seedlings_data3, newcols], axis=1)

seedlings_data4.head()

#See here for more details http://pandas.pydata.org/pandas-docs/stable/merging.html

#===========================
# Creating dummy variables
#===========================

dummy_levs = pd.get_dummies(seedlings_data4['cohort'], prefix='cohort')

dummy_levs.head()

seedlings_data5 = seedlings_data4.join(dummy_levs)


#################################################
#===============Dates and Times=================#
# Provides a brief introduction to date-time	#
# objects in R. Columns containing dates and	#
# times are read in as if they are objects.		#
#################################################

afib_data = pd.read_table('afib_data.txt')
afib_data.dtypes

afib_data['admitted_dt_tm'] = pd.to_datetime(afib_data['admitted_dt_tm'])
afib_data.admitted_dt_tm.head()

#############################################
#=============Read in Libraries=============#
# Read in the necessary libraries.          #
#############################################

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os

#For QQ Plot
import scipy.stats as sts

#Correlation p-values
from scipy.stats.stats import pearsonr

#Regression output
from sklearn.linear_model import LinearRegression
import statsmodels.formula.api as smf


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

ozone_data = pd.read_table('ozone.data.txt')
ozone_data.columns

ozone_data.dtypes

stdt_data = pd.read_table('class_performance.txt')
stdt_data.columns

stdt_data.dtypes


#################################################
#=============Descriptive Analysis==============#
# This section is used to assess the variance 	#
# inflation factor, standard deviations, and 	#
# means for each variable.                      #
#################################################

######################################################################
#### Obtain the Means, Standard Deviations, etc. for the data.	
######################################################################

#### Boxplot Variables
ozone_data.boxplot()

#### Radiation (IV)
ozone_data.rad.describe()					        #Obtain descriptives
ozone_data.rad.plot()                               #Index plot
ozone_data.plot.scatter(x='rad', y='ozone')         #Check for linearity

#### Temperature (IV)
ozone_data.temp.describe()					        #Obtain descriptives
ozone_data.temp.plot()                              #Index plot
ozone_data.plot.scatter(x='temp', y='ozone')        #Check for linearity

#### Wind (IV)
ozone_data.wind.describe()
ozone_data.wind.plot()
ozone_data.plot.scatter(x='wind', y='ozone')

#### Ozone Concentration (DV)
ozone_data.ozone.describe()					        #Obtain descriptives


#################################################
#==============Correlation Analysis=============#
# Create a new dataset that only contains the	#
# variables for your final regression model.	#
#################################################

#### All columns within a dataframe, no p-values
ozone_data.corr()

#### A single correlation, with p-values
pearsonr(ozone_data.rad, ozone_data.ozone)

pearsonr(ozone_data.wind, ozone_data.ozone)

pearsonr(ozone_data.temp, ozone_data.ozone)


#################################################
#==============Regression Analysis==============#
# Create the regression equations to be used to	#
# obtain the VIF for the models. Also, you can 	#
# obtain the predicted values and residuals 	#
# from the regression model to assess constant 	#
# variance.							            #
#################################################

linreg1 = LinearRegression(fit_intercept=True, normalize=True)
linreg1.fit(ozone_data[['rad','wind','temp']],ozone_data.ozone)

#Calculate R-square
rsquare = linreg1.score(ozone_data[['rad','wind','temp']],ozone_data.ozone)

#Nicely formatted output
print('COEFFICIENTS\n',
      'rad: ', linreg1.coef_[0],
      '\nwind: ', linreg1.coef_[1],
      '\ntemp: ', linreg1.coef_[2],
      '\ninterc: ', linreg1.intercept_,
      '\nR-Square: ', rsquare)

#Output coefficients in raw format
linreg1.coef_

#Output just the intercept
linreg1.intercept_

#======================================
# Does not have function to calculate
# VIF scores. Here is the math for
# each variable
#======================================

#Calculate VIF for Radiation
linreg1.fit(ozone_data[['wind','temp']],ozone_data.rad)
vif1 = 1/(1 - linreg1.score(ozone_data[['wind','temp']],ozone_data.rad))

#Calculate VIF for Wind
linreg1.fit(ozone_data[['rad','temp']],ozone_data.wind)
vif2 = 1/(1 - linreg1.score(ozone_data[['rad','temp']],ozone_data.wind))

#Calculate VIF for Temperature
linreg1.fit(ozone_data[['rad','wind']],ozone_data.temp)
vif3 = 1/(1 - linreg1.score(ozone_data[['rad','wind']],ozone_data.temp))

#Output VIF scores
print('VIF rad: ', vif1,
        '\nVIF wind: ', vif2,
        '\nVIF temp: ', vif3)

#===============================================
# This code is simpler and provides everything
# in the output. This also includes the 
# Durbin-Watson Test for Independence.
# Does not have VIF calculations!
#===============================================

linreg2 = smf.ols('ozone ~ rad + wind + temp', ozone_data).fit()

linreg2.summary()

#Assess homoscedasticity
plt.scatter(linreg2.fittedvalues, linreg2.resid)
plt.xlabel('Predicted/Fitted Values')
plt.ylabel('Residual Values')
plt.title('Assessing Homoscedasticity')
plt.plot([-40, 120],[0, 0], 'red', lw=2)   #Add horizontal line
plt.show()

#QQ plot for normality
sts.probplot(linreg2.resid, dist="norm", plot=plt)

#Leverage Plot if you need it
from statsmodels.graphics.regressionplots import *
plot_leverage_resid2(linreg2)


#########################################################
#==================Logistic Regression==================#
# Perform a binomial logistic regression on	student     #
# data. Convert target variable to binary 0s and 1s.    #
#########################################################

stdt_data.Grade.replace(['A','B'],[0,1], inplace=True)

logreg1 = smf.logit('Grade ~ Project*Exam', stdt_data).fit()

logreg1.summary()

#Remove the product
logreg2 = smf.logit('Grade ~ Project + Exam', stdt_data).fit()

logreg2.summary()
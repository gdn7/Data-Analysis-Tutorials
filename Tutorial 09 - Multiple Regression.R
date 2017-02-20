###########################################
#============Read in Libraries============#
# Read in the necessary libraries. Note,	#
# the commented code for installing		#
# packages. Remove the "#" and run the	#
# script to install them. You must be	#
# connected to the internet to download	#
# them.						#
###########################################

#install.packages("psych")
#install.packages("ggplot2")
#install.packages("Hmisc")
#install.packages("fmsb")
#install.packages("car")

#library(foreign)
library(psych)
library(ggplot2)
library(Hmisc)	#Only load this after using psych; it overrides psych
library(car)	#Used for Durbin-Watson test and VIF scores
#library(fmsb)	#Alternative to calculate the VIF scores

#######################################################
#=============Setup the Working Directory=============#
#Set the working directory to the project folder by 	#
#running the appropriate script below. Note, you can 	#
#run the data off of your OneDrive or DropBox.		#
#######################################################

workingdirectory = "C:\\Users\\bryan\\OneDrive - Oklahoma State University\\Teaching\\MSIS 5223\\In-Class Exercises\Data"
setwd(workingdirectory)


###########################################
#==============Read in data===============#
#Read in the data for both data sets.	#
###########################################

#This loads the Ozone data
temptable = paste(workingdirectory, "\\ozone.data.txt", sep="")
ozone_data = read.table(temptable, header=T, sep="\t")

#Use this function to open a GUI to edit the table
ozone_data = edit(ozone_data)

#Ensure the names are correct
names(ozone_data)

summary(ozone_data)			#Basic summary
str(ozone_data)				#Look at structure of data

#### student performance data for logistic regression
stdt_data = read.table("C:\\Users\\bryan\\OneDrive - Oklahoma State University\\Teaching\\MSIS 5223\\In-Class Exercises\\Data\\class_performance.txt",sep="\t",header=T)


#################################################
#=============Descriptive Analysis==============#
# This section is used to assess the variance 	#
# inflation factor, standard deviations, and 	#
# means for each variable. Also, the 		#
# significance of the correlations is obtained.	#
# Place any other descriptive statistics here	#
# within this section. Be sure to add comments.	#
#################################################

######################################################################
#### Obtain the Means, Standard Deviations, etc. for the data.	
#### You must first install the "pysch" package before proceeding.
######################################################################

#### Radiation (IV)
describe(ozone_data$rad)					#Obtain descriptives
sprintf("%.3f", describe(ozone_data$rad))			#Round to 3 decimal places
plot(ozone_data$rad)						#Index plot; x-axis is the order number the data point appears
plot(ozone_data$rad, ozone_data$ozone)			#Check for linearity
boxplot(ozone_data$rad

#### Temperature (IV)
describe(ozone_data$temp)					#Obtain descriptives
sprintf("%.3f", describe(ozone_data$temp))		#Round to 3 decimal places
boxplot(ozone_data$temp)

#### Wind (IV)
describe(ozone_data$wind)
sprintf("%.3f", describe(ozone_data$wind))
boxplot(ozone_data$wind)

#### Ozone Concentration (DV)
describe(ozone_data$ozone)
sprintf("%.3f", describe(ozone_data$ozone))
boxplot(ozone_data$ozone)

#### Create scatter plots to assess linearity
#### Look at the row with the DV, ozone
pairs(ozone_data, panel=panel.smooth)


#################################################
#==============Correlation Analysis=============#
# Create a new dataset that only contains the	#
# variables for your final regression model.	#
# Pass that new dataset into the cor()		#
# function below.						#
#################################################

ozone_corr = cor(ozone_data)			#pearson correlation
ozone_corr						#show correlations; this doesn't round the correlation values

#### What about significance of the correlations? 
#### This shows the correlation values (rounded) and their associated p-values
rcorr(as.matrix(ozone_data))


#################################################
#==============Regression Analysis==============#
# Create the regression equations to be used to	#
# obtain the VIF for the models. Also, you can 	#
# obtain the predicted values and residuals 	#
# from the regression model to assess constant 	#
# variance.							#
#################################################

#### Signif. Codes: 0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

ozone_reg = lm(ozone_data$ozone~ozone_data$rad+ozone_data$wind+ozone_data$temp)
summary(ozone_reg)
#### Results:
#                 Estimate Std. Error t value Pr(>|t|)    
#(Intercept)     -63.70036   23.06231  -2.762  0.00676 ** 
#ozone_data$rad    0.06008    0.02316   2.594  0.01082 *  
#ozone_data$wind  -3.35156    0.65405  -5.124 1.33e-06 ***
#ozone_data$temp   1.64576    0.25355   6.491 2.74e-09 ***
#
#Residual standard error: 21.16 on 107 degrees of freedom
#Multiple R-squared:  0.6068,    Adjusted R-squared:  0.5958 
#F-statistic: 55.04 on 3 and 107 DF,  p-value: < 2.2e-16

#Calculate vif using library car
vif(ozone_reg)

#Using the library fmsb for vif
#This is much more tedious than the
#previous function
VIF(lm(ozone_data$rad~ozone_data$wind+ozone_data$temp))
VIF(lm(ozone_data$wind~ozone_data$rad+ozone_data$temp))
VIF(lm(ozone_data$temp~ozone_data$rad+ozone_data$wind))

#Test Independence Assumption
durbinWatsonTest(ozone_reg)

plot(ozone_reg)		#Hit "Enter" to move through the 4 plots
#### Results: 
#### The Residual-Predicted Plot (i.e. Residual vs. Fitted) shows
#### heteroscadasticity; not good!
#### It appears the model is not normal (QQ Plot); it has a slight curve
#### to the upper-right. Perhaps we should log-transform the DV?


ozone_reg2 = lm(log(ozone_data$ozone)~ozone_data$rad+ozone_data$wind+ozone_data$temp)
summary(ozone_reg2)

#Calculate vif
vif(ozone_reg2)

#Test Independence Assumption
durbinWatsonTest(ozone_reg2)

plot(ozone_reg2)
#### Results: Normality is not as much of an issue. However, Cook's Plot
#### (the 3rd plot) shows data point 17 to be highly influential. Gasp!

ozone_reg3 = lm(log(ozone_data$ozone)~ozone_data$rad+ozone_data$wind+ozone_data$temp, subset=(1:length(ozone_data$ozone)!=17))
summary(ozone_reg3)

#Calculate vif
vif(ozone_reg3)

#Test Independence Assumption
durbinWatsonTest(ozone_reg3)

plot(ozone_reg3)

#### How does this compare to a stepwise process?
ozone_step_reg = step(ozone_reg)
summary(ozone_step_reg)


#############################################################################
#### This calculates the centered variance inflation factor.
#### This is a function I have written myself to demonstrate the
#### capabilities R possesses.
#### I have tested my function's accuracy using five different data sets
#### and compared the results to SPSS; I found no differences.
#### The function requires a regression object passed in. If your
#### regression object is called "regress_obj" then you would type
#### vif.lm(regress_obj).
#### At the time I created this function, R did not have a library that
#### provided the vif calculations; so, I built this myself.

#### Run this script below
vif <- function(object, ...)
UseMethod("vif")
vif.default <- function(object, ...)
stop("No default method for vif. Sorry.")

vif.lm <- function(object, ...) {
	V = summary(object)$cov.unscaled
	Vi = crossprod(model.matrix(object))
	nam = names(coef(object))
	k = match("(Intercept)", nam,nomatch = FALSE)

	if(k) {
		v1 = diag(V)[-k]
		v2 = diag(Vi)[-k] - Vi[k, -k]^2 / Vi[k, k]
		nam = nam[-k]
	}
	else {
		v1 = diag(V)
		v2 = diag(Vi)
		warning(paste("No intercept term","detected. Results may surprise."))
	}

	structure(v1 * v2, names = nam)
}

#### This is a template for using the vif() function
#### You can copy the results and list them below if desired.
#### Do this for each of the regression models you built.

vif.lm(ozone_reg)
#### Results:
#VarName	VIF
#rad		1.10
#wind		1.33
#temp		1.43


#### For more information, please read Chapter 10 in The R Book
#### by Michael J. Crawley.


#################################################
#==============Logistic Regression==============#
# Perform a binomial logistic regression on	#
# student data
#################################################

names(stdt_data)
describe(stdt_data)

#### Perform logistic regression using Project as
#### a predictor of Grade
stdt_reg1 = glm(Grade~Project*Exam, binomial, data=stdt_data)
summary(stdt_reg1)
anova(stdt_reg1, test="Chisq")

stdt_reg2 = glm(Grade~Project+Exam, binomial, data=stdt_data)
summary(stdt_reg2)

#### For more information, please read Chapter 16 on Proportion Data
#### in The R Book by Michael J. Crawley.
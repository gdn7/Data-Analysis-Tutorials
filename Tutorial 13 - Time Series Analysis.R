#############################################
#=============Read in Libraries=============#
# Read in the necessary libraries. Note,    #
# the commented code for installing		    #
# packages. Remove the "#" and run the	    #
# script to install them. You must be	    #
# connected to the internet to download	    #
# them.						                #
#############################################

options(digits=4)   #Useability by way of rounding
library(forecast)


#########################################################
#==============Setup the Working Directory==============#
# Set the working directory to the project folder by    #
# running the appropriate script below. Note, you can 	#
# run the data off of your OneDrive or DropBox.		    #
#########################################################

workingdirectory = "C:\\Users\\bryan\\OneDrive - Oklahoma State University\\Teaching\\MSIS 5223\\In-Class Exercises\\TimeSeriesData"
setwd(workingdirectory)


#############################################
#===============Read in data================#
# Read in the data.	                        #
#############################################

# International passenger bookings (in thousands) per month on Pan Am
# from 1949 - 1960 (Brown, 1963)
data(AirPassengers)

airp_ts = AirPassengers

airp_ts

class(airp_ts)    #time series object

#Unemployment data from Maine 1996 to August 2006
temptable = paste(workingdirectory, "\\Maine.dat", sep = "")
maine_data = read.table(temptable, sep = '\t', header = TRUE)

class(maine_data) #dataframe object

#Use an example data set for the tutorial
exampledata = c(15, 28, 25, 34, 53, 42, 45, 48, 56, 34, 28, 36, 43, 45)
example_ts = ts(exampledata) #convert to time series object

#Seasonal data
season_data = c(45, 335, 520, 100, 70, 370, 590, 170, 100, 585, 830, 285, 100, 725, 1160, 215)
season_ts = ts(season_data, frequency = 4, start = c(1992, 1))

season_ts

#NYC Birth Data
nycbirths_data = read.table('NYC_births.txt', sep = '\t', header = TRUE)
births_ts = ts(nycbirths_data, frequency = 12, start = c(1946, 1))

births_ts

#monthly sales for a souvenir shop at a beach resort town in Queensland, Australia
#January 1987 - December 1993 (Wheelwright & Hyndman, 1998)
temptable = paste(workingdirectory, "\\souvenir_data.txt", sep = "")
souv_data = read.table(temptable, sep = '\t', header = TRUE)
souv_ts = ts(souv_data, frequency = 12, start = c(1987, 1))

#Multiplicative model
plot(souv_ts)

#Convert to additive model
souv_ts_log = log(souv_ts)

plot(souv_ts_log)


#################################################
#=============Descriptive Analysis==============#
# This section is used to assess the structure  #
# of the data and what type of time series is   #
# being used.                                   #
#################################################

start(airp_ts)
end(airp_ts)
frequency(airp_ts)

plot(airp_ts,  ylab="Passengers (1000's)")
#### Possesses a linear trend that is increasing over time
#### Seasonal variation is apparent from year to year with
#### summer months the highest and winter months the lowest

#===================================================================
# To improve the view of the trend, the seasonality can be
# removed by aggregating the data annually using aggregate().
# To get the seasonal variation, use a boxplot. Note, the
# aggregation works because the time series data is already
# organized by year. If each record in the time series was a month
# then the aggregate() function would aggregate by month, not year.
# In the boxplot, the numbers on the x-axis refer to a month.
#===================================================================
layout(1:2)
plot(aggregate(airp_ts))
boxplot(airp_ts ~ cycle(airp_ts))

airp_ts_dc = decompose(airp_ts)

# Compare standard deviations to see if seasonal effect does exist
sd(airp_ts)

sd(airp_ts - airp_ts_dc$seasonal)
#### Result: Yes, the standard deviations are not similar

# Converting dataframe to time series object
# freq argument specifies how many records are within each year
# 12 months per year, starting with the year 1996
maine_month_ts = ts(maine_data$unemploy, start = c(1996, 1), freq = 12)

#Force it to quarterly data; the original isn't, but we can force it
maine_month_ts2 = ts(maine_data$unemploy, start = c(1996, 1), freq = 4)

maine_year_ts = aggregate(maine_month_ts)
maine_year_mean_ts = aggregate(maine_month_ts) / 12    #average value

layout(1:3)
plot(maine_month_ts, ylab = 'unemployed (%)')
plot(maine_year_ts, ylab = 'unemployed (%)')
plot(maine_year_mean_ts, ylab='unemployed (%)')

layout(1)   #return layout back to single plot


#############################################
#===========Time Series Analysis============#
# Look at horizontal data:                  #
#   -Simple Moving Average                  #
#   -Exponential Smoothing                  #
# Assess some trend-based data:             #
#   -Trend-Adjusted Exponential Smoothing   #
# 
#############################################

#========================
# Simple Moving Average
#========================
example_ma = ma(example_ts, order = 2, centre = FALSE)

example_ma

example_ma2 = ma(example_ts, order = 4, centre = FALSE)

plot(example_ts)
lines(example_ma, col = 'red')
lines(example_ma2, col = 'green')

#========================
# Exponential Smoothing
#========================
example_es = HoltWinters(example_ts, beta = FALSE, gamma = FALSE, alpha = 0.3)

#Predicted values
example_es$fitted

example_es2 = HoltWinters(example_ts, beta = FALSE, gamma = FALSE, alpha = 0.7)

layout(1:2)
plot(example_es, main='alpha = 0.3')
plot(example_es2, main='alpha = 0.7')

#Obtain estimate of alpha; do not provide a value for alpha
example_es3 = HoltWinters(example_ts, beta = FALSE, gamma = FALSE)

plot(example_es3)

#Forecast the model beyond the known range of data
example_es3_fore = forecast.HoltWinters(example_es3, h = 8)

#Forecasts with 80% and 95% intervals
example_es3_fore

#Look at forecasted values
plot(example_es3_fore)

#Assess constant variance
plot(example_es3_fore$residuals)
lines(c(0, 14), c(0, 0), col = 'red')

plotForecastErrors = function(forecasterrors,forecasttitle) {
    #Function provided by Avril Coghlan
    forecasterrors = na.omit(forecasterrors)
    # make a histogram of the forecast errors:
    mybinsize = IQR(forecasterrors) / 4
    mysd = sd(forecasterrors)
    mymin = min(forecasterrors) - mysd * 5
    mymax = max(forecasterrors) + mysd * 3
    # generate normally distributed data with mean 0 and standard deviation mysd
    mynorm <- rnorm(10000, mean = 0, sd = mysd)
    mymin2 <- min(mynorm)
    mymax2 <- max(mynorm)
    if (mymin2 < mymin) { mymin <- mymin2 }
    if (mymax2 > mymax) { mymax <- mymax2 }
    # make a red histogram of the forecast errors, with the normally distributed data overlaid:
    mybins <- seq(mymin, mymax, mybinsize)
    hist(forecasterrors, col = "red", freq = FALSE, breaks = mybins, main=forecasttitle)
    # freq=FALSE ensures the area under the histogram = 1
    # generate normally distributed data with mean 0 and standard deviation mysd
    myhist <- hist(mynorm, plot = FALSE, breaks = mybins)
    # plot the normal curve as a blue line on top of the histogram of forecast errors:
    points(myhist$mids, myhist$density, type = "l", col = "blue", lwd = 2)
}

#Assess normality of residuals
plotForecastErrors(example_es3_fore$residuals,'Assessing Normal Distribution')

#==============================
# Trend Exponential Smoothing
#==============================
example_es4 = HoltWinters(example_ts, 
                            alpha = 0.2, 
                            beta = 0.4, 
                            gamma = FALSE, 
                            l.start = 17.6, 
                            b.start = 1.04)

example_es4$fitted

example_es5 = HoltWinters(example_ts,
                            alpha = 0.2,
                            beta = 0.8,
                            gamma = FALSE,
                            l.start = 17.6,
                            b.start = 1.04)

example_es6 = HoltWinters(example_ts,
                            alpha = 0.7,
                            beta = 0.4,
                            gamma = FALSE,
                            l.start = 17.6,
                            b.start = 1.04)

example_es7 = HoltWinters(example_ts,
                            alpha = 0.7,
                            beta = 0.8,
                            gamma = FALSE,
                            l.start = 17.6,
                            b.start = 1.04)

par(mfrow = c(2, 2))
plot(example_es4, main='a=0.2, b=0.4')
plot(example_es5, main='a=0.2, b=0.8')
plot(example_es6, main='a=0.7, b=0.4')
plot(example_es7, main = 'a=0.7, b=0.8')

par(mfrow = c(1, 1))

#Allow the model to determine alpha and beta
example_es8 = HoltWinters(example_ts,
                            gamma = FALSE,
                            l.start = 17.6,
                            b.start = 1.04)

example_es8

#Create a new time series object ending at Period 9
#This is where the first trend ends
example_ts2 = ts(exampledata, start = 1, end = 9)

example_es9 = HoltWinters(example_ts2,
                            gamma = FALSE,
                            l.start = 17.6,
                            b.start = 1.04)

example_es9

plot(example_es9)

example_es9_fore = forecast.HoltWinters(example_es9, h = 8)

plot(example_es9_fore)

#Assess constant variance
plot(example_es9_fore$residuals)
lines(c(3, 14), c(0, 0), col = 'red')

#Assess normal distribution
plotForecastErrors(example_es9_fore$residuals, 'Assessing Normal Distribution')

#=====================================
# Holt-Winters Exponential Smoothing
#=====================================
#New York City birth data
plot(births_ts)

births_ts_dc = decompose(births_ts)

plot(births_ts_dc)

#Remove season to use Trend-Adjusted Exponential Smoothing
births_ts_trend = births_ts - births_ts_dc$seasonal

births_es = HoltWinters(births_ts_trend,
                        gamma = FALSE)

births_es
plot(births_es)

#Leave season in the model
births_es2 = HoltWinters(births_ts,
                        gamma = FALSE)

#Forecast the next 8 periods for both
births_es_fore = forecast.HoltWinters(births_es, h = 8)

plot(births_es_fore)

births_es_fore2 = forecast.HoltWinters(births_es2, h = 8)

#Assess constant variance
par(mfrow = c(2, 1))
plot(births_es_fore$residuals, main='NYC Births: No Seasonal Component')
lines(c(1946, 1960), c(0, 0), col = 'red')

plot(births_es_fore2$residuals, main='NYC Births: With Seasonal Component')
lines(c(1946, 1960), c(0, 0), col = 'red')

#Assess normal distribution
plotForecastErrors(births_es_fore$residuals,'NYC Births: No Seasonal Component')

plotForecastErrors(births_es_fore2$residuals, 'NYC Births: With Seasonal Component')

#### Result: By removing season, the model fits better for
#### Trend-Adjusted Exponential Smoothing
#### Information is lost; conduct a Holt-Winters model instead.

#NYC Birth data in a Holt-Winters model
par(mfrow = c(1, 1))
births_es3 = HoltWinters(births_ts)

births_es3
plot(births_es3)

births_es3_fore = forecast.HoltWinters(births_es3, h = 40)

plot(births_es3_fore, main='Forecast for 40 Periods')

#Autocorrelation assessment
Box.test(births_es3_fore$residuals, lag = 20, type = "Ljung-Box")

acf(na.omit(births_es3_fore$residuals))
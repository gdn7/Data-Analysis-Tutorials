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
#install.packages("tree")
#install.packages("Hmisc")

#library(foreign)
#library(psych)
#library(ggplot2)
library(tree)
#library(Hmisc)

#######################################################
#=============Setup the Working Directory=============#
#Set the working directory to the project folder by 	#
#running the appropriate script below. Note, you can 	#
#run the data off of your OneDrive or DropBox.		#
#######################################################

#My PC
workingdirectory = "C:\\Users\\Bryan\\OneDrive - Oklahoma State University\\Teaching\\MSIS 5223\\In-Class Exercises\Data"
setwd(workingdirectory)


###########################################
#==============Read in data===============#
#Read in the data for tree analysis.	#
###########################################

#This loads the Pollution data; it is tab-delimited
temptable = paste(workingdirectory, "\\Pollute.txt", sep="")
pollute_data = read.table(temptable, header=T, sep="\t")

#Load the epilobium data
temptable = paste(workingdirectory, "\\epilobium.txt", sep="")
epi_data = read.table(temptable, header=T, sep="\t")

#Ensure the names are correct
names(pollute_data)
names(epi_data)

summary(pollute_data)			#Basic summary
str(pollute_data)				#Look at structure of data


#################################################
#=================Tree Analysis=================#
# Use a basic tree function to demonstrate.	#
# Pollution is a continuous variable, so this	#
# tree is a regression tree.				#
# Pollution (SO2 concentration) is the target	#
# variable.							#
#################################################

#### This tree function uses binary recursive partitioning
#### Deviance is the default, but you can use Gini Index
#### The first column in your data is assumed to be the
#### target variable
pollute_tree = tree(pollute_data)

#### Text-based tree; terminal nodes designated by *.
#### yval is the mean value of the DV within that node or leaf
pollute_tree					
#### Result: Industry is the first split; the split is Industry < 748

#================================================================
# Explain splitting using Deviance; use Industry as an example.
#================================================================
low = (pollute_data$Industry<748)			#use the first split value of 748
tapply(pollute_data$Pollution, low, mean)
plot(pollute_data$Industry, pollute_data$Pollution, pch=16)

#### Each IV is assessed by determining how much deviance in the 
#### DV is explained. In this case, Industry explains the most for
#### Pollution. The Deviance is based on a threshold value for
#### each IV; it produces two mean values: 1 above the threshold,
#### and one below.
#### The value 748 (the vertical line in the below plot) is the 
#### chosen threshold value of Industry based on deviance:
abline(v=748, lty=2)

#### The mean values for the two groups is shown via the two 
#### horizontal lines:
lines(c(0,748), c(24.92, 24.92))				#Low-end mean
lines(c(748,max(pollute_data$Industry)), c(67,67))	#High-end mean

#### Both of these mean values are used to calculate the deviance. The
#### algorithm iterates through all x-values of Industry as the
#### threshold; a mean below and above the split is calculated.
#### For each threshold, the x value with the lowest deviance
#### is chosen. The data set is then split based on this threshold
#### value. The program then runs through the other IVs for each
#### of the new data subsets. This continues until further deviance
#### is not possible or there are too few data points (fewer than 6 
#### cases is default; see right-side of plot).

#### Plotting it makes a visual representation
plot(pollute_tree)					#plot the tree structure
text(pollute_tree)					#attach text to tree plot

#### Interpretation:
#### Industry: Industry values 748 or greater lead to pollution
#### problems (67.0!); less than 748, Population explains what
#### occurs. Low populations have a high mean of 43.43! For high
#### levels of population, the number of wet days is a key factor.

#### The tree above has 6 terminal nodes. Is this optimal?
#### Prune the tree to simplify it.
pollute_prune_tree = prune.tree(pollute_tree)
pollute_prune_tree
#### Results: 
#$size
#[1] 6 5 4 3 2 1
# Shows 6 different models with the number of terminal nodes within each
#$dev
#[1]  8876.589  9240.484 10019.992 11284.887 14262.750 22037.902
# Total deviance of each tree
#$k
#[1]      -Inf  363.8942  779.5085 1264.8946 2977.8633 7775.1524
# Cost-complexity calculation; the third has the lowest cost

plot(pollute_prune_tree)
#### Results: As complexity increases, deviance decreases
#### You only want variables that explain a lot of deviance
#### and after 3 the gain in the explanation is minimal

#### Go with 3 nodes based on plot
#### Use the attribute best=3 to select the best tree
#### using 3 terminal nodes
pollute_prune_tree2 = prune.tree(pollute_tree, best=3)
pollute_prune_tree2

plot(pollute_prune_tree2)
text(pollute_prune_tree2)

#### Now you can build a regression model based on these 2 variables!


#################################################
#=================Tree Analysis=================#
# Use a basic tree function to demonstrate.	#
# This tree is a classification tree using	#
# categorical independent variables.		#
#################################################

#Note the number of species in the data:
edit(epi_data)
epi_data$species

#### This dataset contains various plant flora and fauna. We want
#### to create a key to classify these plants. There is only one
#### entry per species for a total of 9; thus, we want each
#### row to have its own node.

#==================================================================
# To produce a tree that fits the data perfectly, set mindev = 0 
# and minsize = 2, if the limit on tree depth allows such a tree.
# Ideally, the minimum deviance should be 0, but that leads
# to problems; give it a value as close to 0 as possible, such as
# 10^-6. Create a regression within the function.
#==================================================================
epi_tree = tree(species~., epi_data, mindev=1e-6, minsize=2)
epi_tree

plot(epi_tree)
text(epi_tree)


#### For more information, please read Chapter 23 in The R Book (2nd Edition)
#### or Chapter 21 in The R Book (1st Edition)
#### by Michael J. Crawley.
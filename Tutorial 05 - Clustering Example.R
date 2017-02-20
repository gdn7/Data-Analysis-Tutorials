###########################################
#============Read in Libraries============#
# Read in the necessary libraries.		#
###########################################

library(tree)


#######################################################
#=============Setup the Working Directory=============#
#Set the working directory to the project folder by 	#
#running the appropriate script below. Note, you can 	#
#run the data off of your OneDrive or DropBox.		#
#######################################################

workingdirectory = "C:\\Users\\bryan\\OneDrive - Oklahoma State University\\Teaching\\MSIS 5223\\In-Class Exercises"
setwd(workingdirectory)


###########################################
#==============Read in data===============#
#Read in the data for tree analysis.	#
###########################################

#This loads the example kmeans data; it is tab-delimited
temptable = paste(workingdirectory, "\\kmeansdata.txt", sep="")
kmeans_data = read.table(temptable, header=T, sep="\t")

summary(kmeans_data)
str(kmeans_data)

#Load the Taxonomy data of 120 plants
temptable = paste(workingdirectory, "\\taxon.txt", sep="")
taxon_data = read.table(temptable, header=T)

summary(taxon_data)
str(taxon_data)

#Load the Experimental Plant Plot data file
temptable = paste(workingdirectory, "\\pgfull.txt", sep="")
pg_data = read.table(temptable, header=T)
pg_labels = paste(pg_data$plot, letters[pg_data$lime], sep="")

summary(pg_data)
str(pg_data)


#################################################
#============Partitioning Analysis==============#
# Partition the data based on K-Means.		#
#################################################

#### Allow the R Graphics window to display 4 graphics
#### with 2 on top and 2 on the bottom:
par(mfrow=c(2,2))

#### Look at the data without using a cluster algorithm;
#### This data contains 6 natural groups: A, B, C, D, E, and F;
####
#### pch argument in plot is the type of symbol used; 
#### see http://www.endmemo.com/program/R/pchsymbols.php
plot(kmeans_data$x, kmeans_data$y, pch=18)

#### Add color based on the "grouping" variable
plot(kmeans_data$x, kmeans_data$y, pch=18, col=kmeans_data$grouping, main="Grouping Var.")

#### Now, let us use the K-Means algorithm to plot the data.
#### Restrict the data to 6 distinct groups
km = kmeans(data.frame(kmeans_data$x, kmeans_data$y), 6)
plot(kmeans_data$x, kmeans_data$y, col=km[[1]], main="6 KM Groups")

#### Restrict it based on using 4 groups instead of 6
km2 = kmeans(data.frame(kmeans_data$x, kmeans_data$y), 4)
plot(kmeans_data$x, kmeans_data$y, col=km2[[1]], main="4 KM Groups")

#### Reset the number of figures to display to just 1
par(mfrow=c(1,1))

#### Assess the misclassification for groups A, B, C, D, E, F for 6 groups
table(km[[1]], kmeans_data$grouping)
#### Results: Groups A, C, and F were perfect; B, D, E were not


#################################################
#============Partitioning Analysis==============#
# Another example using the K-Means algorightm.	#
# A case in which a tree might be better.		#
# Use clustering to determine which variables	#
# would provide the best grouping for taxonomic	#
# purposes.							#
#################################################

#### Observe which variables appear to have natural separation
pairs(taxon_data)

#==============================================================
# Which of the variables are the most useful for taxonomic 
# characterization? Using K-Means, assess which groups each
# observation is put into. 
# N = 120 observations.
#==============================================================

km_tax = kmeans(taxon_data, 4)
km_tax

#==============================================================
# The data itself is sorted so that the first 30 observations
# belong to taxon I, the next 30 taxon II, etc.
# Start out with 4 possible groupings:
# Results: Not a very good job. Look at the first 30; the
# observations are placed in clusters 2, 3, and 4! This
# should be just one!
# Let's try out 3, instead of 4:
#==============================================================
 
kmeans(taxon_data, 3)

#==========================================================
# Results: That is a little cleaner. Except we know there
# are 4 taxons. Perhaps we should use a tree.
#==========================================================

#### Read in the full data file for Taxonomy
temptable = paste(workingdirectory, "\\taxonomy.txt", sep="")
taxonomy_data = read.table(temptable, header=T)

taxon_tree = tree(taxonomy_data$Taxon~., taxonomy_data)
plot(taxon_tree)
text(taxon_tree)
taxon_tree

#### Try this again with just the three variables Sepal, Leaf, and Petiole
kmeans(data.frame(taxon_data$Sepal, taxon_data$Leaf, taxon_data$Petiole), 4)
#### Results: It actually works!


#################################################
#============Agglomerative Analysis=============#
# Here is a simple example of Hierarchical	#
# Agglomerative analysis.				#
#################################################

summary(pg_data)
ncol(pg_data)			#59 columns of data!

#### First, calculate the euclidean distances for all of the 
#### rows and columns. Note, only do this for the first 54
#### columns; the other 5 (plot, lime, species, hay, pH) are
#### not considered for this.
pg_dist = dist(pg_data[,1:54])
pg_clust = hclust(pg_dist)
plot(pg_clust, labels=pg_labels, main="Agglomerative Clustering")

#### How about on the Taxonomic data?
plot(hclust(dist(taxon_data)), main="Taxonomy Cluster Analysis")
#### Results: Still not very good :'(


#### For more information, please read Chapter 23 in The R Book
#### by Michael J. Crawley.
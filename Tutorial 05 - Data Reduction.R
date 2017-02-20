#######################################################
#=============Setup the Working Directory=============#
#Set the working directory to the project folder by 	#
#running the appropriate script below. Note, you can 	#
#run the data off of your OneDrive or DropBox.		#
#######################################################

setwd("C:\\Users\\bryan\\OneDrive - Oklahoma State University\\Teaching\\MSIS 5223\\Tutorials")


###########################################
#==============Read in data===============#
#Read in the data for both data sets.	#
###########################################

#==========================================
# Read in the data sample for technology
# adoption research project
#==========================================

reduction_data = read.table("C:\\Users\\bryan\\OneDrive - Oklahoma State University\\Teaching\\MSIS 5223\\In-Class Exercises\\Data\\datareduction.csv", header=T, sep=",")

#Remove columns from the dataset
reduction_data = subset(reduction_data, select=-c(Q32,Q175:Q179_1))

#Rename columns
colnames(reduction_data) = c("time","peruse01","peruse02","peruse03","peruse04","peruse05","peruse06","pereou01","pereou02","pereou03","pereou04","pereou05","pereou06",
"intent01","intent02","intent03","operatingsys","gender","educ_level","race_white","race_black","race_hisp","race_asian","race_native","race_pacif","race_other",
"age","citizenship","state","military","militbranch","familystruct","children","income","employ","color","eatout","religion")

names(reduction_data)

#Alternative Data
reduc_data = read.table("C:\\Users\\bryan\\OneDrive - Oklahoma State University\\Teaching\\MSIS 5223\\In-Class Exercises\\Data\\reduction_data_new.txt", header=T, sep="\t")
names(reduc_data)

#################################################
#==========Principal Component Analysis=========#
# Perform a PCA for PU, PEOU, and Intention;	#
# Best used for testing a new model using new	#
# theory; for established models, use Factor	#
# Analysis (see below).					#
# Assessment is based on the full variance in	#
# the data; Factor Analysis is based on the	#
# shared variance.					#
#################################################

#### Create dataframe with only Perceived Usefulness variables
reduction_data.pca = reduction_data[c("peruse01","peruse02","peruse03","peruse04","peruse05","peruse06")]

pcamodel_reduc = princomp(reduction_data.pca,cor=TRUE)		#save PCA model with loadings
pcamodel_reduc$sdev^2								#Only one component has an eigenvalue greater than 1.0

plot(pcamodel_reduc,main="Perceived Usefuleness Scree Plot")							#screeplot
biplot(pcamodel_reduc)								#biplot of PCA model; numbers are rows in data
#### Result: Screeplot indicates one component; Biplot shows the items are evenly distributed
#### Decision: 

#### Perceived Ease of Use
reduction_data.pca = reduction_data[c("pereou01","pereou02","pereou03","pereou04","pereou05","pereou06")]

pcamodel_reduc = princomp(reduction_data.pca,cor=TRUE)			#save PCA model with loadings
pcamodel_reduc$sdev^2

plot(pcamodel_reduc,main="Screeplot of PEOU")
biplot(pcamodel_reduc_sona)								#biplot of PCA model
#### Result: Screeplot indicates one component
#### Decision: even spread

#### PU, PEOU, and Intention to Use System
reduction_data.pca = reduction_data[c("peruse01","peruse02","peruse03",
	"peruse04","peruse05","peruse06","pereou01","pereou02","pereou03",
	"pereou04","pereou05","pereou06","intent01","intent02","intent03")]

pcamodel_reduc = princomp(reduction_data.pca,cor=FALSE)
pcamodel_reduc$sdev^2

plot(pcamodel_reduc,main="Screeplot of PU, PEOU, Intention")	#screeplot
biplot(pcamodel_reduc)								#biplot of PCA model
#### Result: 
#### Decision: 


#################################################
#===============ML Factor Analysis==============#
# Perform a varimax rotation for all variables	#
# in the data. Use Factor Analysis for		#
# established models and theory. Assessment is	#
# based on shared variance within the model.	#
#################################################

#### Perceived Usefulness: confirm results of PCA
reduction_data.FA = factanal(~peruse01+peruse02+peruse03+peruse04+peruse05+peruse06,factors=1,rotation="varimax", 
  scores="none",data=reduction_data)					#run the factor analysis with 1 factor as indicated by screeplot
reduction_data.FA						
#### Result: PU5 and PU6 have loadings below 0.8; PU6 has 0.706
#### Decision: just fine

#### Perceived Ease of Use: confirm results of PCA
reduction_data.FA = factanal(~pereou01+pereou02+pereou03+pereou04+pereou05+pereou06,factors=1,rotation="varimax", 
  scores="none",data=reduction_data)					#run the factor analysis with 1 factor as indicated by screeplot
reduction_data.FA						
#### Result: PEOU5 has 0.705 and PEOU has 0.733
#### Decision: 

#### Intention to Use
reduction_data.FA = factanal(~intent01+intent02+intent03,factors=1,rotation="varimax",
scores="none",data=reduction_data)			#one factor solution
reduction_data.FA
#### Result: Good
#### Decision: no change


#================================================================
# Perfom factor analysis with varimax rotation of all IV items
#================================================================
reduction_data.FA = factanal(~peruse01+peruse02+peruse03+peruse04+peruse05+peruse06+pereou01+pereou02+pereou03+pereou04+pereou05+pereou06,
factors=2,rotation="varimax",scores="none",data=reduction_data)			#two factor solution based on previous factor analyses
reduction_data.FA
#### Result: Looks good except PU6 has a loading of 0.682, PEOU4 has 0.676, and PEOU5 has 0.654
#### Decision: 

#==============================================================
# Perfom factor analysis with promax rotation of all IV items
# to check results against the varimax rotation
#==============================================================
reduction_data.FA = factanal(~peruse01+peruse02+peruse03+peruse04+peruse05+peruse06+pereou01+pereou02+pereou03+pereou04+pereou05+pereou06,
factors=2,rotation="promax",scores="none",data=reduction_data)			#two factor solution based on previous results
reduction_data.FA
#### Results: 
#### Decision: 

#==========================================================
# Perfom factor analysis with varimax rotation of all IV
# & all DV items
#==========================================================
reduction_data.FA = factanal(~peruse01+peruse02+peruse03+peruse04+peruse05+peruse06+
	pereou01+pereou02+pereou03+pereou04+pereou05+pereou06+
	intent01+intent02+intent03,
	factors=3,
	rotation="varimax",
	scores="none",
	data=reduction_data)		#three factor solution based on previous factor analyses

reduction_data.FA
#### Result: Looks good except the same items are loading weakly
#### Decision: 

#==========================================================
# Perfom factor analysis with varimax rotation of all IV
# & all DV items
#==========================================================
reduction_data.FA = factanal(~peruse01+peruse02+peruse03+peruse04+peruse05+
	pereou01+pereou02+pereou03+pereou06+
	intent01+intent02+intent03,
	factors=3,
	rotation="varimax",
	scores="none",
	data=reduction_data)		#three factor solution based on previous factor analyses

reduction_data.FA
#### Result: Looks good except the same items are loading weakly
#### Decision: 

reduc_data.FA = factanal(~peruse01+peruse02+peruse03+peruse04+peruse05+
	pereou01+pereou02+pereou03+pereou06+
	intent01+intent02+intent03,
	factors=3,
	rotation="varimax",
	scores="none",
	data=reduc_data)		#three factor solution based on previous factor analyses

reduc_data.FA


#=========================================================
# Perfom factor analysis with promax rotation of all IV
# & all DV items
#=========================================================
reduction_data.FA = factanal(~peruse01+peruse02+peruse03+peruse04+peruse05+peruse06+
	pereou01+pereou02+pereou03+pereou04+pereou05+pereou06+
	intent01+intent02+intent03,
	factors=3,
	rotation="promax",
	scores="none",
	data=reduction_data)		#three factor solution based on previous factor analyses
reduction_data.FA
#### Result: 
#### Decision: 


#### For more information, please read Chapters 23 in The R Book
#### by Michael J. Crawley.
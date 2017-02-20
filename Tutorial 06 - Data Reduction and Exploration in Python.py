#############################################
#=============Read in Libraries=============#
# Read in the necessary libraries.          #
#############################################

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os

from sklearn.decomposition import PCA as pca
from sklearn.decomposition import FactorAnalysis as fact

#Clustering modules
import sklearn.metrics as metcs
from scipy.cluster import hierarchy as hier
from sklearn import cluster as cls

#For the tree
from sklearn.feature_extraction.image import grid_to_graph
from sklearn import tree
from sklearn.externals.six import StringIO
from IPython.display import Image
import pydotplus


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

reduc_data = pd.read_table('reduction_data_new.txt')
reduc_data.columns

kmeans_data = pd.read_table('kmeansdata.txt')
kmeans_data.columns
kmeans_data.dtypes
kmeans_data.head()
kmeans_data['group'] = kmeans_data['group'].astype('category')          #convert to categorical dtype
kmeans_data['grouping'] = kmeans_data['grouping'].astype('category')    #convert to categorical dtype
rows, cols = kmeans_data.shape
rows        #number of records
cols        #number of variables
kmeans_data.describe()
kmeans_data.describe(include=['category'])
kmeans_data.group.unique()
kmeans_data.grouping.unique()

taxon_data = pd.read_table('taxon.txt', sep=' ')
taxon_data.columns
taxon_data.dtypes
rows, cols = taxon_data.shape
rows        #number of records
cols        #number of variables
taxon_data.describe()

pg_data = pd.read_table('pgfull.txt', sep='\t')
pg_data.dtypes
pg_data.columns
pg_data.head()


#################################################
#==========Principal Component Analysis=========#
# Perform a PCA for PU, PEOU, and Intention	    #
#################################################

reduc_data_pca = reduc_data[['peruse01', 'peruse02', 'peruse03', 'peruse04', 'peruse05',
                             'peruse06', 'pereou01', 'pereou02', 'pereou03', 'pereou04', 
                             'pereou05','pereou06', 'intent01', 'intent02', 'intent03']]

pca_result = pca(n_components=15).fit(reduc_data_pca)

#Obtain eigenvalues
pca_result.explained_variance_

#Components from the PCA
pca_result.components_

plt.figure(figsize=(7,5))
plt.plot([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15], pca_result.explained_variance_ratio_, '-o')
plt.ylabel('Proportion of Variance Explained') 
plt.xlabel('Principal Component') 
plt.xlim(0.75,4.25) 
plt.ylim(0,1.05) 
plt.xticks([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15])


#################################################
#===============ML Factor Analysis==============#
# Perform a varimax rotation for all variables	#
# in the data. Use Factor Analysis for		    #
# established models and theory. Assessment is	#
# based on shared variance within the model.	#
#################################################

reduc_data_fac = reduc_data[['peruse01', 'peruse02', 'peruse03', 'peruse04', 'peruse05',
                             'peruse06', 'pereou01', 'pereou02', 'pereou03', 'pereou04', 
                             'pereou05','pereou06', 'intent01', 'intent02', 'intent03']]

fact_result = fact(n_components=3).fit(reduc_data_fac)

fact_result.components_

#################################################
#================Cluster Analysis===============#
# Perform several clustering techniques         #
#################################################

kmeans_data.grouping.unique()

#Will not work with categorical variables; metadata is the reason
#Convert back to object
kmeans_data['grouping'] = kmeans_data['grouping'].astype('object') 

#Replace values
kmeans_data.grouping.replace(['A','B','C','D','E','F'],[1,2,3,4,5,6], inplace=True)

#Convert back to categorical
kmeans_data['grouping'] = kmeans_data['grouping'].astype('category')

#Use 6 clusters
km = cls.KMeans(n_clusters=6).fit(kmeans_data.loc[:,['x','y']])
km.labels_      #assigned clusters

#Create a confusion matrix
cm = metcs.confusion_matrix(kmeans_data.group, km.labels_)
print(cm)       #Printed matrix

cm = metcs.confusion_matrix(kmeans_data.grouping, km.labels_)
print(cm)       #Printed matrix

#Color-based chart
plt.matshow(cm)
plt.title('Confusion Matrix')
plt.xlabel('Actual Value')
plt.ylabel('Predicted Value')
plt.xticks([0,1,2,3,4,5], ['A','B','C','D','E','F'])

#Use 4 clusters
km2 = cls.KMeans(n_clusters=4).fit(kmeans_data.loc[:,['x','y']])
km2.labels_     #assigned clusters

print(metcs.confusion_matrix(kmeans_data.group, km2.labels_))

#Try agglomerative clustering
agg1 = cls.AgglomerativeClustering(linkage='ward').fit(kmeans_data[['x','y']])
agg1.labels_

#Create a plot to view the output
z = hier.linkage(kmeans_data[['x', 'y']], 'single')
plt.figure()
dn = hier.dendrogram(z)
#### Results: Indicates 3 cluster groups; interesting


#################################################
#============Partitioning Analysis==============#
# Another example using the K-Means algorightm.	#
# A case in which a tree might be better.		#
# Use clustering to determine which variables	#
# would provide the best grouping for taxonomic	#
# purposes.							            #
#################################################

#==============================================================
# Which of the variables are the most useful for taxonomic 
# characterization? Using K-Means, assess which groups each
# observation is put into. 
# N = 120 observations.
#==============================================================

km3 = cls.KMeans(n_clusters=4).fit(taxon_data)
km3.labels_

#==============================================================
# The data itself is sorted so that the first 30 observations
# belong to taxon I, the next 30 taxon II, etc.
# Start out with 4 possible groupings:
# Results: Not a very good job. Look at the first 30; the
# observations are placed in clusters 2, 3, and 0! This
# should be just one!
# Let's try out 3, instead of 4 clusters:
#==============================================================

km4 = cls.KMeans(n_clusters=3).fit(taxon_data)
km4.labels_

#==========================================================
# Results: That is a little cleaner. Except we know there
# are 4 taxons. Attempt to use an agglomerative clustering 
# technique instead
#==========================================================

agg2 = cls.AgglomerativeClustering(linkage='ward').fit(taxon_data)

agg2.labels_

#Create a plot to view the output
z = hier.linkage(taxon_data, 'single')
plt.figure()
dn = hier.dendrogram(z)

#==========================================================
# Still not the cleanest result. There does appear to be
# some close clustering on the right side, but not on the
# left side. A classification tree may perform better
#==========================================================

taxon_data = pd.read_table('taxonomy.txt', sep='\t')

#Run this code all together
#You must install Graphviz prior to running this
col_names = list(taxon_data.columns.values)
classnames = list(taxon_data.Taxon.unique())

tre1 = tree.DecisionTreeClassifier('gini').fit(taxon_data.ix[:,1:8],taxon_data.Taxon)

dot_data = StringIO()
tree.export_graphviz(tre1, out_file=dot_data,
                     feature_names=col_names[1:7],
                     class_names=classnames,
                     filled=True,
                     rounded=True,
                     special_characters=True)
graph = pydotplus.graph_from_dot_data(dot_data.getvalue())
Image(graph.create_png())

#==========================================================
# Perform a hierarchical clustering technique on this
# data. Use an agglomerative process
#==========================================================

agg3 = cls.AgglomerativeClustering(linkage='ward').fit(pg_data.ix[:,0:54])

agg3.labels_

#Create a plot to view the output
z = hier.linkage(pg_data, 'single')
plt.figure()
dn = hier.dendrogram(z)
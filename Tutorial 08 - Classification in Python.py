#############################################
#=============Read in Libraries=============#
# Read in the necessary libraries.          #
#############################################

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os

from sklearn.feature_extraction.image import grid_to_graph
from sklearn import tree
from sklearn import metrics

#For displaying the tree
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
# Read in the data for both data sets.	    #
#############################################

pollute_data = pd.read_table('Pollute.txt', sep='\t')
pollute_data.columns

pollute_data.head()

taxon_data = pd.read_table('taxonomy.txt', sep='\t')
taxon_data.columns

taxon_data.head()


#################################################
#=================Tree Analysis=================#
# Pollution is a continuous variable, so this	#
# tree is a regression tree.				    #
# Pollution (SO2 concentration) is the target	#
# variable.							            #
#################################################

col_names = list(pollute_data.ix[:,1:7].columns.values)

tre1 = tree.DecisionTreeRegressor().fit(pollute_data.ix[:,1:7],pollute_data.Pollution)

dot_data = StringIO()
tree.export_graphviz(tre1, out_file=dot_data,
                     feature_names=col_names,
                     filled=True,
                     rounded=True,
                     special_characters=True)
graph = pydotplus.graph_from_dot_data(dot_data.getvalue())
Image(graph.create_png())

#==========================================================
# Resulted in a large tree that is difficult to use.
# Use the criteria min_samples_split and min_samples_leaf
# and set both to 5
#==========================================================

col_names = list(pollute_data.ix[:,1:7].columns.values)

tre1 = tree.DecisionTreeRegressor(min_samples_split=5,min_samples_leaf=5)

tre1.fit(pollute_data.ix[:,1:7],pollute_data.Pollution)

dot_data = StringIO()
tree.export_graphviz(tre1, out_file=dot_data,
                     feature_names=col_names,
                     filled=True,
                     rounded=True,
                     special_characters=True)
graph = pydotplus.graph_from_dot_data(dot_data.getvalue())
Image(graph.create_png())


#################################################
#=================Tree Analysis=================#
# Use a basic tree function to demonstrate.	    #
# This tree is a classification tree using	    #
# categorical independent variables.		    #
#################################################

#Run this code all together
col_names = list(taxon_data.columns.values)
classnames = list(taxon_data.Taxon.unique())

tre2 = tree.DecisionTreeClassifier().fit(taxon_data.ix[:,1:8],taxon_data.Taxon)

dot_data = StringIO()
tree.export_graphviz(tre2, out_file=dot_data,
                     feature_names=col_names[1:7],
                     class_names=classnames,
                     filled=True,
                     rounded=True,
                     special_characters=True)
graph = pydotplus.graph_from_dot_data(dot_data.getvalue())
Image(graph.create_png())

predicted = tre2.predict(taxon_data.ix[:,1:8])

print(metrics.classification_report(taxon_data.Taxon, predicted))

cm = metrics.confusion_matrix(taxon_data.Taxon, predicted)
print(cm)

plt.matshow(cm)
plt.title('Confusion Matrix')
plt.xlabel('Actual Value')
plt.ylabel('Predicted Value')
plt.xticks([0,1,2,3], ['I','II','III','IV'])
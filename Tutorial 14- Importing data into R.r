
############################## READING DATA INTO R #############################

#reading a file
dataframe=read.table(file.choose(),header= ,sep= )

############################### Reading the TXT data ######################

# reading TXT file
dataframe=read.table(file.choose(),header= ) 

############################### Reading the CSV data ######################


# reading csv file # csv is , seperated and csv2 is ; seperated.
dataframe=read.csv(file.choose(),header= ) 


############################### Reading the JSON data ######################

library(rjson)
JsonData <- fromJSON(file.choose() )

############################### Reading the XML data ######################


library(XML)
url <- "<a URL with XML data>"
data_df <- xmlToDataFrame(url)


############################### Reading the HTML data ######################

# Activate the libraries
library(XML)
library(RCurl)

# Assign your URL to `url`
url <- "YourURL"

# Get the data
urldata <- getURL(url)

# Read the HTML table
data <- readHTMLTable(rawToChar(urldata$content),
                      stringsAsFactors = FALSE) 

############################ :FROM STATISTICAL PACKAGES: ###################

#SPSS
library(foreign)
dataframe=read.spss(file.choose() ,to.data.frame=TRUE,use.value.labels=FALSE)

#STATA
library(foreign)
dataframe=read.dta(file.choose())

#SYSTAT
library(foreign)
dataframe=read.systat(file.choose())
 
#SAS
library(sas7bdat)
dataframe=read.sas7bdat(file.choose())

#MINITAB
library(foreign)

############################# :FROM DATABASES:  #############################

library(RMySQL)

mydb = dbConnect(MySQL(), user='user', password='password', dbname='database_name', host='host')
dataframe=read.mtp(file.choose())

dbListTables(mydb)
dbListFields(mydb, 'some_table')

#WED SCRAPPING USING API  

https://www.programmableweb.com/apis/directory

############################### READING TEXT DATA ###########################

library(tm)
text = readLines("url") # use file.choose()
docs = Corpus(VectorSource(text))

##############################################################################


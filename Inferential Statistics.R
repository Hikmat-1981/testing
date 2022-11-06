
# data.table() packages memory efficient version of data.frame cause faster way
# function() work on data.frame also works with data.table as well
# we build data.table the way create data.frame call package

library(data.table)
DF=data.frame(x=rnorm(9),y=rep(c("a","b","c"),each=3),z=rnorm(9))
head(DF,3)

DT=data.table(x=rnorm(9),y=rep(c("a","b","c"),each=3),z=rnorm(9))
head(DT,3)

# we check number of all tables in memory using tables()
tables()
# we may subset the rows based on logical criteria in data.table() package
DT[2,]
DT[DT$y=="a",]

# in data.frame() we can not use one index but in data.table()we could
DT[c(2,3)]
# but sub-setting columns in data.frame()and data.table() is diverges

DF[,c(2,3)]
DT[,c(2,3)] # you would not get error $ no result at all

# expression is collection of statements enclosed in curly braces{}
{x=1 
  y=2}
k={print(10);5}
print(k)

DT[,list(mean(x),sum(z))] 
# extract value of variable with expressions
DT[,table(y)]
DT
# here we add very fast column into data.table() package
# R just get 2 copies of data frame with and without the newly added column
DT[,w:=z^2]

DT2<-DT
DT[,y:=2]
DT[,m:={tmp<-(x+z); log2(tmp+5)}]

# we may do multiple operations on variables, just like we did in MS Excel

DT[,a:=x>0]
DT[,b:=mean(x+w),by=a]

# by means GROUP by variable names

set.seed(123);
DT<-data.table(x=sample(letters[1:3],1E5,TRUE))
DT[,.N,by=x]

DT<-data.table(x=rep(c("a","b","c"),each=100),y=rnorm(300))
setkey(DT,x)
DT["a"]

# key is also used while joining the Tables by using the KEY

DT<-fread("C:/Users/SAMSUNG/Desktop/RStudo_CFA/ACS/sex.csv")
head(DT) #--be able to load the file into R memory
# fread() command stands for Fast Reading into R

sex<-rowMeans(DT)[DT$SEX==1]; rowMeans(DT)[DT$SEX==2]
file<-tempfile() # here we create temporary file since system.time()reads and return file
write.table(sex,file=file)

install.packages("XML")
library(XML)
restaurant<-"C:/Users/SAMSUNG/Desktop/RStudo_CFA/ACS/rest.xml"
# there is no ready file to read XML just like read.XML there is way better long way to read it
doc<-xmlTreeParse(restaurant,useInternalNodes = TRUE)

rootNode<-xmlRoot(doc)
result<-xpathSApply(rootNode,"//zipcode",xmlValue)
# <xpathSApply> returns a result vector
result<-as.numeric(result)
result[,]

sum(result==21231) # this is how we count number of specific values in R vector
x<-rowMeans(DT)[DT$SEX==1]; rowMeans(DT)[DT$SEX==2]
system.time(x)

# in data.table() use by to represent group for efficient memory use
# sometimes we have to read files with <sq l> extension, data file prepared in other language like XML, x ls
# once we install DB (MySQL) packages and loaded both using library

# we have to connect to US MariaDB (SQL)server for the university database server is MariaDB
# instruction to make connection to specific SQL server is within host address is available web site

ucscDB<-dbConnect(MySQL(),user="genome",host="genome-mysql.soe.ucsc.edu")
result<-dbGetQuery(ucscDB,"show databases");dbDisconnect(ucscDB)
result

# now we may want to connect specific database we want to
hg19<-dbConnect(MySQL(),host="genome-mysql.soe.ucsc.edu",user="genome",db="hg19")
allTables<-dbListTables(hg19)
length(allTables)

allTables # --here we get >100 000 alphabetically ordered tables within the DB
allTables[1:5]

#-- we do not have an explicit way to get connected to table

dbGetQuery(hg19,"SELECT count(*) FROM affyU133Plus2")
dbListFields(hg19,"affyU133Plus2")

#-- Now, we are going to read specific table in a given database so 2 speak
#-- since, Table name is <chr>, add in within quotes

read_table<-dbReadTable(hg19,"affyU133Plus2") read_table

# Once suck out data, query still in database so clear the query out
query<-dbSendQuery(hg19,"SELECT * FROM affyU133Plus2 WHERE misMatches between 1 and 3")
john<-fetch(query)
head(john[,1:10],10) 

#--get the head of some part from the data.frame / DB Table
dbClearResult(query)

# now read HDF 5 format file
# HDF format has different groups, whereas each has data sets along with MetaData so 2 speak
# Fist we load file into R, where it helps to install the package from <BiocLite>
source("http://www.bioconductor.org/bioClite.R")
install.packages('hdf5r', repos = "http://cran.us.r-project.org")
# You may download the <hdf5r> package into R directly form cran

library(hdf5r) 
# names of function in this package starts with h5File

# An alternative way to download the package FROM
install.packages("BiocManager")
BiocManager::install("rhdf5")

library(rhdf5)
created=h5createFile("./ACS/example.h5") # extension of file is .h5
created

# Here we build groups and subgroups under the HDF5 File
# The below is the Data Structure of HDF5 Format File

created=h5createGroup("./ACS/example.h5","foo")
created=h5createGroup("./ACS/example.h5","baa")
created=h5createGroup("./ACS/example.h5","foo/foobaa")

h5ls("./ACS/example.h5")

A = matrix(1:10, nc=2, nr=5)
h5write(A,"./ACS/example.h5","foo/A")

# Here build object B-- numbers FROM 0.1 to 2.0 using dim 5 rows, 2 cols, and 2 matrices
# Build R object like matrix,data frame or an array then write it up into HDF5 groups/subgroups

B=array(seq(0.1,2,by=0.1),dim=c(5,2,2))
attr(B,"scale")<-"liter"
#scale() function scales columns of numeric Matrix
h5write(B,"./ACS/example.h5","foo/foobaa/B")

df=data.frame(1L:5L,seq(0,1,length.out=5),c("ab","cde","fghi","a","s"),stringsAsFactors = TRUE)
library(rhdf5)
h5write(df,"./ACS/example.h5","df")
h5ls("./ACS/example.h5")
# To build data frame need to add column by column

# read data that resides within group/subgroup
# it is going to extract the values out of that Group

readA=h5read("./ACS/example.h5","foo/A")
readB=h5read("./ACS/example.h5","foo/foobaa/B")
readdf=h5read("./ACS/example.h5","df")
readA

# Now we are moving on into more crucial steps in R Programming Language--

h5write(c(12,13,14),"./ACS/example.h5","foo/A",index=list(1:3,1))
h5read("./ACS/example.h5","foo/A")

# Now moving to reading from Webs-- Web Scraping out of Home Pages
# Scraping is getting data out of HTML codes of website or URLs directly not via API
# readlines() commands extract all text from and input file so 2 speak


# That is 1 way out of 3 ways to suck the data out of webpages actually

con<-url("https://scholar.google.com/citations?user=HI-I6C0AAAAJ&hl=en")
htmlCode=readLines(con)
close(con)
htmlCode

# Before connecting to URL,first create connection object using URL() just like handler
# then using subsequent functions / methods based on that connection object use close(con)

# As need to parse the data extracted from URL just the same way we get data off <.XML>file
# That is the 2 way out of 3 ways to suck out the data out of webpages actually

library(XML)#-- load the same
url<-"https://scholar.google.com/citations?user=HI-I6C0AAAAJ&hl=en"
html<-htmlTreeParse(url,useInternalNodes = TRUE)

xpathSApply(html,"//title",xmlValue)
y<-xpathSApply(html,"//td[@id='col-citedby']",xmlValue)

# GET From the httr package

library(httr)--
  
  # Once we load <httr> library, use GET(),content(),htmlParse and xpathSApply() by sequence 
  # That is an alternative way to get access and read data off the URL or pages
  
  url<-"https://scholar.google.com/citations?user=HI-I6C0AAAAJ&hl=en"
html2<-GET(url)

content2<-content(html2,as="text")
parsedHtml=htmlParse(content2,asText = TRUE)
xpathSApply(parsedHtml,"//title",xmlValue)

# Access websites with passwords--

pg2<-GET("http://httpbin.org/basic-auth/user/passwd",authenticate("user","passwd"))
names(pg2)

pg1=GET(handle=...,path) # to make sure save authentication across multiple save

# READING FROM API --
# API is more clean way of sucking out data compared to scraping whole web at all

install.packages("httr")
library(httr)

# Accessing web API's are crucial step being in this stage--
# Web services use special style known as REST API's
# API is remote computer or serves used for data provision. Use commands to request data from the server
# You send and HTTP Request to server where API is located and get and parse the response--
#Web services use HTTP protocol--
# Domain is the address of the web Server--
# Path is the resource on server you want to have access to like file or folder name--

# To send HTTP Request to register with the API-- who is asking the data
# Secret Password means= API Keys

# Better to keep API key in separate R files and run using source()command

source("api-keys.R")
print(api_key)

# Have access a Web API, you just need to send an HTTP Request to a particular URI.--
# GET() function will send an HTTP GET Request to the URI specified as an argument--
# ?q = represents parameters for the query--

response <- GET("https://api.github.com/search/repositories?q=d3&sort=forks")
body <- content(response, "text")

# content() extracts the content of the URL as the "text" not the list
# JSON format is an interesting version of Data.Frame in R Programming Language

install.packages("jsonlite")--
  
  library(jsonlite)
parsed_data <- fromJSON(body)  # convert the JSON string to a list

pased=jsonlite::fromJSON(toJSON(parsed_data))

# Registering an application GithUB account the number one for quiz--

response_2 <- GET("https://api.github.com/users/jtleek/repos")
body<-content(response_2,"text")
json<-fromJSON(body)


# FwF (Fixed width file) is <Fortran> Language file and use R to read .fwf extension format--
# I use read.fwf()command to read that file into R and return data.frame into Programming Lang

# In question itself it implicitly states that there should be "nine" columns
# width() argument should be integer vector each stating number of character for columns arbitrarily--

fortran<-read.fwf("C:/Users/SAMSUNG/Desktop/RStudo_CFA/ACS/getdata_wksst8110.for",skip=4, widths=c(12, 7, 4, 9, 4, 9, 4, 9, 4))
sum(fortran[,4])

# To read <html> file on web--,first we build handler using url()command and insert the link --
# Then use readLines()command inserting handler as argument-- then close connection

url_son <- url("http://biostat.jhsph.edu/~jleek/contact.html")
code <- readLines(url_son)
close(url_son)
url_son

# I better to use <sqldf> package loaded into R to send SQL Queries into data Frame in R
# so, I use sqldf() command to run SQL queries in double quotes into R data Frames
# in SQL,select command selects columns but the rows like in R --

install.packages("sqldf");library(sqldf)
acs<-read.csv("C:/Users/SAMSUNG/Desktop/RStudo_CFA/ACS/getdata_data_ss06pid.csv")

# here is the answer
sqldf("select pwgtp1 from acs where AGEP< 50")

# GitHub has its own API software endpoints like Twitter, Google APIs accessed tokes 
# To access to GitHub API I use <OAuth> applications that need to register myself github/settings/developers
# First we install and load libraries to work with

install.packages(c("jsonlite","httpuv","httr"))
library(jsonlite);library(httpuv);library(httr)

# Here we find OAuth settings for GitHub 
# That is because, different Servers has different setting check <oauth_endpoints("twitter or google")>

oauth_endpoints("github")

# Now I need to register an OAuth application in GitHub and assign it to the variable
# I may need to register myself github/settings/developers--
# Once registered we add app name,key and secret from the GitHub account to assign to variable <myapp>
# ouath_app() command requires httr package to load in hand

myapp <- oauth_app("Hikmat_app",key = "6590f6469335fd347986",secret = "b7804df91a2b5621527e41cd1638ab15790bf6ac")

# Here we are getting credentials for OAuth in GitHub to authorize the <Hikmat_app> application
# use oauth2.0_token() command for more info ?oauth2.0_token
# We authenticate the Hikmat_app to have and get access to my github account called <hikmat-1982>

github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)

# Now I am using an API sending GET request to the url--
# You do not need to log in to your GitHub every time, since API will do it for you

req <- GET("https://api.github.com/users/jtleek/repos", config(token = github_token))

# I take action on http error if anything happens--
# For more info use ?stop_for_status()
# Extract content from GET request --so it returns a list in R Programming Language

stop_for_status(req)
output <- content(req);str(output)
gitDF=jsonlite::fromJSON(jsonlite::toJSON(output))

# Converting a .json file into a data.frame in R
# Hence I am sub-setting the data frame
gitDF[gitDF$full_name=="jtleek/datasharing","created_at"]

# Sub-setting and Sorting Data in Data Frames in R language
# I am sub-setting the rows based on variable categories since observation based on variable

set.seed(12345)
X<-data.frame("var1"=sample(1:5),"var2"=sample(6:10),"var3"=sample(11:15))
X$var2[c(1,3)]=NA
X[1:2,"var2"]

X[(X$var1<=3 & X$var3>11),] # Sub-setting rows logical factor using vector of rows and cols
X[(X$var1<=3 | X$var3>15),] # Sub-setting rows logical factor using vector of rows and cols

X[which(X$var2>8),]

# If you do not use which()command index of rows with NA also included
# Use which() command for the selected vector returns the number of rows condition met w/o NAs

sort(X$var1,decreasing = TRUE)

# By using order() command reorder the vector of row indices --
# If the var1 has same repeating number then sorted by var3,no repeat values returns the same result

X[order(X$var1),]

X[order(X$var1,X$var3),]

# An alternative way to build sort() or order() is to use arrange() from <plyr> packages
# In arrange() method I do not use X$ but only name of variable itself--
# easiest way to add new column is to use Data Frame name and assign a value to it --

install.packages("plyr"); library(plyr);arrange(X,desc(var1));X$var4<-rnorm(5)

# First we create folder named data if does not exist under the current working directory
if(!file.exists("./data")){dir.create("./data")}

# Then I assign the URL(link) for the file I wish to download
fileUrl<-"03_GettingData/03_02_summarizingData/data/restaurants.csv"

# Finally, download the file url into destination file under <cwd> using "curl" method
# Final,I read the file into R Studio using read.csv()method --

download.file(fileUrl,destfile ="./data/restaurants.csv",method="curl" )
restData<-read.csv("./data/restaurants.csv")

head(restData,n=3) # that way I may want to see only head some columns for the data Frame

summary(restData) # returns the characteristics for each column-variable in a given data frame
str(restData)     # returns the structure for the given data frame

quantile(restData$councilDistrict,na.rm = TRUE) # -- I actually think in R in terms of vector()
quantile(restData$councilDistrict,probs = c(0.5,0.75,0.9),na.rm = TRUE) # may add probs() argument

# I can make a table out of column(variable)sucked out of data frame--

table(restData$zipCode,useNA = "ifany")

# To be able to create a table out of variable/column out of data frame in multiple dimension
# So,2 dimension means I order one vector on top, and another on left and see the intersection of the 2
# Here is how it really works out - - table means frequency table intersection==numbers

table(restData$councilDistrict,restData$zipCode)

# Checking for missing values in Data Frame or in separate columns in it--

sum(is.na(restData$councilDistrict)) 
# returns the sum of <TRUE>s, if there is a NA values/missing

any(is.na(restData$councilDistrict))
# return TRUE or False if any of the value in vector is NA

all(restData$zipCode>0)              
# returns TRUE or False if all the values in vector >0

colSums(is.na(restData))
all(colSums(is.na(restData))==0)      # returns Boolean if all <colSums> ==0

restData$zipCode %in% c("21212")        # returns Boolean vector()if there is "21212" text in the vector()
table(restData$zipCode %in% c("21212")) # takes the vector and builds frequency table of TRUE and <FALSEs>

# Today we are going to wrap up with "Summarizing Data"
# I load R built-in data frames in using data()command in R Programming Language

data(UCBAdmissions)

# Since data()command returns <table> structure--I need to convert it 2 data frame

DF=as.data.frame(UCBAdmissions)
summary(DF)

# Cross Tabs make formula of one variable in terms of other variables --
xt<-xtabs(Freq~Admit+Gender,data=DF)

data(warpbreaks)

# Here I am adding new variable/column to <warpbreaks> data frame repeating 9 times to 54--
warpbreaks$replicate<-rep(1:9,len=54)

# Here I assume breaks columns in as a function() of all other <.sign> 
# Since there are >2 variables, one is staying the same other in terms of 2 dimensional Table --
xt=xtabs(breaks~., data=warpbreaks)

# Since there are >2 variables out there,-- hard to see more 2 dimensional tables
# I am using flat table using <ftable>() command picking an cross Table as an argument columns up 

ftable(xt)

# Creating new variable by transformation, missing values and so on..

restData<-read.csv("C:/Users/SAMSUNG/Desktop/RStudo_CFA/data/restaurants.csv")

# There are 3 ways to build up sequence in R Programming Language
# Last version takes any other variable as an argument and returns an index vector for comparison

s1<-seq(1,10,by=2); s1
s2<-seq(1,10,length=3); s2

vecor<-c(1,10,20,35,50); seq(along=vecor)

# HINT: whenever I am not using any packages I use $ sign before the variable-- <packgages> directly
# Table()command creates a frequency Table--, using TRUE and False as categorical variable

restData$nearMe=restData$neighborhood %in% c("Roland Park","Homeland")

table(restData$nearMe)

# Now I am creating a binary variable instead in tabular format
# table() frequency command puts 2 variables side by side -- return sum of same combinations
# Use semi-colon operator to run lines of codes by sequence in R Programming Language

restData$zipWrong=ifelse(restData$zipCode<0,TRUE,FALSE);table(restData$zipWrong,restData$zipCode<0)

# Now I am going to create a categorical variable into R--
# quantile()command by default breaks down whole vector into 4 equal intervals as a factor variable

abc<-c(2,10,20,30,50,35,48,60); quantile(abc)

# What actually the code below does,breaks down vector()into intervals and returns interval factor vector-
# and creates frequency table out of 2 vectors using sum of unique combinations of 2 vectors
# cut() method/command breaks down integer/numeric vector and build a factor variable

restData$zipGroups=cut(restData$zipCode,breaks=quantile(restData$zipCode));table(restData$zipGroups,restData$zipCode)

# There is an easy way for cutting numeric data into factor variable using <Hmisc> packages.
# Since I have built-in R function cut(), the packages uses the same as cut2()--

install.packages("Hmisc"); library(Hmisc);restData$zipGroups=cut2(restData$zipCode,g=4)
table(restData$zipGroups)

# I do create factor vector out of integer using factor()command and integer factor as an argument--

restData$zcf<-factor(restData$zipCode); restData$zcf[1:10]; class(restData$zcf)

# Here using random number generator-- I use character vector of <yesno>
# Then again--convert it to factor vector() using the factor()command with level=argument--

# relevel() command is crucial--while converting to integer how to assign 0 or 1

yesno<- sample(c("yes","no"),size=10,replace=TRUE)
yesnofac<-factor(yesno,levels=c("yes","no"));relevel(yesnofac,ref="yes")

# mutate() command also works with dplyr package which I am gonna to talk about shortly--
install.packages("plyr"); library(plyr);restData2=mutate(restData,zipGroups=cut2(zipCode,g=4))

# round(data.frame(),digits=2) that command works both with vector and data frame as well.
# Congratulations Hikmat -- Well done job Man

install.packages("reshape");library(reshape);head(mtcars);View(mtcars)

mtcars$carname<-rownames(mtcars)

carMelt<-melt(mtcars,id.vars=c("carname","gear","cyl"),measure.vars=c("mpg","hp"))

# In id()variable in melt()function, means I am keeping all the column out there--
# That means for every combination of id variable column provide me variables and their values side by side

head(carMelt,n=3); tail(carMelt,n=3)

cylData<-dcast(carMelt,cyl~variable);cylData;cylData<-cast(carMelt,cyl~variable,mean)

# Any time, if there is more than one value in id variable column ,since the dcast() or if not available
# dcast() function- returns values only once I need to use aggregation function just like mean, sum,count

head(InsectSprays); tapply(InsectSprays$count,InsectSprays$spray,sum)

# The meaning of the line code above is that, go to count column vector in Insect Spray DF, apply sum()function
# along with spray column and return the vector of their results.
# <tapply() function means apply the fun. along index, where index serves as a column 2 in that case>--

# split() breaks down the column/vector along with the other column/vector and returns list--

spIns=split(InsectSprays$count,InsectSprays$spray);sprCount=lapply(spIns,sum);unlist(sprCount)

# An alternative way is to use ddply() command in dplyr packages-- install.packages("plyr")
# Here I am using .(spray) in order to differentiate it from function so it is not a function actually--

# Both tapply(),dcast() and ddply() commands are used to summarize on vector of variable on the other one.
# There should be some other methods to come up with the same answer at once --

ddply(InsectSprays,.(spray),summarize,sum=sum(count));library(plyr)

spraySums=ddply(InsectSprays,.(spray),summarize,sum=ave(count,FUN=sum))

# The only difference between those 2 lines of code, one below puts the summarised value on every value
# Now, I am moving to most powerful <dplyr> package for manipulating the data frame in R Programming Lang...

install.packages("dplyr");library(dplyr)

chicago<-readRDS("chicago.rds"); dim(chicago);str(chicago)

# Hint:While choosing subset of columns from:to just as the way I am choosing vector values I may want
# to use columns. For instance: <col1:col5> # While using packages, in command I put the data frame first then refer to cols w/o the $ sign

head(select(chicago,city:dptp));head(select(chicago,-(city:dptp))) 

# Negative sign means choose all the columns except the city <dptp> column as thereof
# filer()command in <dplyr> package is used to filter the vector of rows where col is on condition

chic.f<-filter(chicago,pm25tmean2>30);head(chic.f,10)

# arrange()command in R, is used to reorder the rows based on criteria on columns --
# filter() command extract the values of rows based on criteria on columns --
# rename() method is used 2 rename the cols --

chicago<-arrange(chicago,desc(date));chicago<-rename(chicago,pm25=pm25tmean2);head(chicago,10) 

# mutate() in <dplyr> package to create or transform the existing column/vector just the way in MS Excel
# New columns automatically added to the end of the data frame

chicago<-mutate(chicago,pm25detrend=pm25-mean(pm25,na.rm=TRUE))

head(select(chicago,pm25,pm25detrend))

# I am using the 1*logical()TRUE or FALSE vector to convert it into 0's and 1's -- so 2 speak --
# use factor(labels=c("")) is used to build up a factor category labels so 2 speak --

# For today, U have done great job Man

library(dplyr);chicago<-mutate(chicago,tempcat=factor(1*(tmpd>80),labels=c("cold","hot")))

hotcold<-group_by(chicago,tempcat);str(hotcold);summarize(hotcold)

# summarize()command itself creates new data structure called tibble --
# Once I have done grouping by one column, I may take summary statistics any of the columns I want to

summarize(hotcold,pm25=mean(pm25,na.rm=TRUE),o3=max(o3tmean2),no2=median(no2tmean2))

# I may want to categorise all other columns based on year variable/column
# In order to do that--  I need to create new variable using mutate() then group all D.F by that col
# Once I group by all then use various summary statistics over the other columns so 2 speak

chicago<-mutate(chicago,year=as.POSIXlt(date)$year+1900); years<-group_by(chicago,year)

# summarize()command/method/function is also included in <dplyr> package in R Programming Language

summarize(years,pm25=mean(pm25,na.rm=TRUE),o3=max(o3tmean2),no2=median(no2tmean2))

# There is an easy and alternative way doing multiple operations together in one row
# Combining the sequence of operations by using %>% -- pipeline operator in <dplyr> packages

# Merging data in R is the same as in SQL Programming Language -- so it is crucial for R too..
# That is place I am going to download and read files from --

if(!file.exists(./data)){dir.create("./data")}

# download.file(fileUrl1,destfile = "./data/reviews.csv",method="curl")
# download.file(fileUrl2,destfile = "./data/solutions",method="curl")

reviews=read.csv("./data/reviews.csv");solutions<-read.csv("./data/solutions.csv");head(reviews,2)

# The downloaded file is read into R memory-- only if the link is not broken--otherwise an error--
# If I look at the data, solution table <id> column corresponds to <solution_id> col in reviews D.F

head(reviews,2)

names(reviews);names(solutions)

mergedData=merge(reviews,solutions,by.x="solution_id",by.y="id",all=TRUE)

# Here argument all=TRUE means Full Outer Join in SQL command, it is easy 2 remember that way --

df1=data.frame(id=sample(1:10),x=rnorm(10))
df2=data.frame(id=sample(1:10),x=rnorm(10))
arrange(merge(df1,df2),id)

install.packages("dplyr");library(dplyr)

# The join()command or method in <dplyr> package defaults to left join in SQL command
# But -- merge() command in base R is more flexible in terms of full left and right Joins

# I can merge more than 2 data frames by including all DF in a list and then merging all together
# But, the basic premise is 2 use merge() functions in R

df1=data.frame(id=sample(1:10),x=rnorm(10));df2=data.frame(id=sample(1:10),x=rnorm(10))
df3=data.frame(id=sample(1:10),x=rnorm(10))

dfList=list(df1,df2,df3); join_all(dfList)

# Here I am loading swirl() for assignments 2 be submitted --
# Once I am getting an error, Google it and fix that in Note Pad File

library(swirl);uninstall_all_courses();install_course("Getting and Cleaning Data");swirl()

install.packages("jpeg");library(jpeg) 
install.packages("reshape2")
library(datasets);data(ChickWeight);library(reshape2)

wideCW<-dcast(ChickWeight,Diet+Chick~Time,value.var = "weight")

# Here,using dcast()command means diet and chick columns will stay in >
# place, and time move in horizontal direction and weigh along also >

# In plain English that means how the weigh changes along time across
# all diet an chicken combinations over time --

names(wideCW)[-(1:2)]<-paste("time",names(wideCW)[-(1:2)],sep="")

# The code above means names(wideCW)means return me the vector of names
# of given data frame and then paste time word 2 each of them but
# excluding the first 2 since they are from dcast()command 2 repeated--

# mutate()command used 2 add new column in dplyr package --

wideCW14<-subset(wideCW,Diet %in% c(1,4))

# The code above means select the data frame subset where Diet column
# has the values 1 or 4 and skip the others

install.packages("UsingR")
library(UsingR)

data("father.son")
x<-father.son$sheight
n<-length(x)
B<-10000
resamples<-matrix(sample(x,n*B,replace=TRUE),B,n)
resamplemedians<-apply(resamples,1,median)

# apply()command is applied to matrix so 2 speak --
# Resampling clearly moves some obstacles out of the way --


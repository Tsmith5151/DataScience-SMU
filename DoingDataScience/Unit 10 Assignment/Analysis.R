# Data Source http://stat.columbia.edu/~rachel/datasets

library(ggplot2)

#Function to download each csv file from URL
mydownload <- function(start,end){
  num <- seq(start,end,by=1)
  for (i in 1:length(num)){
    string_num <- as.character(num[i])
    url <- paste0("http://stat.columbia.edu/~rachel/datasets/nyt",string_num,".csv")
    file <- paste0("Data/nyt",string_num,".csv")
    download.file(url,destfile = file)
  }
}


#call the download function and pass the range for file names
mydownload(1,1)

#Read CSV file into Data.Frame
mydata <- function(name,start,end){
  t1 <- proc.time()
  #read first file to create variables in data frame and headers
  d1<- read.csv(paste0(name,"1",".csv",sep=""),header=TRUE)
  num <- seq(start,end,by=1)
  for(i in 1:length(num)){
    string_num <- as.character(num[i])
    file <- paste0(name,string_num,".csv",sep="")
    d1<-rbind(d1,read.csv(file=file))
  }
  total <- proc.time() - t1
  print(cat("Dimensions:",dim(d1),sep=" "))
  print(cat("Run Time:",total,sep=" "))
  return(d1)
}

#call mydata function and pass file name, start and end date:
df<-mydata("Data/nyt",1,1)

#Remove any rows with NA for Age
df<-df[!(is.na(df$Age)), ]

#Remove any row observations with age = 0
df <- df[-which(df$Age == 0),]
head(df,10)

#Create histogram of age distribution 
hist(df$Age,freq=FALSE,xlab="Age",col="navy",border="white",
     main="Histogram of Age")

#Create a new variable ageGroup that categorizes age into following groups:
#< 18, 18–24, 25–34, 35–44, 45–54, 55–64 and 65+.
df$ageGroup <- cut(df$Age,c(-Inf,18,24,34,44,54,64,Inf))
#cut function creates a factor with levels
levels(df$ageGroup) <- c("<18","18-24","25-34","35-44","45-54","55-64","65+")
knitr::kable(head(df,3))


#Use sub set of data called “ImpSub” where Impressions > 0 ) in your data set.
  
#Subset the data; new object "ImpSub"
ImpSub <- subset(df,Impressions>0)

#Create a new variable called click-through-rate (CTR = click/impression).
  
ImpSub$CTR <- round(ImpSub$Clicks/ImpSub$Impressions,4)

# Using ImpSub data set to do further analysis

#Plot distributions of number impressions and click-through-rate (CTR = click/impression) for the age groups.
p<- ggplot(ImpSub,aes(x=Impressions,colour=ageGroup)) + geom_density()
p+labs(title="Day 1: Impressions vs Age Group", # add title
       x="Impressions",y="Density",colour="Age Group") 

#Define a new variable to segment users based on click -through-rate (CTR) behavior.
#CTR< 0.2, 0.2<=CTR <0.4, 0.4<= CTR<0.6, 0.6<=CTR<0.8, CTR>0.8 
ImpSub$CTR_Segments <- cut(ImpSub$CTR,c(0,0.2,0.4,0.6,0.8,Inf))
levels(ImpSub$CTR_Segments) <- c("<0.20","0.20-0.40","0.40-0.60","0.60-0.80",">0.80")


#Get the total number of Male, Impressions, Clicks and Signed_In (0=Female, 1=Male) 

#Convert Numeric to Male/Female:
ImpSub$Gender[ImpSub$Gender == "0"] <- "Female"
ImpSub$Gender[ImpSub$Gender == "1"] <- "Male"

sum_stats <- aggregate(ImpSub[c("Impressions","Clicks","Signed_In")],by=list(ImpSub$Gender),FUN=sum)
colnames(sum_stats) <- c("Gender","Total Impressions","Clicks","Signed_In")
knitr::kable(sum_stats)


#Subset for Sign In and Males
ImpSub.Male <- subset(ImpSub,Gender=="Male",Signed_In=1)
head(ImpSub.Male)


# Get the mean of Age, Impressions, Clicks, CTR and percentage of males and signed_In 
  
sum_stats <- aggregate(ImpSub.Male[c("Impressions","Clicks","Signed_In")],by=list(ImpSub.Male$Gender),FUN=sum)
colnames(sum_stats) <- c("Gender","Avg Impressions","Avg Clicks","Signed_In")
knitr::kable(sum_stats)

#Get the means of Impressions, Clicks, CTR and percentage of males and signed_In  by AgeGroup.
  

Age_stats <- aggregate(ImpSub.Male[c("Impressions","Clicks","CTR")], by=list(ImpSub.Male$ageGroup) ,FUN=mean)
colnames(Age_stats) <- c("AgeGroup","Impressions","Avg Clicks","CTR")
knitr::kable(Age_stats)

# Plot Males Age Group vs Avg. Click Through Rate

p <- ggplot(ImpSub.Male,aes(x=ageGroup,y=mean(CTR),fill=ageGroup)) + geom_bar(stat="identity") 
p+labs(title="Males: Age Group vs Avg. CTR", # add title
       x="Age Group",y="Mean CTR",colour="Age Group")  
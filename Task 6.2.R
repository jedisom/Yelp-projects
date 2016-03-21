#Coursera Data Mining Capstone - UIUC
#Task 6
#Jed Isom
#October 5, 2015

library("pacman")
pacman::p_load(jsonlite, tm, slam, topicmodels, LiblineaR)

rm(list=ls())
setwd("./Capstone/Raw Data")

#Hygiene.dat file loading
filename <- "./Hygiene/hygiene.dat"
reviews <- readLines(filename)

#Hygiene.dat.labels file loading
filename <- "./Hygiene/hygiene.dat.labels"
labels <- readLines(filename)
labels <- as.numeric(labels)

#Hygiene.dat.additional file loading
filename <- "./Hygiene/hygiene.dat.additional"
X <- read.csv(filename, header=FALSE)
names(X) <- c("categories", "Zip", "review.count", "avg rating")
X[,"categories"] <- as.character(X[,"categories"])
X[,"review.count"] <- as.numeric(X[,"review.count"])
X[,"avg rating"] <- as.numeric(X[,"avg rating"])

#F-score combining review counta and avg rating
#normalize the review counts (log of counts) and average ratings to be values between 0 and 1
log.counts <- log(X[, "review.count"])
norm.counts <- (log.counts-min(log.counts)+1)/(max(log.counts)-min(log.counts)+1) #add 1 to prevent 0's
norm.stars <- (X[,"avg rating"]-min(X[,"avg rating"]))/(max(X[,"avg rating"])-min(X[,"avg rating"]))
beta <- 3.0
X[,"F1"] <- (1+beta^2)*(norm.counts * norm.stars)/((beta^2 * norm.counts) + norm.stars)

#turn first column into lists of categories, not long characters/factors
X[,1] <- gsub("\\[", "", X[,1])
X[,1] <- gsub("\\]", "", X[,1])
X[,1] <- gsub("'", "", X[,1])

#read text reviews into a "corpora" and clean them up for analysis
reviews <- gsub("&#160;", "", reviews)
reviews <- paste(reviews, " zaybxc") #add dummy term: helps if document is empty after scrubbing.
corp <- Corpus(VectorSource(reviews))
rm(reviews) #delete reviews to save RAM
corp <- tm_map(corp, removeNumbers)
corp <- tm_map(corp, content_transformer(tolower))    #lower case needs to be before stopwords
corp <- tm_map(corp, removeWords, rev.default(stopwords('english')))  #reverse order to get contractions
corp <- tm_map(corp, removeWords, "'s")
corp <- tm_map(corp, removePunctuation)   #remove after stopwords because many contractions are stop words
corp <- tm_map(corp, stripWhitespace)
corp <- tm_map(corp, stemDocument)

dtm <- DocumentTermMatrix(corp)

#create label vectors to split the dtm by pass/fail
Labels <- matrix(labels, ncol=1)
Labels1 <- Labels
Labels0 <- Labels
Labels1[is.na(Labels[,1]),1] <- 0
Labels0[is.na(Labels[,1]),1] <- 1
Labels1 <- as.vector((Labels1[,1]==1))
Labels0 <- as.vector((Labels0[,1]==0))
dtm0 <- dtm[Labels0, ]
dtm1 <- dtm[Labels1, ]

#calculate and sort comparative term frequencies for pass/fail reviews
length0 <- sum(as.matrix(rollup(dtm0, 2, na.rm=TRUE, FUN = sum)))
length1 <- sum(as.matrix(rollup(dtm1, 2, na.rm=TRUE, FUN = sum)))

terms0 <- as.data.frame(t(as.matrix(rollup(dtm0, 1, na.rm=TRUE, FUN = sum))))
terms1 <- as.data.frame(t(as.matrix(rollup(dtm1, 1, na.rm=TRUE, FUN = sum))))

terms0 <- terms0/length0
terms1 <- terms1/length1

termsDelta <- as.data.frame(terms0-terms1)
names(termsDelta) <- "Delta"
termsDelta[,"terms"] <- row.names(termsDelta)
termsDelta <- termsDelta[termsDelta[,1]!=0,]
termsDelta[,1] <- abs(termsDelta[,1])
termsDelta <- termsDelta[order(-termsDelta$Delta),]

#rm(corp) #delete corpus to save RAM

#Get document lengths based on terms found
X[,"doc.lengths"] <- as.data.frame(as.matrix(rollup(dtm, 2, na.rm=TRUE, FUN = sum)))

term.list <- termsDelta$terms
#term.list <- c(findFreqTerms(dtm, lowfreq=10), "zaybxc")
dtm <- dtm[ ,term.list]
dtm0 <- dtm0[ , term.list]
dtm1 <- dtm1[ , term.list]

#create topic models to be turned into X variables (0=passed inspection, 1=failed inspection)
#figure out roughly the best # of topics to create based on knee of perplexity curve
#This takes a long time, but I only ran this code once get the number of topics
for (i in 2:20){
      topics0 <- LDA(dtm0, i, method = "Gibbs") #, seedwords = suspect.terms)
      print(paste(i, ": ", perplexity(topics0, dtm0, estimate_theta=FALSE), sep=""))
}
for (i in 6:18){
      topics1 <- LDA(dtm1, i, method = "Gibbs") #, seedwords = suspect.terms)
      print(paste(i, ": ", perplexity(topics1, dtm1, estimate_theta=FALSE), sep=""))
}

zero.topic.count <- 11
one.topic.count <- 13

topics0 <- LDA(dtm0, zero.topic.count, method = "Gibbs") #, seedwords = suspect.terms)
topics1 <- LDA(dtm1, one.topic.count, method = "Gibbs") #, seedwords = good.terms)

#Use topic models from p/f restaurants to create posterior probabilities for unknown p/f rest's
num.docs <- dim(X)[1]
topic0names <- paste("pass_topic_",(1:zero.topic.count), sep="")
topic1names <- paste("fail_topic_",(1:one.topic.count), sep="")
X[, topic0names] <- 0
X[, topic1names] <- 0

for (i in 1:num.docs){
      temp.dtm <- dtm[i, ]
      #print (posterior(topics0, temp.dtm)$topics)
      X[i, topic0names] <- posterior(topics0, temp.dtm)$topics
      X[i, topic1names] <- posterior(topics1, temp.dtm)$topics
      print (paste("row ", i, " of 13299", sep=""))
}

#write to file just in case
write.csv(X,"X.csv")

#turn categories into sparse boolean vectors/columns for analysis in the future
cuisine.list <- as.list(unique(unlist(strsplit(X[,1], split=", "))))
cuisine.list[[match("Restaurants", cuisine.list)]] <- NULL
cuisine.list <- unlist(cuisine.list)
X[,cuisine.list] <- 0      #add empty columns that will be logical if cuisine or not
nrows <- dim(X)[1]
for (i in 1:nrows){
      tempList <- strsplit(X[i,1], split=", ")
      for (j in tempList){
            X[i,j] <- 1
      }
}

#figure out which cuisines might be used as predictors for pass/fail
tRows <- 1:546
tLabels <- as.matrix(labels,ncol=1)[tRows,1]
cuisine.fail <- matrix(tLabels, ncol=1)
cuisine.fail = cbind(cuisine.fail, X[1:546, cuisine.list])
names(cuisine.fail) <- c("pass_fail", cuisine.list)
cuisine.pass = cuisine.fail[cuisine.fail[,1]==0, ]
cuisine.fail = cuisine.fail[cuisine.fail[,1]==1, ]
cuisine.diff <- colSums(cuisine.pass[, cuisine.list])-colSums(cuisine.fail[, cuisine.list])
pred.cuisines <- names(cuisine.diff[cuisine.diff!=0])

#Add in variables for term count/doc.length for each document (normalize between 0 and 1)
#X[ ,term.list] <- as.data.frame(as.matrix(dtm)/X[,"doc.lengths"])
#X[ ,term.list] <- (X[ ,term.list]-min(X[ ,term.list]))/
#                           (max(X[ ,term.list])-min(X[ ,term.list])) 

#remove dtm variable to save RAM
#rm(dtm)

###LOGISTIC REGRESSION

#train logistic regression model
Xs <- X[,c("review.count", "avg rating", "F1", topic0names, topic1names, pred.cuisines)]
c <- heuristicC(as.matrix(Xs[tRows, ]))
regConstants <- c(.0000001, .0000003, .000001, .000003, .00001, .00003, .0001, .0003, .001, .003, 
                  .01, .03, .1, .3, 1, 3, 10, 30, 100, 300, 1000, 3000, 10000, 30000)
set.seed(1)
for (i in regConstants){
      
      temp <- LiblineaR(data=as.matrix(Xs[tRows, ]), target=tLabels, cost=i, cross=10) 
      print(paste(i, cat("\t"), temp))
}
logRegModel <- LiblineaR(data = as.matrix(Xs[tRows, ]), target=tLabels, cost=c)


#get predictions for the rest of the data
test.rows <- 547:dim(X)[1]
logRegPredict <- as.numeric(as.character(unlist(predict(object=logRegModel, 
                                                        newx=as.matrix(Xs[test.rows, ])))))

#create submission file
submission <- matrix(c("jedi623", logRegPredict),ncol=1)
write(submission, file="logRegSubmission6.txt")

#Add the logistic regression model output to the X parameters used to tune future models
X[,"logReg"] <- as.numeric(as.character(unlist(predict(object=logRegModel, newx=as.matrix(Xs)))))

###sUPPORT VECTOR MACHINE

#train svm model
Xs <- X[,c("review.count", "avg rating", "F1", "doc.lengths", topic0names, topic1names, "logReg")]
c <- heuristicC(as.matrix(Xs[tRows, ]))
regConstants <- c(.0000001, .0000003, .000001, .000003, .00001, .00003, .0001, .0003, .001, .003, 
                  .01, .03, .1, .3, 1, 3, 10, 30, 100, 300)
set.seed(1)
for (i in regConstants){
      #setting type =1 changes model from logistic regression (default=0) to SVM (1)
      temp <- LiblineaR(data=as.matrix(Xs[tRows, ]), target=tLabels, cost=i, cross=10, type=1) 
      print(paste(i, cat("\t"), temp))
}
SVMModel <- LiblineaR(data=as.matrix(Xs[tRows, ]), target=tLabels, cost=.003, type=1)

#get predictions for the rest of the data
SVMPredict <- as.numeric(as.character(unlist(predict(object=SVMModel, newx=as.matrix(Xs[test.rows,])))))

#create submission file
submission <- matrix(c("jedi623", SVMPredict),ncol=1)
write(submission, file="SVMSubmission2.txt")


###
#figure out which cuisines might be used as predictors for pass/fail
cuisine.fail <- matrix(tLabels, ncol=1)
cuisine.fail = cbind(cuisine.fail, X[1:546, cuisine.list])
names(cuisine.fail) <- c("pass_fail", cuisine.list)
cuisine.pass = cuisine.fail[cuisine.fail[,1]==0, ]
cuisine.fail = cuisine.fail[cuisine.fail[,1]==1, ]
cuisine.diff <- colSums(cuisine.pass[, cuisine.list])-colSums(cuisine.fail[, cuisine.list])
pred.cuisines <- names(cuisine.diff[cuisine.diff!=0])

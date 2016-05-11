#Coursera Data Mining Capstone - UIUC
#Task 3.2
#Jed Isom
#September 22, 2015

library("pacman")
pacman::p_load(jsonlite, tm, topicmodels, lsa, slam, cluster)

rm(list=ls())
setwd("./Capstone/Raw Data")

json.file <- "yelp_academic_dataset_business.JSON"
#took this line of code from http://stackoverflow.com/questions/26519455/error-parsing-json-file-with-the-jsonlite-package
business <- fromJSON(sprintf("[%s]", paste(readLines(json.file), collapse=",")))
#this lists information about the businesses (location, hours, category, name, some attributes)

json.file <- "yelp_academic_dataset_review.JSON"
review <- fromJSON(sprintf("[%s]", paste(readLines(json.file), collapse=",")))
#list reviews by businesses

#add boolean variable to business is.chinese
#quick and dirty code for this, but only takes a couple seconds
for (i in 1:dim(business)[1]){
  business[i,"is.chinese"] <- is.element("Chinese", business[i,"categories"][[1]])
}

#subset business dataframe for just restaurants
business <- business[business[,"is.chinese"]==TRUE,]

#consolidate all of the reviews for Chinese into 1 "document"
#get list of businesses that have that Chinese
bus.list <- business[,"business_id"]

#get list of reviews for those businesses
rev.list <- review[is.element(review[,"business_id"],bus.list),"text"]
#randomly select maximum number of reviews to use as representation of the cuisine
rev.max <- min(5000,length(rev.list))
set.seed(1)
rev.list <- sample(rev.list, rev.max, replace=FALSE)

#Combine all the reviews for these businesses and store in Chinese.reviews
Chinese.reviews <- paste(rev.list, collapse = " - ")

#Turn text into Corpus and clean up before creating document term matrix
corp <- VCorpus(VectorSource(Chinese.reviews))
corp <- tm_map(corp, removeNumbers)
corp <- tm_map(corp, content_transformer(tolower))    #lower case needs to be before stopwords
#corp <- tm_map(corp, removeWords, rev.default(stopwords('english')))  #reverse order to get contractions
corp <- tm_map(corp, removePunctuation)   #remove after stopwords because many contractions are stop words
corp <- tm_map(corp, stripWhitespace)

#hopefully this writes all that text to 1 file...
write(as.character(corp[[1]][1],"Chinese_reviews.txt"))

#This section of code inspired by the class forum (thanks Juan Luis Herrera Cortijo!)
#https://class.coursera.org/dataminingcapstone-001/forum/thread?thread_id=124

#word2vec doesn't work without pthread.h which isn't used by windows so use cygwin64
#terminal window instead

#before this works you have to download, compile word2vec.c and word2phrase.c from Google:
#https://code.google.com/p/word2vec/
#compile this by opening cygwin64 terminal, navigating to the folder and run 'make'

#Add the folder where the compiled .exe files are to the list of PATH variables
#http://stackoverflow.com/questions/10235125/linux-custom-executable-globally-available
# confirm PATH variables this way 'echo $PATH'

#This code just generates the text I coplied into the cygwin64 terminal
training.file <- "Chinese_reviews.txt"
output.file.phrases <- "Chinese_Phrases.txt"
output.file.text <- "Chinese_Model.txt"

# Run the output of these next 2 lines in the cygwin64 terminal
paste0("word2phrase -train ",training.file," -output ",output.file.phrases)
paste0("word2vec -train ",output.file.phrases," -output ",output.file.text," -binary 0")

# Read the vectors
vectors <- read.table(output.file.text,skip = 1, stringsAsFactors = FALSE)

# Get the terms
words <- vectors[,1]

# Transform to a matrix
vectors <- as.matrix(vectors[,-1])

# Get most similar terms to other dishes found
dishes <- read.table("./manualAnnotationTask/Chinese_Flat.txt")
dishes <- as.character(dishes[,1])
dishes.final <- as.data.frame(matrix(c("Chinese",100),nrow=1,ncol=2))
names(dishes.final) <- c("dish", "cosine")
dishes.final[,"cosine"] <- as.numeric(dishes.final[,"cosine"])
#dishes.final <- rbind(dishes.final,as.data.frame(matrix(c(dishes,
#                                    rep(1, length(dishes))),ncol=2)))
temp <- as.data.frame(matrix(c(dishes,rep(0, length(dishes))),ncol=2))
names(temp) <- c("dish", "cosine")
dishes.final <- rbind(dishes.final,temp)
for (dish in dishes){
  if(is.element(dish,words)){
        v <- vectors[which(words==dish),] 
        sim <- apply(vectors,1,function(d) cosine(v,d))
        sim.dishes <- head(data.frame(Word=words[order(sim,decreasing = TRUE)],
                                      Cosine=sim[order(sim,decreasing = TRUE)])[-1,],50)
        names(sim.dishes) <- c("dish", "cosine")
        dishes.final <- rbind(dishes.final, sim.dishes)      
  }
}

dishes.final[,'cosine'] <- as.numeric(dishes.final[,'cosine'])
dishes.final <- dishes.final[with(dishes.final, order(-cosine)), ]

dishes.final <- unique(unlist(as.character(dishes.final[,1]), use.names = FALSE))
write(dishes.final,"Task 3.2 Submission.txt")
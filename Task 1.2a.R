##Task 1.2 for Coursera Data Mining Capstone

##Note that the Yelp! data set used in this analysis can be downloaded here:
##  https://www.yelp.ca/dataset_challenge/dataset

#set working directory (change this to the local repository where you fork this code)
setwd("C:/Users/jed.isom/version-control/Yelp-projects")

#load libraries that will be needed later in the script
library("pacman")
pacman::p_load(jsonlite, tm, topicmodels, slam, dplyr)

#load review data from JSON file
rm(list=ls())
json_file <- "yelp_academic_dataset_review.JSON"
review <- fromJSON(sprintf("[%s]", paste(readLines(json_file), collapse=",")))

#Find the most reviewed restaurant (3695 reviews)
t=as.data.frame(table(review$business_id))
temp <- head(t[order(-t$Freq), ],10)
most_reviewed <- as.character(temp[1,1])    #4bEjOyTaDG24SY5TxsaUNQ

#subset reviews for this rest. & determine the median rating
review1 <- review[review$business_id == most_reviewed, ]
rm(review)  #remove the review variable to same space in RAM
rev_med <- median(review1$stars)
review_good <- review1[review1$stars >= rev.med, ]
review_bad <- review1[review1$stars < rev.med, ]

#Turn text into Corpus and clean up before applying model
corp_good <- Corpus(VectorSource(review_good$text))
corp_good <- tm_map(corp_good, removeNumbers)
corp_good <- tm_map(corp_good, content_transformer(tolower))    #lower case needs to be before stopwords
corp_good <- tm_map(corp_good, removeWords, rev.default(stopwords('english')))  #reverse order to get contractions
corp_good <- tm_map(corp_good, removePunctuation)   #remove after stopwords because many contractions are stop words
corp_good <- tm_map(corp_good, stripWhitespace)
corp_good <- tm_map(corp_good, stemDocument)

corp_bad <- Corpus(VectorSource(review_bad$text))
corp_bad <- tm_map(corp_bad, removeNumbers)
corp_bad <- tm_map(corp_bad, content_transformer(tolower))    #lower case needs to be before stopwords
corp_bad <- tm_map(corp_bad, removeWords, rev.default(stopwords('english')))  #reverse order to get contractions
corp_bad <- tm_map(corp_bad, removePunctuation)   #remove after stopwords because many contractions are stop words
corp_bad <- tm_map(corp_bad, stripWhitespace)
corp_bad <- tm_map(corp_bad, stemDocument)

#turn Corpus into "DocumentTermMatrix" class
dtm_good <- DocumentTermMatrix(corp_good)
rowTotals_good <- as.data.frame(as.matrix(rollup(dtm_good, 2, na.rm=TRUE, FUN = sum)))
dtm_good   <- dtm_good[rowTotals_good> 0, ] #remove all docs without words
rm(corp_good) #remove corpus to save RAM

dtm_bad <- DocumentTermMatrix(corp_bad)
rowTotals_bad <- as.data.frame(as.matrix(rollup(dtm_bad, 2, na.rm=TRUE, FUN = sum)))
dtm_bad   <- dtm_bad[rowTotals.bad> 0, ]
rm(corp_bad) #remove corpus to save RAM

#create LDA model based on dtm
topics_good <- LDA(dtm_good, 10, method = "Gibbs")
topics_bad <- LDA(dtm_bad, 5, method = "Gibbs")
rm(dtm_good)  #remove dtm to save RAM
rm(dtm_bad)  #remove dtm to save RAM

#Get probabilities for words in Corpus for each topic
topic_prob_good <- as.data.frame(t(posterior(topics_good)$terms))
topic_prob_bad <- as.data.frame(t(posterior(topics_bad)$terms))

#Turn words/terms and probabilities into data frames for future use...
top_topic_words_good <- NULL
for (i in 1:length(names(topic_prob_good))){
      temp <- head(topic_prob_good[order(-topic_prob_good[,i]), ],10)
      wordColTitle <- paste("topic_",i,"_words",sep="")
      probColTitle <- paste("topic_",i,"_prob",sep="")
      
      if (is.null(top_topic_words_good)){
            top_topic_words_good <- as.data.frame(row.names(temp))
            names(top_topic_words_good)[1] <- wordColTitle
      } else{
            top_topic_words_good[,wordColTitle] <- as.data.frame(row.names(temp))      
      }
      top_topic_words_good[,probColTitle] <- temp[,i]
}

top_topic_words_bad <- NULL
for (i in 1:length(names(topic_prob_bad))){
      temp <- head(topic_prob_bad[order(-topic_prob_bad[,i]), ],10)
      wordColTitle <- paste("topic_",i,"_words",sep="")
      probColTitle <- paste("topic_",i,"_prob",sep="")
      
      if (is.null(top_topic_words_bad)){
            top_topic_words_bad <- as.data.frame(row.names(temp))
            names(top_topic_words_bad)[1] <- wordColTitle
      } else{
            top_topic_words_bad[,wordColTitle] <- as.data.frame(row.names(temp))      
      }
      top_topic_words_bad[,probColTitle] <- temp[,i]
}

#write data to hard drive just in case of crash
write.csv(top_topic_words_good, "Task 1.2a Output.csv") #file with good review probs.
write.csv(top_topic_words_bad, "Task 1.2b Output.csv")  #file with bad review probs.

#recover, start over from here if crash occurs
rm(list=ls())
top_topic_words_good <- read.csv("Task 1.2a Output.csv", header = TRUE)
top_topic_words_bad <- read.csv("Task 1.2b Output.csv", header = TRUE)

##This section of the code takes the data and puts it into network
##format for data visualization purposes

#Initialize data frames for storing links and nodes
links <- data.frame(0,0)
colnames(links) <- c("From", "To")
nodes <- as.data.frame(matrix(c("Top Rest.", 1, "black"), nrow=1, ncol=3))
names(nodes) <- c("Node", "Intensity", "Color")
nodes[, 1] <- sapply(nodes[, 1], as.character)
nodes[, 2] <- sapply(nodes[, 2], as.numeric)
nodes[, 3] <- sapply(nodes[, 3], as.character)

topic_colors <- rainbow(17)

#create link/nodes from root to good and bad review nodes
links[1,] <- rbind(c("Top Rest.","Good Review"))
links[2,] <- rbind(c("Top Rest.","Bad Review"))
nodes <- rbind(nodes,c("Good Review", 1, "forestgreen"))
nodes <- rbind(nodes,c("Bad Review", 1, "darkred"))

#setup the links to the good and bad nodes
for (i in 1:10){  
      links <- rbind(links, c("Good Review",paste("Topic ",i,"g", sep="")))
}
for (i in 1:5){
      links <- rbind(links, c("Bad Review",paste("Topic ",i,"b", sep="")))
}

#Link each of the topics to their top 10 words and add node to node data frame
#...for good reviews
for (i in 1:10){  # cycle through all the topics
      nodes <- rbind(nodes,c(paste("Topic ",i,"g", sep=""), 1, topic_colors[i+1]))
      for (j in 1:10){  # cycle through the top 10 words in each topic
            word_col <- paste("topic_",i,"_words", sep="")
            prob_col <- paste("topic_",i,"_prob", sep="")
            word <- paste(i,"g: ",as.character(top_topic_words_good[j,word_col]),sep="")
            
            #Scale color intensity by the highest probability word in the topic
            if (j==1) {
                  max.prob = as.numeric(top_topic_words_good[1,prob_col])
            }
            prob <- as.numeric(top_topic_words_good[j,prob_col])/max.prob
            links <- rbind(links, c(paste("Topic ",i,"g", sep=""),word))
            nodes <- rbind(nodes,c(word,prob, topic_colors[i+1])) 
      }
}
#...and bad
for (i in 1:5){  # cycle through all the topics
      nodes <- rbind(nodes,c(paste("Topic ",i,"b", sep=""), 1, topic_colors[i+11]))
      for (j in 1:10){  # cycle through the top 10 words in each topic
            word_col <- paste("topic_",i,"_words", sep="")
            prob_col <- paste("topic_",i,"_prob", sep="")
            word <- paste(i,"b: ",as.character(top_topic_words_bad[j,word_col]),sep="")
            
            #Scale color intensity by the highest probability word in the topic
            if (j==1) {
                  max.prob = as.numeric(top_topic_words_bad[1,prob_col])
            }
            prob <- as.numeric(top_topic_words_bad[j,prob_col])/max.prob
            links <- rbind(links, c(paste("Topic ",i,"b", sep=""),word))
            nodes <- rbind(nodes,c(word,prob, topic_colors[i+11])) 
      }
}

#create variable for transparent colors based on word probability
rgb_transp <- t(col2rgb(nodes$Color))
nodes[,"r"] <- rgb_transp[,1]/255
nodes[,"g"] <- rgb_transp[,2]/255
nodes[,"b"] <- rgb_transp[,3]/255
nodes[,"t.color"]=NULL
for (i in 1:dim(nodes)[1]){
      nodes[i,"t.color"] <- rgb(red = nodes[i,"r"], 
                                blue = nodes[i,"g"], 
                                green = nodes[i,"b"],
                                alpha = nodes[i,"Intensity"])
}
#make sure the variable is the right class for a color
nodes[, "t.color"] <- sapply(nodes[, "t.color"], as.character)

#create variable for font color for good contrast
nodes$f.color = rgb(0,0,0)    #default is black
nodes[1,"f.color"] = rgb(1,1,1)
nodes[2,"f.color"] = rgb(1,1,1)
nodes[3,"f.color"] = rgb(1,1,1)
for (i in 37:42){
      nodes[i,"f.color"] = rgb(1,1,1)      
}
for (i in 48:63){
      nodes[i,"f.color"] = rgb(1,1,1)      
}
for (i in 70:71){
      nodes[i,"f.color"] = rgb(1,1,1)      
}

#create variable that will control the width of the rectangle plotted
nodes[,"rect.width"] = ceiling(1.8*nchar(nodes[,1])-4)

#Now we start to use igraph to plot the "network" to visualize it
net <- graph.data.frame(links, nodes, directed=FALSE)
V(net)$frame.color="black"
V(net)$label=nodes$Node
V(net)$color <- nodes$t.color
l<-layout.fruchterman.reingold(net) #Use this layout sytle as a starting point
plot.id <- tkplot(net, layout = l, vertex.size = 12,
                  vertex.label.color="black", vertex.label.font = 3)

#manual adjustment of plot in tkplot here
nl<-tk_coords(plot.id)
write.csv(nl, "task 1.2 layout.csv")      #save on hard drive just in case
#nl <- read.csv("task 1.2 layout.csv", header = TRUE)  #read layout back in if needed
tk_close
plot(net, layout = nl, vertex.shape = "rectangle", vertex.size = nodes$rect.width,  
     vertex.size2 = 6, vertex.label.color=nodes$f.color, vertex.label.font = 3,
     asp = .5)
#zoom in on the plot and then print screen and save
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
most.reviewed <- as.character(temp[1,1])    #4bEjOyTaDG24SY5TxsaUNQ

#subset reviews for this rest. & determine the median rating
review1 <- review[review$business_id == most.reviewed, ]
rm(review)  #remove the review variable to same space in RAM
rev.med <- median(review1$stars)
review.good <- review1[review1$stars >= rev.med, ]
review.bad <- review1[review1$stars < rev.med, ]

#Turn text into Corpus and clean up before applying model
corp.good <- Corpus(VectorSource(review.good$text))
corp.good <- tm_map(corp.good, removeNumbers)
corp.good <- tm_map(corp.good, content_transformer(tolower))    #lower case needs to be before stopwords
corp.good <- tm_map(corp.good, removeWords, rev.default(stopwords('english')))  #reverse order to get contractions
corp.good <- tm_map(corp.good, removePunctuation)   #remove after stopwords because many contractions are stop words
corp.good <- tm_map(corp.good, stripWhitespace)
corp.good <- tm_map(corp.good, stemDocument)

corp.bad <- Corpus(VectorSource(review.bad$text))
corp.bad <- tm_map(corp.bad, removeNumbers)
corp.bad <- tm_map(corp.bad, content_transformer(tolower))    #lower case needs to be before stopwords
corp.bad <- tm_map(corp.bad, removeWords, rev.default(stopwords('english')))  #reverse order to get contractions
corp.bad <- tm_map(corp.bad, removePunctuation)   #remove after stopwords because many contractions are stop words
corp.bad <- tm_map(corp.bad, stripWhitespace)
corp.bad <- tm_map(corp.bad, stemDocument)

#turn Corpus into "DocumentTermMatrix" class
dtm.good <- DocumentTermMatrix(corp.good)
rowTotals.good <- as.data.frame(as.matrix(rollup(dtm.good, 2, na.rm=TRUE, FUN = sum)))
dtm.good   <- dtm.good[rowTotals.good> 0, ] #remove all docs without words
rm(corp.good) #remove corpus to save RAM

dtm.bad <- DocumentTermMatrix(corp.bad)
rowTotals.bad <- as.data.frame(as.matrix(rollup(dtm.bad, 2, na.rm=TRUE, FUN = sum)))
dtm.bad   <- dtm.bad[rowTotals.bad> 0, ]
rm(corp.bad) #remove corpus to save RAM

#create LDA model based on dtm
topics.good <- LDA(dtm.good, 10, method = "Gibbs")
topics.bad <- LDA(dtm.bad, 5, method = "Gibbs")
rm(dtm.good)  #remove dtm to save RAM
rm(dtm.bad)  #remove dtm to save RAM

#Get probabilities for words in Corpus for each topic
topic.prob.good <- as.data.frame(t(posterior(topics.good)$terms))
topic.prob.bad <- as.data.frame(t(posterior(topics.bad)$terms))

#Turn words/terms and probabilities into data frames for future use...
top.topic.words.good <- NULL
for (i in 1:length(names(topic.prob.good))){
      temp <- head(topic.prob.good[order(-topic.prob.good[,i]), ],10)
      wordColTitle <- paste("topic.",i,".words",sep="")
      probColTitle <- paste("topic.",i,".prob",sep="")
      
      if (is.null(top.topic.words.good)){
            top.topic.words.good <- as.data.frame(row.names(temp))
            names(top.topic.words.good)[1] <- wordColTitle
      } else{
            top.topic.words.good[,wordColTitle] <- as.data.frame(row.names(temp))      
      }
      top.topic.words.good[,probColTitle] <- temp[,i]
}

top.topic.words.bad <- NULL
for (i in 1:length(names(topic.prob.bad))){
      temp <- head(topic.prob.bad[order(-topic.prob.bad[,i]), ],10)
      wordColTitle <- paste("topic.",i,".words",sep="")
      probColTitle <- paste("topic.",i,".prob",sep="")
      
      if (is.null(top.topic.words.bad)){
            top.topic.words.bad <- as.data.frame(row.names(temp))
            names(top.topic.words.bad)[1] <- wordColTitle
      } else{
            top.topic.words.bad[,wordColTitle] <- as.data.frame(row.names(temp))      
      }
      top.topic.words.bad[,probColTitle] <- temp[,i]
}

#write data to hard drive just in case of crash
write.csv(top.topic.words.good, "Task 1.2a Output.csv") #file with good review probs.
write.csv(top.topic.words.bad, "Task 1.2b Output.csv")  #file with bad review probs.

#recover, start over from here if crash occurs
rm(list=ls())
top.topic.words.good <- read.csv("Task 1.2a Output.csv", header = TRUE)
top.topic.words.bad <- read.csv("Task 1.2b Output.csv", header = TRUE)

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

topic.colors <- rainbow(17)

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
      nodes <- rbind(nodes,c(paste("Topic ",i,"g", sep=""), 1, topic.colors[i+1]))
      for (j in 1:10){  # cycle through the top 10 words in each topic
            word.col <- paste("topic.",i,".words", sep="")
            prob.col <- paste("topic.",i,".prob", sep="")
            word <- paste(i,"g: ",as.character(top.topic.words.good[j,word.col]),sep="")
            
            #Scale color intensity by the highest probability word in the topic
            if (j==1) {
                  max.prob = as.numeric(top.topic.words.good[1,prob.col])
            }
            prob <- as.numeric(top.topic.words.good[j,prob.col])/max.prob
            links <- rbind(links, c(paste("Topic ",i,"g", sep=""),word))
            nodes <- rbind(nodes,c(word,prob, topic.colors[i+1])) 
      }
}
#...and bad
for (i in 1:5){  # cycle through all the topics
      nodes <- rbind(nodes,c(paste("Topic ",i,"b", sep=""), 1, topic.colors[i+11]))
      for (j in 1:10){  # cycle through the top 10 words in each topic
            word.col <- paste("topic.",i,".words", sep="")
            prob.col <- paste("topic.",i,".prob", sep="")
            word <- paste(i,"b: ",as.character(top.topic.words.bad[j,word.col]),sep="")
            
            #Scale color intensity by the highest probability word in the topic
            if (j==1) {
                  max.prob = as.numeric(top.topic.words.bad[1,prob.col])
            }
            prob <- as.numeric(top.topic.words.bad[j,prob.col])/max.prob
            links <- rbind(links, c(paste("Topic ",i,"b", sep=""),word))
            nodes <- rbind(nodes,c(word,prob, topic.colors[i+11])) 
      }
}

#create variable for transparent colors based on word probability
rgb.transp <- t(col2rgb(nodes$Color))
nodes[,"r"] <- rgb.transp[,1]/255
nodes[,"g"] <- rgb.transp[,2]/255
nodes[,"b"] <- rgb.transp[,3]/255
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
##Task 1.1

#load libraries that will be needed later in the script
library("pacman")
pacman::p_load(jsonlite, tm, topicmodels, slam, igraph, dplyr)

#load review data from JSON file
rm(list=ls())     #remove any variables from R environment to save RAM
json_file <- "yelp_academic_dataset_review.JSON"
review <- fromJSON(sprintf("[%s]", paste(readLines(json_file), collapse=",")))
#randomly sample ~1/20 of the reviews to make computation faster
set.seed(1)
review[,"sample"] <- rbinom(n=dim(review)[1], size=1, prob=.05)

#Turn text into Corpus and clean up before applying model
#only take first 5000 results due to processing time
corp <- Corpus(VectorSource(head(review[review$sample==1,"text"],5000)))
rm(review)  #remove the review variable to same space in RAM
corp <- tm_map(corp, removeNumbers)
corp <- tm_map(corp, content_transformer(tolower))    #lower case needs to be before stopwords
corp <- tm_map(corp, removeWords, rev.default(stopwords('english')))  #reverse order to get contractions
corp <- tm_map(corp, removePunctuation)   #remove after stopwords because many contractions are stop words
corp <- tm_map(corp, stripWhitespace)
corp <- tm_map(corp, stemDocument)

#turn Corpus into "DocumentTermMatrix" class
dtm <- DocumentTermMatrix(corp)
rowTotals <- as.data.frame(as.matrix(rollup(dtm, 2, na.rm=TRUE, FUN = sum)))
dtm   <- dtm[rowTotals> 0, ] #remove all docs without words
rm(corp) #remove corpus to save RAM

#create LDA model based on dtm
topics <- LDA(dtm, 10, method = "Gibbs")
rm(dtm)  #remove dtm to save RAM

#Get probabilities for words in Corpus for each topic
topic.prob <- as.data.frame(t(posterior(topics)$terms))

#topic.prob[order(topic.prob$topic1), ]
top.topic.words <- NULL
for (i in 1:length(names(topic.prob))){
      temp <- head(topic.prob[order(-topic.prob[,i]), ],10)
      wordColTitle <- paste("topic_",i,"_words",sep="")
      probColTitle <- paste("topic_",i,"_prob",sep="")
      
      if (is.null(top.topic.words)){
            top.topic.words <- as.data.frame(row.names(temp))
            names(top.topic.words)[1] <- wordColTitle
      } else{
            top.topic.words[,wordColTitle] <- as.data.frame(row.names(temp))      
      }
      top.topic.words[,probColTitle] <- temp[,i]
}

# Output to .csv file type just in case
write.csv(top.topic.words, "Task 1.1 Output.csv")
top.topic.words <- read.csv("Task 1.1 Output.csv", header = TRUE)

##This section of the code takes the data and puts it into network
##format for data visualization purposes

#Initialize data frames for storing links and nodes
links <- data.frame(0,0)
colnames(links) <- c("From", "To")
nodes <- as.data.frame(matrix(c("Root", 1, "black"), nrow=1, ncol=3))
names(nodes) <- c("Node", "Intensity", "Color")
nodes[, 1] <- sapply(nodes[, 1], as.character)
nodes[, 2] <- sapply(nodes[, 2], as.numeric)
nodes[, 3] <- sapply(nodes[, 3], as.character)
topic.colors <- c("gray", "purple", "blue", "cyan", "green", "yellow", "orange", "brown", 
                  "red", "pink")

#setup the links to the root node
for (i in 1:10){  
      if(i == 1){
            links[1,] <- rbind(c("Root",paste("Topic",i)))
      } else{
            links <- rbind(links, c("Root",paste("Topic",i)))
      }
}

#Link each of the topics to their top 10 words and add node to node data frame
for (i in 1:10){  # cycle through all the topics
      nodes <- rbind(nodes,c(paste("Topic",i), 1, topic.colors[i]))
      for (j in 1:10){  # cycle through the top 10 words in each topic
            word.col <- paste("topic_",i,"_words", sep="")
            prob.col <- paste("topic_",i,"_prob", sep="")
            word <- paste(i,": ",as.character(top.topic.words[j,word.col]),sep="")
            
            #Scale color intensity by the highest probability word in the topic
            if (j==1) {
                  max.prob = as.numeric(top.topic.words[1,prob.col])
            }
            prob <- as.numeric(top.topic.words[j,prob.col])/max.prob
            links <- rbind(links, c(paste("Topic",i),word))
            nodes <- rbind(nodes,c(word,prob, topic.colors[i]))            
      }
}

#create variable for transparent colors
rgb.transp <- t(col2rgb(nodes$Color))
nodes[,"r"] <- rgb.transp[,1]/255
nodes[,"g"] <- rgb.transp[,2]/255
nodes[,"b"] <- rgb.transp[,3]/255
nodes[,"t.color"]=NULL
for (i in 1:dim(nodes)[1]){
      if (i==2){
            #make sure the variable is the right class for a color
            nodes[, "t.color"] <- sapply(nodes[, "t.color"], as.character)
      }
      nodes[i,"t.color"] <- rgb(red = nodes[i,"r"], 
                                blue = nodes[i,"g"], 
                                green = nodes[i,"b"],
                                alpha = nodes[i,"Intensity"])
}

#create variable for font color for good contrast
nodes$f.color = rgb(0,0,0)    #default is black
nodes[1,"f.color"] = rgb(1,1,1)
nodes[46,"f.color"] = rgb(1,1,1)
nodes[47,"f.color"] = rgb(1,1,1)
nodes[48,"f.color"] = rgb(1,1,1)

#Now we start to use igraph to plot the "network" to visualize it
net <- graph.data.frame(links, nodes, directed=FALSE)
V(net)$frame.color="black"
V(net)$label=nodes$Node
V(net)$color <- nodes$t.color
l<-layout.fruchterman.reingold(net) #Use this layout sytle as a starting point
plot.id <- tkplot(net, layout = l, vertex.shape = "rectangle", vertex.size = 20,
                  vertex.size2 = 10, vertex.label.color="black")
#manual adjustment of plot in tkplot here
nl<-tk_coords(plot.id)
write.csv(nl, "task 1.1 layout.csv")      #save on hard drive just in case
tk_close
plot(net, layout = nl, vertex.shape = "rectangle", vertex.size = 25,  
     vertex.size2 = 5, vertex.label.color=nodes$f.color)
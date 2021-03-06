##Task 1.1 for Coursera Data Mining Capstone
##Note that the Yelp! data set used in this analysis can be downloaded here:
##  https://www.yelp.ca/dataset_challenge/dataset

#set working directory (change this to the local repository where you fork this code)
setwd("C:/Users/jed.isom/version-control/Yelp-projects")

#load libraries that will be needed later in the script
library("pacman")
pacman::p_load(jsonlite, tm, topicmodels, slam, igraph, dplyr)

LoadData <- function(json.file) {

	#load review data from JSON file
	rm(list=ls())     #remove any variables from R environment to save RAM
	
	review <- fromJSON(sprintf("[%s]", paste(readLines(json.file), collapse=",")))
	#randomly sample ~1/20 of the reviews to make computation faster
	set.seed(1)
	review[,"sample"] <- rbinom(n=dim(review)[1], size=1, prob=.05)
	return (review)
}
	
CleanText <- function(review) {
	
	#Turn text into Corpus and clean up before applying model
	#only take first 5000 results due to processing time
	corp <- Corpus(VectorSource(head(review[review$sample==1,"text"],5000)))
	corp <- tm_map(corp, removeNumbers)                   #remove numbers
	corp <- tm_map(corp, content_transformer(tolower))    #lower case needs to be before stopwords
	corp <- tm_map(corp, removeWords, rev.default(stopwords('english')))  #reverse order to get contractions
	corp <- tm_map(corp, removePunctuation)   #remove after stopwords because many contractions are stop words
	corp <- tm_map(corp, stripWhitespace) 
	corp <- tm_map(corp, stemDocument)

	#turn Corpus into "DocumentTermMatrix" class
	dtm <- DocumentTermMatrix(corp)
	rowTotals <- as.data.frame(as.matrix(rollup(dtm, 2, na.rm=TRUE, FUN = sum)))
	dtm   <- dtm[rowTotals> 0, ] #remove all docs without words
	
	return (dtm)
}

CreateTopTopics <- function(dtm) {
	#create LDA model based on dtm
      print ("finding topics...")
	topics <- LDA(dtm, 10, method = "Gibbs")
	
      #Get probabilities for words in Corpus for each topic
	print ("Putting top topics into dataframe..")
      topic.prob <- as.data.frame(t(posterior(topics)$terms))

	#topic.prob[order(topic.prob$topic1), ]
	top.topic.words <- NULL
	for (i in 1:length(names(topic.prob))){
		  temp <- head(topic.prob[order(-topic.prob[,i]), ],10)
		  wordColTitle <- paste("topic.",i,".words",sep="")
		  probColTitle <- paste("topic.",i,".prob",sep="")
		  
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
      
      return (top.topic.words)
}

#This function was copied and pasted from this URL
#https://stat.ethz.ch/pipermail/r-help/2004-June/053343.html
list <- structure(NA,class="result")
"[<-.result" <- function(x,...,value) {
      args <- as.list(match.call())
      args <- args[-c(1:2,length(args))]
      length(value) <- length(args)
      for(i in seq(along=args)) {
            a <- args[[i]]
            if(!missing(a)) eval.parent(substitute(a <- v,list(a=a,v=value[[i]])))
      }
      x
}

CreateNetwork <- function(top.topic.words){
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
				word.col <- paste("topic.",i,".words", sep="")
				prob.col <- paste("topic.",i,".prob", sep="")
				word <- paste(i,": ",as.character(top.topic.words[j,word.col]),sep="")
				
				#Scale color intensity by the highest probability word in the topic
				if (j==1) {
					  max.prob = as.numeric(top.topic.words[1,prob.col])
				}
				prob <- as.numeric(top.topic.words[j,prob.col])/max.prob
				links <- rbind(links, c(paste("Topic",i),word))
				nodes <- rbind(nodes,c(word, prob, topic.colors[i]))            
		  }
	}
    
	net <- list(nodes, links)
	return (net)
}

CreateVisualization <- function(nodes, links){

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

	#I manually adjusted the plot in tkplot here to get the spacing I wanted
	#Create pause in code: http://stackoverflow.com/questions/15272916/how-to-wait-for-a-keypress-in-r
	invisible(readline(prompt="Adjust node locations as desired then, press [enter] to continue"))
      
	nl<-tk_coords(plot.id)
	write.csv(nl, "task 1.1 layout.csv")      #save on hard drive just in case
	tk_close
	plot(net, layout = nl, vertex.shape = "rectangle", vertex.size = 25,  
	     vertex.size2 = 5, vertex.label.color=nodes$f.color)
}

json.file <- "yelp_academic_dataset_review.JSON"
review <- LoadData(json.file)
dtm <- CleanText(review)
rm(review)  #remove the review variable to same space in RAM
top.topic.words <- CreateTopTopics(dtm)
rm(dtm)  #remove dtm to save RAM
#top.topic.words <- read.csv("Task 1.1 Output.csv", header = TRUE)
list[nodes, links] <- CreateNetwork(top.topic.words)
CreateVisualization(nodes, links)


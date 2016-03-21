#Coursera Data Mining Capstone - UIUC
#Task 4
#Jed Isom
#September 28, 2015

library("pacman")
pacman::p_load(jsonlite, tm, SDMTools, Hmisc, plyr)

rm(list=ls())
setwd("./Capstone/Raw Data")

json_file <- "yelp_academic_dataset_business.JSON"
#took this line of code from http://stackoverflow.com/questions/26519455/error-parsing-json-file-with-the-jsonlite-package
business <- fromJSON(sprintf("[%s]", paste(readLines(json_file), collapse=",")))
#this lists information about the businesses (location, hours, category, name, some attributes)

json_file <- "yelp_academic_dataset_review.JSON"
review <- fromJSON(sprintf("[%s]", paste(readLines(json_file), collapse=",")))
#list reviews by businesses

#add boolean variable to business is.chinese
#quick and dirty code for this, but only takes a couple seconds
for (i in 1:dim(business)[1]){
  business[i,"is.chinese"] = is.element("Chinese", business[i,"categories"][[1]])
}

#subset business dataframe for just restaurants
business <- business[business[,"is.chinese"]==TRUE,]

#consolidate all of the reviews for Chinese into 1 "document"
#get list of businesses that have that Chinese
bus.list <- business[,"business_id"]

#get list of star ratings and reviews for those businesses
rev.list <- review[is.element(review[,"business_id"],bus.list),
                   c("review_id", "business_id", "stars", "text")]
rm(review) #delete review variable to save RAM

#Turn text into Corpus and clean up before creating document term matrix
myReader <- readTabular(mapping=list(content="text", id="review_id", 
                                     business="business_id", rating="stars"))
corp <- VCorpus(DataframeSource(rev.list), readerControl=list(reader=myReader))
corp <- tm_map(corp, removeNumbers)
corp <- tm_map(corp, content_transformer(tolower))    #lower case needs to be before stopwords
corp <- tm_map(corp, removePunctuation)   #remove after stopwords because many contractions are stop words
corp <- tm_map(corp, stripWhitespace)

##This section will load a list of known dishes for Chinese cuisine and then count the average times each
##dish is mentioned in reviews for each business, as well as the average star rating for reviews that
##contain that dish

#function I created to count the number of times a phrase/term is found in text.
strcount <- function(pattern, string){ 
      #assumes all numbers have already been removed from the text
      temp.text <- gsub(pattern, "1", string)        #replace the pattern with #1
      temp.text2 <- gsub("1", "", temp.text)    #replace 1 with ""
      return(nchar(temp.text)-nchar(temp.text2)) #get the difference in length of the character
}

#load the list of known Chinese dishes
dishes <- as.list(read.table("Task 4 dish list.txt", header=FALSE, colClasses="character"))
dishes <- dishes[[1]]
dishes <- gsub("_", " ", dishes)  #replace '_' with a space (' ')
dishes <- gsub("\\d", "", dishes) #remove numbers (just in case)

#Create data frame to keep scores/counts for each dish
dish.score <- data.frame(dish="place", review = "holder", business="values", dish.count=-1, stars=-2)
dish.score[,1:3] <- as.character(dish.score[,1:3])
dish.score[,4:5] <- as.character(dish.score[,4:5])

#Initialize some variable before looping through reviews to get scores
rev.count <- dim(rev.list)[1]
first.loop <- TRUE

#loop through all the Chinese reviews
for (rev in 1:rev.count){
      
      #print number of current review of the user to keep track of progress
      print(paste("review ", rev, " of ", rev.count))
      
      #count how many times the dish is in the review
      count <- unlist(lapply(X = dishes, FUN = strcount, string=as.character(corp[[rev]]$content)))
      non.zero.vector <- count > 0  #create boolean vector of dishes found in this review
      non.zero.count <- sum(non.zero.vector, na.rm=TRUE) #count of different dishes found
      
      #Only add record if a dish is found in that review
      if (max(count) > 0){
            #overwrite NA's if it's the first review
            if(first.loop == TRUE){
                  
                  first.loop <- FALSE
                  
                  #populate a row of data for each dish found in the review
                  dish.score[1:non.zero.count,1] <- dishes[non.zero.vector]
                  dish.score[1:non.zero.count,2] <- rep(corp[[rev]]$meta$id,non.zero.count)
                  dish.score[1:non.zero.count,3] <- rep(corp[[rev]]$meta$business,non.zero.count)
                  dish.score[1:non.zero.count,4] <- count[non.zero.vector]
                  dish.score[1:non.zero.count,5] <- rep(corp[[rev]]$meta$rating,non.zero.count)
                  
            } else { #Otherwise...
                  
                  next.row <- dim(dish.score)[1]+1
                  last.row <- next.row + non.zero.count - 1
                  
                  dish.score[next.row:last.row, 1] <- dishes[non.zero.vector]
                  dish.score[next.row:last.row, 2] <- rep(corp[[rev]]$meta$id,non.zero.count)
                  dish.score[next.row:last.row, 3] <- rep(corp[[rev]]$meta$business,non.zero.count)
                  dish.score[next.row:last.row, 4] <- count[non.zero.vector]
                  dish.score[next.row:last.row, 5] <- rep(corp[[rev]]$meta$rating,non.zero.count)
                  
            }      
      }
}

#write dish.score to file just in case
write.csv(dish.score, file = "Task4 dish scores.csv")

#fix class type of a couple columns
dish.score[,"dish.count"] <- as.numeric(dish.score[,"dish.count"])
dish.score[,"stars"] <- as.numeric(dish.score[,"stars"])

dish.results <- as.data.frame(table(dish.score$dish))
names(dish.results) <- c("dish", "review count")
dish.results[,"chatter"] <- tapply(dish.score$dish.count, dish.score$dish, FUN=sum) #count of mentions of dishes in reviews
dish.results[,"average rating"] <- tapply(dish.score$stars, dish.score$dish, FUN=mean) #average star rating for reviews where each dish is mentioned
dish.results[,"stdev rating"] <- tapply(dish.score$stars, dish.score$dish, FUN=sd)

#write dish.score to file just in case
write.csv(dish.results, file = "Task4 dish results.csv")

###
###This section creates the visualizations for Task 4
###

#do plot for visualization purposes
palette <- colorRampPalette(c("pink", "dark red"), alpha = .5)
max.review <- max(dish.results[,"review count"])
colorCuts <- cut(dish.results[,"review count"],breaks = floor(max.review/100)) #Max review count is 4715
dish.results$Col <- palette(floor(max.review/100))[as.numeric(colorCuts)]

##Create Plot for Raw Dish Count in the corpus (I called this the "chatter" about the dish)
#sort dish.results by chatter variable
dish.results <- dish.results[order(-dish.results[,"chatter"]),]

#setup and show plot
par(mgp = c(3, 1, 0)) #moves label positions; default is c(3, 1, 0)
par(mar=c(6.3, 4.1, 4.1, 2.1)) #changes dimensions of the plot (bottom, left, top, right)
par(opa=c(0,0,0,0)) #This is the default
barplot(head(dish.results$chatter,100), main="Top 100 Dishes Mentioned in Chinese Reviews", 
        xlab="", ylab= "# of Mentions in Reviews", col = dish.results$Col, cex.names = .6, las=2)

#print the x axis title to the plot seperately to get the spacing of the text right
mtext("Dishes", 1, 4.5, cex = 1.4)

#Create and show gradient legend for colors of bars in the chart
pnts = cbind(x =c(70,77,77,70), y =c(6000,6000,3000,3000))
legend.colors <- palette(floor(max.review/100))[1:47]
legend.gradient(pnts, cols = legend.colors, limits = c(1, max.review), 
                title = "Reviews w/ Dish")

##Setup plot showing average star rating of reviews that contain each dish
#sort dish.results by chatter variable
dish.results <- dish.results[order(-dish.results[,"average rating"]),]

#setup and show plot
par(mgp = c(3, 1, 0)) #moves label positions; default is c(3, 1, 0)
par(mar=c(10, 4.1, 4.1, 2.1)) #changes dimensions of the plot (bottom, left, top, right)
par(opa=c(0,0,0,0)) #This is the default
barplot(head(dish.results[,"average rating"],100), main="Top 100 Dishes' Mean Star Rating", 
        xlab="", ylab= "Mean review rating w/ dish mentioned", col = dish.results$Col, cex.names = .6, 
        las=2, ylim=c(3.5,4.75), xpd=FALSE)

#print the x axis title to the plot seperately to get the spacing of the text right
mtext("Dishes", 1, 5.5, cex = 1.4)

#Create and show gradient legend for colors of bars in the chart
pnts = cbind(x =c(70,77,77,70), y =c(4.55,4.55,4,4))
legend.colors <- palette(floor(max.review/100))[1:47]
legend.gradient(pnts, cols = legend.colors, limits = c(1, max.review), 
                title = "Reviews w/ Dish")

#get correlation coefficients between chatter, review count and avg. rating
cor(dish.results[, 2:4])
rcorr(as.matrix(dish.results[, 2:4]), type="pearson")
#results show strong correlation between chatter and review count
#they also show a weak negative correlation between avg. rating and the other 2
#all of these correlation values and statistically significant at alpha=0.5

##Create scatter plot that shows relationship between "chatter" and "average rating"
plot(dish.results[,"average rating"], dish.results[,"chatter"], col = dish.results$Col, 
     type = "p", bg = dish.results$Col, pch=16, main="Chatter versus Average Rating", 
     xlab="Average Star Rating", ylab= "Chatter (Count of mentions of dish)")
pnts = cbind(x =c(4,4.1,4.1,4), y =c(6000,6000,3000,3000))
legend.colors <- palette(floor(max.review/100))[1:47]
legend.gradient(pnts, cols = legend.colors, limits = c(1, max.review), 
                title = "Reviews w/ Dish")


###
###This section creates the visualizations for Task 5
###

#create a list of businesses with a "popular" dish along with metrics (I chose "dim sum" as my dish)
bus.dish <- dish.score[dish.score[,"dish"]=="dim sum", ]   #subset dish.score to only get businesses with reviews for "dim sum"
bus.dish.result <- as.data.frame(table(bus.dish[ ,"business"]))
names(bus.dish.result) <- c("business_id", "dish review count")
bus.dish.result[,"average_rating"] <- tapply(bus.dish$stars, bus.dish$business, FUN=mean) #average star rating for reviews per business
bus.dish.result[,"stdev rating"] <- tapply(bus.dish$stars, bus.dish$business, FUN=sd) #std dev similar to above

#normalize the review counts (log of counts) and average ratings to be values between 0 and 1
bus.dish.result[,"log.counts"] <- log(bus.dish.result[, "dish review count"])
bus.dish.result[,"norm.counts"] <- (bus.dish.result$log.counts-min(bus.dish.result$log.counts)+1)/
                                   (max(bus.dish.result$log.counts)-min(bus.dish.result$log.counts)+1) #add 1 to prevent 0's
bus.dish.result[,"norm.stars"] <- (bus.dish.result$average_rating-min(bus.dish.result$average_rating))/
                                  (max(bus.dish.result$average_rating)-min(bus.dish.result$average_rating))

#create F_beta combined score that includes review count and star rating
beta <- 3.0
bus.dish.result[,"F1"] <- (1+beta^2)*(bus.dish.result$norm.counts * bus.dish.result$norm.stars)/
                          ((beta^2 * bus.dish.result$norm.counts) + bus.dish.result$norm.stars)
bus.dish.result <- bus.dish.result[order(-bus.dish.result[,"F1"]),]

#Lookup business name from the business dataframe/JSON file
business.lookup <- business[,c("business_id", "name")] #subset table with just ID and name
bus.dish.result <- join(bus.dish.result, business.lookup, by = "business_id")
bus.dish.result <- bus.dish.result[,c(9,1,2,3,4,5,6,7,8)] #bring name to front of dataframe

#create barplot for the F1 data by business name
par(mgp = c(3, 1, 0)) #moves label positions; default is c(3, 1, 0)
par(mar=c(13, 4.1, 4.1, 2.1)) #changes dimensions of the plot (bottom, left, top, right)
par(opa=c(0,0,0,0)) #This is the default
barplot(names.arg=head(bus.dish.result$name,50),head(bus.dish.result[,"F1"],50), 
        main="Top 50 Restaurants for Dim Sum",xlab="", ylab= "F-Score (stars and review count combined)",
        col = "blue", cex.names = .6, las=2, ylim=c(.6, .9), xpd=FALSE)
#names.arg=bus.dish.result$name
#print the x axis title to the plot seperately to get the spacing of the text right
mtext("Restaurants", 1, 10, cex = 1.4)
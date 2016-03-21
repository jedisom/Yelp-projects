##Task 2.3
#by Jed Isom
#Week of September 13th, 2015

#import the applicable JSON files
library("pacman")
pacman::p_load(jsonlite, tm, topicmodels, slam, cluster)
      #jsonlite for JSON file loading
      #tm and topicmodels for LDA topic modeling

rm(list=ls())

json_file <- "yelp_academic_dataset_business.JSON"
#took this line of code from http://stackoverflow.com/questions/26519455/error-parsing-json-file-with-the-jsonlite-package
business <- fromJSON(sprintf("[%s]", paste(readLines(json_file), collapse=",")))
#this lists information about the businesses (location, hours, category, name, some attributes)

json_file <- "yelp_academic_dataset_review.JSON"
review <- fromJSON(sprintf("[%s]", paste(readLines(json_file), collapse=",")))
#list reviews by businesses

#add boolean variable to business is.restaurant
#quick and dirty code for this, but only takes a couple seconds
for (i in 1:dim(business)[1]){
      business[i,"is.restaurant"] = is.element("Restaurants", business[i,"categories"][[1]])
}

#subset business dataframe for just restaurants
business <- business[business[,"is.restaurant"]==TRUE,]

#get only the restaurants that have a cuisine as a category (and remove low freq. cuisines...)
non.cuisine.list <- c("Nightlife", "Lounges", "Party & Event Planning", "Event Planning & Services", 
                      "Venues & Event Spaces", "Active Life", "Bowling", "Beer, Wine & Spirits", "Grocery", 
                      "Meat Shops", "Dance Clubs", "Arts & Entertainment", "Music Venues", "Karaoke", 
                      "Shopping Centers", "Shopping", "Outlet Stores", "Golf", "Convenience Stores", 
                      "Drugstores", "Hotels & Travel", "Hotels", "Jazz & Blues", "Performing Arts", "Fashion", 
                      "Sporting Goods", "Sports Wear", "Cinema", "Pool Halls", "Arcades", "Casinos", 
                      "Health Markets", "Social Clubs", "Food Delivery Services", "Gift Shops", 
                      "Flowers & Gifts", "Health & Medical", "Hospitals", "Hookah Bars", "Amusement Parks", 
                      "Gas & Service Stations", "Automotive", "Adult Entertainment", "Beauty & Spas", 
                      "Gyms", "Medical Spas", "Fitness & Instruction", "Day Spas", "Taxis", "Transportation", 
                      "Auto Repair", "Colleges & Universities", "Education", "Specialty Schools", 
                      "Cooking Schools", "RV Parks", "Home Decor", "Home & Garden", "Kitchen & Bath", 
                      "Appliances", "Airports", "Tours", "Do-It-Yourself Food", "Cafeteria", 
                      "Swimming Pools", "Wineries", "Art Galleries", "Bed & Breakfast", "Arts & Crafts", 
                      "Landmarks & Historical Buildings", "Personal Shopping", "Public Services & Government", 
                      "Street Vendors", "Dry Cleaning & Laundry", "Local Services", "Festivals", 
                      "Farmers Market", "Internet Cafes", "Leisure Centers", "Kids Activities", "Car Wash", 
                      "Horseback Riding", "Butcher", "Country Dance Halls", "Cultural Center", "Delicatessen", 
                      "Home Services", "Real Estate", "Apartments", "Mass Media", "Print Media", 
                      "Food", "Fast Food", "Bars", "Bakeries", "Coffee & Tea", "Donuts", "Caterers", 
                      "Dive Bars", "Pubs", "Buffets", "Cafes", "Sports Bars", "Specialty Food", 
                      "Gluten-Free", "Wine Bars", "Comfort Food", "Bagels", "Gastropubs", 
                      "Juice Bars & Smoothies", "Breweries", "Pretzels", "Food Stands", "Island Pub",
                      "Tapas Bars", "Cheese Shops", "Gay Bars", "Herbs & Spices", "Hot Pot", "Local Flavor", 
                      "Brasseries", "Shaved Ice", "Food Trucks", "Food Court", "Champagne Bars", 
                      "Bubble Tea", "Piano Bars", "Poutineries", "Beer Bar", "Distilleries", "Lebanese", 
                      "Soup", "Caribbean", "Tea Rooms", "Cheesesteaks", "Soul Food", "Salvadoran", "Kosher", 
                      "Polish", "Creperies", "Cuban", "Russian", "Irish", "Fruits & Veggies", "Fondue", 
                      "Arabian", "Seafood Markets", "Peruvian", "Halal", "Dim Sum", "Mongolian", 
                      "Persian/Iranian", "German", "Cantonese", "Taiwanese", "Argentine", 
                      "Himalayan/Nepalese", "Moroccan", "Falafel", "Ethiopian", "African", "Indonesian", 
                      "Turkish", "Afghan", "Tapas/Small Plates", "Basque", "Spanish", "Cocktail Bars", 
                      "Brazilian", "Personal Chefs", "Laotian", "Szechuan", "Belgian", "Gelato", 
                      "Live/Raw Food", "Bistros", "Chocolatiers & Shops", "Malaysian", "Singaporean", 
                      "Burmese", "Scandinavian", "Canadian (New)", "Czech", "Slovakian", "Scottish", 
                      "Modern European", "Bangladeshi", "Ramen", "Portuguese", "Ukrainian", "Shanghainese", 
                      "Cambodian", "Venezuelan", "Colombian", "Dominican", "Patisserie/Cake Shop", 
                      "Australian", "Egyptian")

#create dataframe of cuisines and the business_id's associated with them
cat.bus <- as.data.frame(matrix(c(NA,NA),nrow=1,ncol=2))
names(cat.bus) <- c("cuisine", "business_id")
cuisine.found <- FALSE

#
for (i in 1:dim(business)[1]){      #go through all businesses
      temp <- as.list(business[i,"categories"][[1]]) #get list of categories for that busines
      if (length(temp)>=1) {  #Make sure the list isn't empty
            for (j in 1:length(temp)){    #cycle through all categories for the business
                  if ((temp[j] != "Restaurants")&(!is.element(temp[j],non.cuisine.list))){
                        #filter out non-cuisines and the word "Restaurants"
                        if (cuisine.found==FALSE){
                              cuisine.found <- TRUE
                              cat.bus[1,1] <- temp[j]
                              cat.bus[1,2] <- business[i,"business_id"]
                              cat.bus <- as.data.frame(cat.bus)
                              names(cat.bus) <- c("cuisine", "business_id")
                        } else {
                              cat.bus <- rbind(cat.bus, c(temp[j], business[i,"business_id"]))
                        }
                  }
            }
      }
}
#get full list of all remaining cuisines
cuisine.list <- unique(unlist(cat.bus$cuisine, use.names = FALSE))

#consolidate all of the reviews for a cuisine into 1 "document" each for future comparison
cuisine.review <- NULL
for (cuisine in cuisine.list){
      #get list of businesses that have that cuisine
      bus.list <- cat.bus[cat.bus[,"cuisine"]==cuisine, "business_id"]       
      
      #get list of reviews for those businesses
      rev.list <- review[is.element(review[,"business_id"],bus.list),"text"]
      #randomly select maximum number of reviews to use as representation of the cuisine
      rev.max <- min(50,length(rev.list))
      set.seed(1)
      rev.list <- sample(rev.list, rev.max, replace=FALSE)
      
      #Combine all the reviews for these businesses and store in cuisine.review
      cuisine.num <- match(cuisine,cuisine.list)
      if (is.null(cuisine.review)){ #initialize dataframe
            cuisine.review <- as.data.frame(matrix(c(cuisine, 
                                            paste(rev.list, collapse = " - ")), nrow=1, ncol=2))
            names(cuisine.review) <- c("cuisine", "combined_reviews")
            cuisine.review[,1] <- as.character(cuisine.review[,1])
            cuisine.review[,2] <- as.character(cuisine.review[,2])
      } else {
            cuisine.review <- rbind(cuisine.review, c(cuisine, paste(rev.list, collapse=" - ")))
      }  
}

#Turn text into Corpus and clean up before creating document term matrix
myReader <- readTabular(mapping=list(content="combined_reviews", id="cuisine"))
corp <- VCorpus(DataframeSource(cuisine.review), readerControl=list(reader=myReader))
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
wordMatrix = as.data.frame(t(as.matrix(dtm)))
#rm(corp) #remove corpus to save RAM

#function that calculates similarity score based on 2 cuisines' texts
#This one uses Pivoted Length Normalization - Vector Space Model
PLM_VSM <- function (tdm, q, d, M, avdl, b=0.5){
      
      #find document length
      dl <- sum(tdm[,d])
      
      #subset tdm to only include words contained in cuisine 1 and cuisine 2
      in.qd <- ((tdm[,q]>=1)|(tdm[,d]>=1))
      if (q==d){
            tdm_qd <- tdm[in.qd,]
            df_ws <- rowSums(tdm_qd != 0) # num. of documents with each term
      } else {
            tdm_qd <- tdm[in.qd,]      
            df_ws <- rowSums(tdm_qd != 0) # num. of documents with each term
      }
           
      ##calculate score using vectorized approach
      #vectorize word counts by terms
      q.word.counts <- tdm_qd[,q]
      if (q==d){
            d.word.counts <- q.word.counts
      } else {
            d.word.counts <- tdm_qd[,d]
      }
      
      #Use vector math to calculate and sum the score
      num <- (log(1+log(1+d.word.counts)))
      den <- (1-b+b*dl/avdl)
      log_term <-log((M+1)/df_ws)
      f_qd <- sum((q.word.counts*num/den)*log_term)
      
      return (f_qd)
}

M <- dim(cuisine.review)[1]         #number of documents in corpus
avdl <- mean(colSums(wordMatrix))   #find average document length

#Create similarity matrix by comparing different cuisines to each other
cuisine.length <- length(cuisine.list)
sim.matrix <- as.data.frame(matrix(nrow=cuisine.length, ncol=cuisine.length))
names(sim.matrix) <- cuisine.list
row.names(sim.matrix) <- cuisine.list
for (c1 in cuisine.list){
      cuisine.num <- match(c1,cuisine.list)
      print(paste(cuisine.num," of ", cuisine.length, " cuisines", sep=""))
      for(c2 in cuisine.list){
            #Decided to use b=0.9 based on visual review of task 2.2 results
            sim.matrix[c1,c2] <- PLM_VSM(wordMatrix, c1, c2, M, avdl, b=0.9)    
      }
}

#Turn similarity score into a cuisine distance with match = 0 distance
dist.matrix <- (max(sim.matrix)/sim.matrix)-1
#get average of (i,j) and (j,i) because they're slightly different when using PLM_VSM
dist.matrix2 <- dist.matrix
for (i in 1:cuisine.length){
      for (j in 1:cuisine.length){
            if (i==j){
                  dist.matrix2[i,j] <- 0
            } else{
                  dist.matrix2[i,j] <- mean(dist.matrix[i,j], dist.matrix[j,i])
            }
      }
}
dist.matrix <- dist.matrix2

#use agglomerative clustering to guess a good # of clusters
cluster.agnes <- agnes(dist.matrix, diss = TRUE)
cluster.agnes$height #look at the height to see where a good break point is (k=2?, 5?, 7?)

#cluster based on the distance matrix
cluster.pam.7 <- pam(dist.matrix, 7, diss = TRUE, keep.diss = FALSE)
cluster.pam.5 <- pam(dist.matrix, 5, diss = TRUE, keep.diss = FALSE)
cluster.pam.2 <- pam(dist.matrix, 2, diss = TRUE, keep.diss = FALSE)

#Assign cluster numbers to each cuisine and sort them
#7 clusters
cluster.num.7 <- as.data.frame(cluster.pam.7[3])
cluster.num.7[,2] <- row.names(cluster.num.7)
names(cluster.num.7) <- c("number", "cuisine")
cluster.num.7 <- cluster.num.7[ order(cluster.num.7[,1]), ]
row.names(cluster.num.7) <- NULL

#5 clusters
cluster.num.5 <- as.data.frame(cluster.pam.5[3])
cluster.num.5[,2] <- row.names(cluster.num.5)
names(cluster.num.5) <- c("number", "cuisine")
cluster.num.5 <- cluster.num.5[ order(cluster.num.5[,1]), ]
row.names(cluster.num.5) <- NULL

#2 clusters
cluster.num.2 <- as.data.frame(cluster.pam.2[3])
cluster.num.2[,2] <- row.names(cluster.num.2)
names(cluster.num.2) <- c("number", "cuisine")
cluster.num.2 <- cluster.num.2[ order(cluster.num.2[,1]), ]
row.names(cluster.num.2) <- NULL

#sort rows and columns of dist.matrix to get like cuisines next to each other
dist.matrix.7 <- dist.matrix[cluster.num.7$cuisine,cluster.num.7$cuisine]
dist.matrix.5 <- dist.matrix[cluster.num.5$cuisine,cluster.num.5$cuisine]
dist.matrix.2 <- dist.matrix[cluster.num.2$cuisine,cluster.num.2$cuisine]

#write clustered distance matrix to file
write.csv(dist.matrix.7,"task 2.3(k=7) distance matrix.csv")
write.csv(dist.matrix.5,"task 2.3(k=5) distance matrix.csv")
write.csv(dist.matrix.2,"task 2.3(k=2) distance matrix.csv")
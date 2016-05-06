##Task 2.1
#by Jed Isom
#Week of September 13th, 2015

#import the applicable JSON files
library("pacman")
pacman::p_load(jsonlite, tm, topicmodels, slam)
      #jsonlite for JSON file loading
      #tm and topicmodels for LDA topic modeling

rm(list=ls())

json.file <- "yelp_academic_dataset_business.JSON"
#took this line of code from http://stackoverflow.com/questions/26519455/error-parsing-json-file-with-the-jsonlite-package
business <- fromJSON(sprintf("[%s]", paste(readLines(json.file), collapse=",")))
#this lists information about the businesses (location, hours, category, name, some attributes)

json.file <- "yelp_academic_dataset_review.JSON"
review <- fromJSON(sprintf("[%s]", paste(readLines(json.file), collapse=",")))
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

#randomly pick subset of reviews for each cuisine for future comparison
cuisine.review <- NULL
for (cuisine in cuisine.list){
      #get list of businesses that have that cuisine
      bus.list <- cat.bus[cat.bus[,"cuisine"]==cuisine, "business_id"]       
      
      #get list of reviews for those businesses
      rev.list <- review[is.element(review[,"business_id"],bus.list),"text"]
      
      #randomly select maximum number of reviews to use as representation of the cuisine
      #I've made sure all remaining cuisines have at least 50 reviews, but just in case...
      rev.max <- min(50,length(rev.list))
      set.seed(1)
      rev.list <- sample(rev.list, rev.max, replace=FALSE)
      
      #Add these reviews to cuisine.review
      cuisine.num <- match(cuisine,cuisine.list)
      if (is.null(cuisine.review)){ #initialize dataframe
            cuisine.review <- as.data.frame(matrix(c(1:length(rev.list), 
                                                     rep(cuisine,length(rev.list)), 
                                                     rev.list), ncol=3))
            names(cuisine.review) <- c("id", "cuisine", "reviews")
            cuisine.review[,1] <- as.character(cuisine.review[,1])
            cuisine.review[,2] <- as.character(cuisine.review[,2])
      } else {
            len <- dim(cuisine.review)[1]
            new.matrix <- as.data.frame(matrix(c((len+1):(len+length(rev.list)), 
                                   rep(cuisine,length(rev.list)), 
                                   rev.list), ncol=3))
            names(new.matrix) <- c("id", "cuisine", "reviews")
            cuisine.review <- rbind(cuisine.review, new.matrix)
      }  
}

#Turn text into Corpus and clean up before creating document term matrix
myReader <- readTabular(mapping=list(content="reviews", id="id", cuisine = "cuisine"))
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
wordMatrix <- as.data.frame(t(as.matrix(dtm)))
#rm(corp) #remove corpus to save RAM

###functions that calculate similarity score based on 2 cuisines' texts
#This function uses a simple cosine angle between texts using term frequency vectors
VectorCos <- function(tdm, q, d){
      
      #subset tdm to only include "query" and the "document"
      if (q==d){
            return (0)
      } else {
            in.qd <- ((tdm[,q]>=1)|(tdm[,d]>=1))
            tdm.qd <- tdm[in.qd,]      
      }
      
      # get q and d vectors for terms left
      a <- tdm.qd[,q]
      b <- tdm.qd[,d]
      
      theta <- acos( sum(a*b) / ( sqrt(sum(a * a)) * sqrt(sum(b * b)) ) )
      
      #get vector lengths to normalize angle calculation
      #q.len <- sqrt(sum(q.vect * q.vect))
      #d.len <- sqrt(sum(d.vect * d.vect))
      
      #dot.prod <- sum(q.vect * d.vect)
      
      return (theta)
}

#Create similarity matrix by comparing different cuisines to each other
cuisine.length <- length(cuisine.list)
sim.matrix <- as.data.frame(matrix(nrow=cuisine.length, ncol=cuisine.length))
names(sim.matrix) <- cuisine.list
row.names(sim.matrix) <- cuisine.list
set.seed(1)
for (c1 in cuisine.list){
      #get cuisine's number in the list
      cuisine.num <- match(c1,cuisine.list)
      
      #show progress to user
      print(paste(cuisine.num," of ", cuisine.length, " cuisines", sep=""))
      
      #get review id's for cuisine 1 (c1) and randomize them
      c1.id <- cuisine.review[cuisine.review[,"cuisine"]==c1,1]
      c1.id <- sample(c1.id, length(c1.id), replace=FALSE)
      
      for(c2 in cuisine.list){
            #get review id's for cuisine 2 (c2)
            if (c1==c2){
                  c2.id <- c1.id  #gives 0 angle if same cuisine
            } else {
                  c2.id <- cuisine.review[cuisine.review[,"cuisine"]==c2,1]
                  c2.id <- sample(c2.id, length(c2.id), replace=FALSE)      
            }
            
            #calculate angle between 50 review vectors from each cuisine
            temp <- rep(NA,50)
            for (i in 1:length(temp)){
                  temp[i] <- VectorCos(wordMatrix, c1.id[i], c2.id[i])
            }
            
            #average the angles and report that to similarity matrix
            sim.matrix[c1,c2] <- mean(temp)
      }
}

write.csv(sim.matrix,"task 2.1 similiarity matrix.csv")
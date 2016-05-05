# Yelp! Academic Dataset & Data Mining Capstone
This repository contains project files for a series of projects completed as part of a Data Mining Specialization Capstone course offered by Coursera and the University of Illinois - Urbana Champaign.  The code for these projects was all created in the R language.

##Dataset
The Yelp! academic data set used to complete these project tasks can be found [here](https://www.yelp.ca/dataset_challenge) along with descriptions of the various data files used.

## Task 1
Task 1 creates topic models using Latent Dirichlet allocation (LDA) to summarize main topics in the Yelp! reviews dataset.  It also takes it a step further and finds common (good and bad) topics for one restaurant.  

###Coursera Task 1 Requirements Description 
>####Overview
>The goal of this task is to explore the Yelp data set to get a sense about what the data look like and their characteristics. You can think about the goal as being to answer questions such as:

>####Instructions
> * What are the major topics in the reviews? Are they different in the positive and negative reviews? Are they different for different cuisines?
> * What does the distribution of the number of reviews over other variables (e.g., cuisine, location) look like?
> * What does the distribution of ratings look like?
> * In general, you can address such questions by showing visualization of statistics computed based on the data set or topics extracted from review text.

>You must complete the following specific tasks.

>Task 1.1:

>Use a topic model (e.g., PLSA or LDA) to extract topics from all the review text (or a large sample of them) and visualize the topics to understand what people have talked about in these reviews.

>Task 1.2:

>Do the same for two subsets of reviews that are interesting to compare (e.g., positive vs. negative reviews for a particular cuisine or restaurant), and visually compare the topics extracted from the two subsets to help understand the similarity and differences between these topics extracted from the two subsets. You can form these two subsets in any way that you think is interesting. 


### Files and Packages Used
Files used in this task include:
 - yelp_academic_dataset_review.JSON
 - Task 1.1.R
 - Task 1.2a.R
 - Task 1.docx (Word version of task report)

Required R Packages include:
 - pacman (automatically installs and calls the other packages listed)
 - jsonlite
 - tm
 - topicmodels
 - slam
 - igraph
 - dplyr

##Task 2
Task 2 uses cuisine (store type) metadata to create similarity metrics between cuisines and cluster cuisines that are similar.  

###Coursera Task 2 Requirements Description 
>####Overview
>The goal of this task is to mine the data set to construct a cuisine map to visually understand the landscape of different types of cuisines and their similarities. The cuisine map can help users understand what cuisines are available and their relations, which allows for the discovery of new cuisines, thus facilitating exploration of unfamiliar cuisines. You can see a sample set of reviews from all the restaurants for a cuisine, but you are strongly encouraged to experiment with your own set of cuisines if you have time.

>####Instructions
>Some questions to consider when building the cuisine map are the following:

> * What's the best way of representing a cuisine? If all we know about a cuisine is just the name, then there is nothing we can do. However, if we can associate a cuisine with the restaurants offering the cuisine and all the information about the restaurants, particularly reviews, then we will have a basis to characterize cuisines and assess their similarity. Since review text contains a lot of useful information about a cuisine, a natural question is: what's the best way to represent a cuisine with review text data? Are some words more important in representing a cuisine than others?
> * What's the best way of computing similarity of two cuisines? Assuming that two cuisines can each be represented by their corresponding reviews, how should we compute their similarity?
> * What's the best way of clustering cuisines? Clustering of cuisines can help reveal major categories of cuisines. How would the number of clusters impact the utility of your results for understanding cuisine categories? How does a clustering algorithm affect the visualization of the cuisine map?
> * Is your cuisine map actually useful to at least some people? In what way? If it's not useful, how might you be able to improve it to make it more useful?

>Note that most of these questions are open questions that nobody really has a good answer to, but they are practically important questions to address. Thus, by working on this task, you are really working on a frontier research topic in data mining. Your goal in this task is to do a preliminary exploration of these questions and help provide preliminary answers to them. You can address such questions by analyzing the visualization of the cuisine map and comparing the results of alternative ways of mining the data to assess which strategy seems to work better for what purpose. You are encouraged to think creatively about how to quantitatively evaluate clustering results. For example, you can consider separating all the reviews about one cuisine (e.g., Indian) into multiple disjoint subsets (e.g., Indian1, Indian2, and Indian3) and thus artificially create multiple separate cuisines that are known to be of the same category. You can then test your algorithm on such an artificial data set to see if it can really group these artificial subcategories of the same cuisine together or give them very high similarity values.

>Task 2.1: Visualization of the Cuisine Map

>Use all the reviews of restaurants of each cuisine to represent that cuisine, and compute the similarity of cuisines based on the similarity of their corresponding text representations. Visualize the similarities of the cuisines and describe your visualization.

>Task 2.2: Improving the Cuisine Map

>Try to improve the cuisine map by 1) varying the text representation (e.g., improving the weighting of terms or applying topic models) and 2) varying the similarity function (e.g., concatenate all reviews then compute the similarity, or, first compute the similarity of individual review, then aggregate the similarity values). Does any improvement lead to a better map? Thoroughly describe the improvements you made to the cuisine map.

>Task 2.3: Incorporating Clustering in Cuisine Map

>Use any similarity results from Task 2.1 or Task 2.2 to do clustering. Visualize the clustering results to show the major categories of cuisines. Vary the number of clusters to try at least two very different numbers of clusters, and discuss how this affects the quality or usefulness of the map. Use multiple clustering algorithms for this task.

### Files and Packages Used
Files used in this task include:
 - yelp_academic_dataset_business.JSON
 - yelp_academic_dataset_review.JSON
 - Task 2.1.R
 - Task 2.2.R
 - Task 2.3.R
 - Task 2.docx (Word version of task report)

Required R Packages include:
 - pacman (automatically installs and calls the other packages listed)
 - jsonlite
 - tm
 - topicmodels
 - slam
 - cluster

##Task 3
Task 3 takes a seed set of dishes within a cuisine and uses Google's word2phrase and word2vec functions to "learn" other dishes within the given cuisine.  Task 3.1 was creating the seed file of known dishes to feed the algorithm.  This is accomplished in the Chinese_dishes and Chinese_dishes.txt files.  Task 3.2 accomplishes the "learning" of new Chinese dishes. 

###Coursera Task 3 Requirements Description 
>####Overview
>The goal of this task is to mine the data set to discover the common/popular dishes of a particular cuisine. Typically when you go to try a new cuisine, you don’t know beforehand the types of dishes that are available for that cuisine. For this task, we would like to identify the dishes that are available for a cuisine by building a dish recognizer.

>####Instructions
>Some questions to consider when building the dish recognizer are the following:

> * What types of dishes are present in the reviews for a cuisine?
> * Are there any surprising dishes in the list you annotated?
> * What types of dishes were you able to find?

>You must complete the following specific tasks.

>Task 3.1: Manual Tagging

>You are given a list of candidate dish names, which are all frequent (at least 10 times in corresponding corpus), automatically generated by the auto-labeling process of [SegPhrase](https://github.com/shangjingbo1226/SegPhrase)... Some of the dish names are verified by an outside knowledge base such that they are all good phrases, and some of them might be good dish names. However, some of the labels might be wrong. Therefore, your task here is to refine the label list for one cuisine. You could modify/add some phrases. Here are some actions you may take:

> * Remove a false positive non-dish name phrase **(recommended)**, e.g., hong kong 1 could be removed in Chinese cuisine.
> * Change a false positive non-dish name phrase to a negative label, e.g., hong kong 1 could be modified as hong kong 0.
> * Remove a false negative dish name phrase, e.g., wonton strips 0 could be removed in Chinese cuisine.
> * Change a false negative dish name phrase to a positive label **(recommended)**, e.g., wonton strips 0 could be modified as wonton strips 1.
> * Add some new annotated phrases in the same format.
>Tip: Notice that the character between a phrase and its label is a tab instead of a space.

>Remember that the tools we are using were originally designed for general phrase mining instead of dish name mining. Therefore, it will be much safer if we just remove those ambiguous labels, while aggressively changing them into opposites may lead to some undetermined risks, although it is still worth a try.

>Task 3.2: Mining Additional Dish Names

>Once you have a list of dish names, it is likely that many dish names are still missing. In this step, you would expand the list of dishes by using other pattern mining techniques and/or word association methods.

>For example, [ToPMine](http://web.engr.illinois.edu/~elkishk2/), as we mentioned in the previous pattern mining course, is an unsupervised frequent pattern-based phrase mining algorithm. It merges consecutive words based on statistical significance (stopwords will be firstly removed and be put back later). The most state of the art framework is [SegPhrase](https://github.com/shangjingbo1226/SegPhrase). SegPhrase will need the (refined) labels in the first task. SegPhrase has a classifier to assign a quality score to each phrase candidate based on their statistical features. The classification procedure will be enhanced by phrasal segmentation results. These two parts could mutually enhance each other.

>Another approach to possibly extending the dish names is using word association. You have previously learned and implemented methods to judge word associations (paradigmatic & syntagmatic relations), such as Mutual Information. There are also some more state-of-the-art methods such as [word2vec](https://code.google.com/archive/p/word2vec/), which you are welcome to experiment with.

### Files and Packages Used
Files used in this task include:
 - Chinese_dishes (includes preliminary dishes and personal opinion pre-filtering)
 - Chinese_dishes.txt (flat file created and manually pre-filtered from Chinese_dishes)
 - yelp_academic_dataset_business.JSON
 - yelp_academic_dataset_review.JSON
 - word2phrase.c (Got this file straight from Google, [here](https://code.google.com/archive/p/word2vec/))
 - word2vec.c (Got this file straight from Google,  [here](https://code.google.com/archive/p/word2vec/))
 - Task 3.2.R
 - Task 3.docx (Word version of task report)

Required R Packages include:
 - pacman (automatically installs and calls the other packages listed)
 - jsonlite
 - tm
 - topicmodels
 - lsa
 - slam
 - cluster 

##Tasks 4 & 5
Task 4 takes a given cuisine and then gives ranked recommendations for dishes to try in that cuisine.  Task 5 is closely related to 
task 4 and recommends a business to go to if you want to try a given dish.  

###Coursera Tasks 4 & 5 Requirements Description 
>####Overview
>The general goal of Tasks 4 and 5 is to leverage recognized dish names to further help people making dining decisions. Specifically, Task 4 is to mine popular dishes in a cuisine that are liked by people; this can be very useful for people who would be interested in trying a cuisine that they might not be familiar with. Task 5 is to recommend restaurants to people who would like to have a particular dish or a certain type of dishes. This is directly useful to help people choose where to dine. 

>The two tasks are different, but they can be completed very similarly. Both tasks rely on knowledge about dish names. You are welcome to use the dish list provided based on the labeled annotations we have compiled, or you are free to use your own dish list based on your results from Task 3. In Task 4, your goal is to rank the dish names of a particular cuisine based on the reviews that mention these dish names so as to rank the popular dishes that received positive comments on the top.  In Task 5, your goal is to rank the restaurants that offer a particular dish based on the comments about the dish expressed in the reviews of a restaurant so that the restaurants whose reviews contain many positive comments about the dish are ranked on the top. 

>####Instructions
>Some questions to consider when working on Tasks 4 & 5: 
> * Given a cuisine and a set of candidate dish names of the cuisine, how do we quantify the popularity of a dish? How can we discover the popular dishes that are liked by many reviewers? What kind of dishes should be ranked higher in general if we are to recommend dishes of a cuisine for people to try?  Would the number of times a dish is mentioned in all the reviews be a better indicator of a popular dish than the number of restaurants whose reviews mentioned the dish?
> * For people who are interested in a particular dish or a certain type of dishes, which restaurants should be recommended? How can we design a ranking function based on the reviews of the restaurants that mention the particular dish(es)? Should a restaurant with more dish name occurrences be ranked higher than one with more unique dish names?
> * How can you visualize the recommended dishes for a cuisine and the recommended restaurants for particular dishes to make them as useful as possible to users? How can the visualization be incorporated into a usable system? For example, you can imagine using the algorithms you developed for Tasks 4 and 5 to construct a system that allows a user to select a cuisine to see the favorite/popular dishes of the cuisine and further recommends the best restaurants if a user selects a particular dish or a set of dishes that are interesting to him/her. 

>Task 4: Mining Popular Dishes

>In this task, you will create a visualization showing a ranking of the dishes for a Yelp cuisine of your choice. You may use the dish list we have provided, the list based on your annotations from Task 3 (or a subset of that list), or any other list for other cuisines. You might find it more interesting to work on a cuisine for which you can recognize many dishes than one with only a few dish names that you recognize. 

>There are many ways to approach this task; the main challenge will be how to create the ranking. You can devise your own method or use other methods you have learned in the Text Retrieval MOOC. The simplest approach can be to simply count how many times a dish is mentioned in all the reviews of restaurants of a particular cuisine, but you are encouraged to explore how to improve over this simple approach, e.g., by considering ratings of reviews or even sentiment of specific sentences that mention a dish. Even if you just try this simple approach, you may still need to consider options of counting dish mentions based on the number of reviews vs. the number of restaurants, so keep this question in mind: What do you think is the best way of ranking dishes for a cuisine? This is an open research question, but your exploration may help us better understand it. 

>Task 5: Restaurant Recommendation

>In this task, your goal is to recommend good restaurants to those who would like to try one or more dishes in a cuisine. Given a particular dish, the general idea of solving this problem is to assess whether a restaurant is good for this dish based on whether the reviews of a candidate restaurant have included many positive (and very few negative) comments about the dish.  You may choose a target dish or a set of target dishes from the list of "popular dishes" you generated from Task 4, or otherwise, choose any dishes that have been mentioned many times in the review data (the more reviews you have for a dish, the more basis you will have for ranking restaurants). 

>You are required to create a visualization to show the ranking of the recommended restaurants. While a generic ranking of restaurants based on their overall ratings can be easily obtained, such a generic ranking is not as useful as one customized for a particular dish if one has decided to try this "particular dish." Thus, the ranking of restaurants you generated should be influenced somehow by the dish names you assumed to represent a diner's dining preference. The central question is thus how to design a dish-specific ranking algorithm for ranking restaurants. A simple approach easy to implement is to collect all the reviews mentioning a dish, and compute the average ratings of these reviews for each restaurant so that a restaurant whose reviews containing the dish have the highest average rating would be ranked on the top.   But you are free to experiment with any parameters such as the rating of the restaurant, among other things.

### Files and Packages Used
Files used in this task include:
 - yelp_academic_dataset_business.JSON
 - yelp_academic_dataset_review.JSON
 - Task 4 dish list.txt (This dish list is based on the output from Task 3, but was manually filtered for items I fealt were truly Chinese dishes prior to being used in this task)
 - Task 4 and 5.R
 - Task 4 & 5.docx (Word version of task report)

Required R Packages include:
 - pacman (automatically installs and calls the other packages listed)
 - jsonlite
 - tm
 - SDMTools
 - Hmisc
 - plyr

##Task 6
Task 6 uses hygiene data provided for several restaurants stating whether the restaurant passed their inspection or not.  This data is used with review data to predict whether restaurants will pass their hygiene inspections.  

###Coursera Task 6 Requirements Description 
>####Overview
>Sometimes we make decisions beyond the rating of a restaurant. For example, if a restaurant has a high rating but it often fails to pass hygiene inspections, then this information can dissuade many people to eat there. Using this hygiene information could lead to a more informative system; however, it is often the case where we don’t have such information for all the restaurants, and we are left to make predictions based on the small sample of data points.

>In this task, you are going to predict whether a set of restaurants will pass the public health inspection tests given the corresponding Yelp text reviews along with some additional information such as the locations and cuisines offered in these restaurants. Making a prediction about an unobserved attribute using data mining techniques represents a wide range of important applications of data mining. Through working on this task, you will gain direct experience with such an application. Due to the flexibility of using as many indicators for prediction as possible, this would also give you an opportunity to potentially combine many different algorithms you have learned from the courses in the Data Mining Specialization to solve a real world problem and experiment with different methods to understand what’s the most effective way of solving the problem.

>####About the Dataset
>You should first download the [dateset](https://d396qusza40orc.cloudfront.net/dataminingcapstone/Task6/Hygiene.tar.gz). The dataset is composed of a training subset containing 546 restaurants used for training your classifier, in addition to a testing subset of 12753 restaurants used for evaluating the performance of the classifier. In the training subset, you will be provided with a binary label for each restaurant, which indicates whether the restaurant has passed the latest public health inspection test or not. Whereas for the testing subset, you will not have access to any labels. The dataset is spread across 3 files such that the first 546 lines in each file correspond to the training subset and the rest are part of the testing subset. Below is a description of each file:

> * **hygiene.dat**: Each line contains the concatenated text reviews of one restaurant.
> * **hygiene.dat.labels**: For the first 546 lines, a binary label (0 or 1) is used where a 0 indicates that the restaurant has passed the latest public health inspection test, while a 1 means that the restaurant has failed the test. The rest of the lines have "[None]" in their label field implying that they are part of the testing subset.
> * **hygiene.dat.additional**: It is a CSV (Comma-Separated Values) file where the first value is a list containing the cuisines offered, the second value is the zip code, which gives an idea about the location, the third is the number of reviews, and the fourth is the average rating, which can vary between 0 and 5 (5 being the best).
>Note that the training subset is perfectly balanced, i.e., the number of restaurants with label 1 is equal to those with label 0. However, the testing subset is imbalanced where the majority of restaurants have a label of 0 (meaning that they have passed the inspection). Due to this imbalance, the classification accuracy may not be a suitable measure for evaluating the performance of classifiers. Therefore, we will use the F1 measure, which is the harmonic mean of precision and recall, to rank the submissions in the leaderboard. The F1 measure will be based on the macro-averages of precision and recall (macro-averaging is used here to ensure that the two classes are given equal weight as we do not want class 0 to dominate the measure).

>####Instructions
>As you have probably noticed, this task is similar to Task 4 in the programming assignment of the Text Mining and Analytics course; however, there are three major differences:

>The training data is perfectly balanced, whereas the testing data is skewed, which creates a new challenge since the training and testing data have different distributions.
>The main performance metric is the F1 score as opposed to the classification accuracy that was used in the Text Mining course. This means that a good classifier is expected to perform well on both classes.
>Extra non-textual features such as the cuisines, locations, and average rating are given. This might help in further improving the prediction performance and provide an opportunity to experiment with many more strategies for solving the problem.

>You are free to use whatever toolkit or programming language you prefer... You should train a classifier over the 546 training instances and then submit the binary predictions for the remaining 12753 instances, each on a separate line. The first line should contain the nickname that you want to have on the leaderboard, i.e., the output file should have the following format:

>    Nickname
>    Label1
>    Label2
>    .
>    .
>    .
>    Label12573

### Files and Packages Used
Files used in this task include:
 - hygiene.dat.additional
 - hygiene.dat.labels
 - hygiene.dat (this file was 100MB+ and is not currently in the repository)
 - Task 6.1.R
 - Task 6.2.R

Required R Packages include:
 - pacman (automatically installs and calls the other packages listed)
 - jsonlite
 - tm
 - topicmodels
 - slam
 - LiblineaR

##MIT License

Copyright (c) 2016 Jed Isom

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

# Yelp! Academic Dataset & Data Mining Capstone
This repository contains project files for a series of projects completed as part of a Data Mining Specialization Capstone course offered by Coursera and the University of Illinois - Urbana Champaign.  The code for these projects was all created in the R language.

##Dataset
The Yelp! academic data set used to complete these project can be found [here](https://www.yelp.ca/dataset_challenge) along with descriptions of the various data files used.

## Task 1
Task 1 creates topic models using Latent Dirichlet allocation (LDA) to summarize main topics in the Yelp! reviews dataset.  It also takes it a step further and finds common (good and bad) topics for one restaurant.  

###Coursera Task 1 Requirements Description 
>The goal of this task is to explore the Yelp data set to get a sense about what the data look like and their characteristics. You can think about the goal as being to answer questions such as:

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
>The goal of this task is to mine the data set to construct a cuisine map to visually understand the landscape of different types of cuisines and their similarities. The cuisine map can help users understand what cuisines are available and their relations, which allows for the discovery of new cuisines, thus facilitating exploration of unfamiliar cuisines. You can see a sample set of reviews from all the restaurants for a cuisine, but you are strongly encouraged to experiment with your own set of cuisines if you have time.

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

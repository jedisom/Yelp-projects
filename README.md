# Yelp-LDA-topic
1st assignment from Coursera Data Mining capstone class.  Code is in R.

Task 1 creates topic models using Latent Dirichlet allocation (LDA) to summarize
main topics in the Yelp! reviews dataset.  It also takes it a step further and 
finds common (good and bad) topics for one restaurant.  Files used in this task
include:
 - Task 1.1.R
 - Task 1.2a.R
 - Task 1.docx (Word version of task report)

Task 2 uses cuisine (store type) metadata to create similarity metrics between 
cuisines and cluster cuisines that are similar.  Files used in this task include:
 - Task 2.1.R
 - Task 2.2.R
 - Task 2.3.R
 - Task 2.docx (Word version of task report)

Task 3 takes a seed set of dishes within a cuisine and uses Google's word2phrase
and word2vec functions to "learn" other dishes within the given cuisine.  Files 
used in this task include:
 - Chinese_dishes (includes preliminary dishes and personal opinion pre-filtering)
 - Chinese_dishes.txt (file used as seed that was pre-filtered manually)
 - word2phrase.c (Got this file straight from Google)
 - word2vec. (Got this file straight from Google)
 - Task 3.2.R
 - Task 3.docx (Word version of task report)

Task 4 recommends a dish to try based on a cuisine.  Task 5 is closely related to 
task 4 and recommends a business to go to if you want to try a given dish.  Files 
used in this task include:
 - Task 4 dish list.txt
 - Task 4 and 5.R
 - Task 4 & 5.docx

Task 6 uses hygiene data provided for several restaurants stating whether the 
restaurant passed their inspection or not.  This data is used with review data to
predict whether restaurants will pass their hygiene inspections.  Files used in 
this task include:
 - hygiene.dat.additional
 - hygiene.dat.labels
 - hygiene.dat (this file was 100MB+ and is not currently in the repository)
 - Task 6.1.R
 - Task 6.2.R


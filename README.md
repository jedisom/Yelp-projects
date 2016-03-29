# Yelp! Academic Dataset & Data Mining Capstone
This repository contains project files for a series of projects completed as part of a Data Mining Specialization Capstone course offered by Coursera and the University of Illinois - Urbana Champaign.  The code for these projects was all created in the R language.

##Dataset
The Yelp! academic data set used to complete these project can be found [here](https://www.yelp.ca/dataset_challenge) along with descriptions of the various data files used.

## Task 1
Task 1 creates topic models using Latent Dirichlet allocation (LDA) to summarize main topics in the Yelp! reviews dataset.  It also takes it a step further and finds common (good and bad) topics for one restaurant.  

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

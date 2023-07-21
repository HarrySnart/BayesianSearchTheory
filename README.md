# BayesianSearchTheory
## Using PROC IML and SAS Visual Analytics to explore Search Effectiveness Probability with Bayesian Updating

This repository holds source code for implementing a batch simulation of Bayesian Search Theory within the context of Salvage Operations. The code is split into two files. Firstly, a macro which computes the updated probabilities using Bayes' Theorem and secondly a file which creates initial probabilities and runs 250 simulated search days using the Bayesian updating. 

The results are visualized using SAS Visual Analytics. Here we can see how the combined probability of successful search operations changes over time and assess what our effective search window is. This can be used to set expectations, and understand required budget and resources for salvage operations.

![Dashboard showing updated probabilities for Bayesian Search Theory](https://raw.githubusercontent.com/HarrySnart/BayesianSearchTheory/main/Images/probabilities.gif)

We are also able to visualize how search effort changes over time. The combined probability of successful search takes two sets of information into consideration. Firstly - our beliefs on where the lost object is. Secondly - our domain understanding of how likely we are to find the object given it is there. This helps us to articulate the search complexity in a given search zone.

![Animated bar chart of search effort by date](https://raw.githubusercontent.com/HarrySnart/BayesianSearchTheory/main/Images/search_zones.gif)

The full blog can be found here on SAS Communities. 

A full explanation of the Bayesian updating can be found here: https://www.lancaster.ac.uk/stor-i-student-sites/katie-howgate/2021/02/08/a-bayesian-approach-to-finding-lost-objects/

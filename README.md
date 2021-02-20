## Description
The application applies Natural Language Processing -NLP- techniques to reviews published on Amazon. At its core, the app relies on the following metrics:

*  **Polarity**: is a float [-1,1] where one (1) means positive statement and minus one (-1) means a negative statement. Subjective sentences generally refer to personal opinion, emotion or judgment (thus, polarity close to +1 or -1) whereas objective refers to factual information (polarity close to zero).
*   **Elaboration**: In writing, elaboration refers to the process of developing an idea. In the context of the app, "elaboration" is the frequency of non-stop words used in a review. In NLP, stopwords refer to words that add no meaning to a sentence or are very common in a language (for English, these are, for example, *the*, *is*, *I*)

### Filtering Options

Users can find different filtering options on the sidebar panel to customize the analysis based primarily on product category and review rating. Besides, the "words to be excluded" feature offers the possibility to manually exclude words that the algorithm did not identify as *unimportant* when pre-processed the reviews. 

> Note: Given that the algorithm is computationally intensive (analyze_comments.R), the "Analyze" button was included to enhance the app performance. 

### Main Panel
#### Wordcloud
The app displays three word clouds, one for each type of review (negative, neutral, and positive). The size of the word is relative to its frequency.

#### Analysis by Word
This visualization aims to compare the sentiment that is associated to a word (see opinion lexicon in Data Sources section), versus elaboration for every category and rating. On the x-axis, users can see the average number of words of the reviews that use the word displayed in the graph, and the color refers to the pre-associated sentiment. For example, users can see that, normally, very negative reviews (rating equal 1) tend to use a lot of words on average (20+); a pattern not necessarily true for other ratings. 

#### Analysis by Review
This visualization aims to spot, at a glance, potential patterns of polarities and elaboration of reviews over time. By hovering over the graph, users can select points and detailed information will be desplayed on the table below the graph. Besides, the app offers the possibility to download the "brushed" points into a csv file.  

## Data Sources

### Amazon Reviews
*./data/reviews_data.csv*

This dataset contains a random sample of 28k+ customer reviews for different Amazon products downloaded from [data.world](https://data.world/datafiniti/consumer-reviews-of-amazon-products/workspace/project-summary?agentid=datafiniti&datasetid=consumer-reviews-of-amazon-products) on February 14th, 2021. Find below a detailed description of the columns that will be used in the project:

* `name`: the product's name used for the publication.
* `categories`: A list of category keywords used for this product across multiple sources.
* `primaryCategories`: A list of standardized categories to which this product belongs.
* `date`: the date the review was posted, starting from February, 2009 until March, 2019 (originally called `reviews.date`)
* `rating`: A 1 to 5 start value for the review (originalle called `reviews.rating`)
* `review`: the actual customer review (originally called `reviews.text`)

### Opinion Lexicon
A list of *negative* and *positive* opinion/sentiment words. The two data sources were downloaded and stored into the `./data/` folder using the following snippet:

```r
library("dplyr")
library("readr")
library("data.table")

urls <- c('http://ptrckprry.com/course/ssd/data/negative-words.txt',
         'http://ptrckprry.com/course/ssd/data/positive-words.txt')

negative <- fread(
  input = urls[1], 
  skip = 35, 
  header = FALSE, 
  encoding = "UTF-8", 
  col.names = c("word")
) %>% 
  mutate(class = "negative")

positive <- fread(
  input = urls[2], 
  skip = 35, 
  header = FALSE, 
  encoding = "UTF-8", 
  col.names = c("word")
) %>% 
  mutate(class = "positive")

classified <- rbind(negative, positive)

write_csv(classified, file = "./data/classified.csv")
```

The `classified.csv` dataset has 6,769 rows and two columns: `word` and `class` (i.e., the sentiment, either positive or negative).

## Dependencies

All R dependencies can be found in the [requirements.txt](https://https://github.com/RforOperations2021/hw1-mlaracue/blob/main/requirements.txt) file.

## Deployment

The app can be found on [shinyapps.io](hhttps://mlaracue.shinyapps.io/amazon-reviews-analyzer/)

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


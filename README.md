## Data Source
*./data/reviews_data.csv*

This dataset contains a random sample of 28k+ customer reviews for different Amazon products downloaded from [data.world](https://data.world/datafiniti/consumer-reviews-of-amazon-products/workspace/project-summary?agentid=datafiniti&datasetid=consumer-reviews-of-amazon-products) on February 14th, 2021. Find below a detailed description of the columns that will be used in the project:

* `name`: the product's name used for the publication.
* `categories`: A list of category keywords used for this product across multiple sources.
* `primaryCategories`: A list of standardized categories to which this product belongs.
* `date`: the date the review was posted, starting from February, 2009 until March, 2019 (originally called `reviews.date`)
* `rating`: A 1 to 5 start value for the review (originalle called `reviews.rating`)
* `review`: the actual customer review (originally called `reviews.text`)

analyze_reviews <- function(reviews_data, sentiments, non_words = NULL, min = 3L, stemming = TRUE) {
  
  library("tidyr")
  library("dplyr")
  library("tm")
  library("SnowballC")
  library("wordcloud")
  library("tidytext")
  library("stringr")
  library("hunspell")
  library("scales")
  
  stop_words <- rbind(
    get_stopwords(language = "English"),
    # data.frame(word = tm::stopwords("English"),
    #            lexicon = "tm"),
    # download quanteda
    data.frame(word = quanteda::stopwords("English"),
               lexicon = "quanteda")) %>% 
    distinct(word) %>% 
    pull(word)
  
  clean_words <- function(review){
    review <- review %>% 
      removePunctuation() %>% 
      removeNumbers() %>% 
      stripWhitespace()
    
    return(review)
  }
  
  cleaned <- reviews_data %>% 
    # split reviews into sentences
    mutate(review := str_split(string = review, 
                               pattern = fixed("."))) %>% 
    unnest(review) %>% 
    mutate(review = clean_words(review)) %>% 
    filter(!is.na(review), 
           !review %in% c(" ", "", "NA")) %>% 
    unnest_tokens(
      output = word, 
      token = "ngrams", 
      # n-grams
      n = 1,
      input = review) %>%
    distinct() %>% 
    filter(!is.na(word), word != "",
           # keep words that are spelled correctly
           hunspell_check(word, dict = "en_US"))
  
  if(stemming){
    cleaned <- cleaned %>% 
      mutate(stem = vapply(hunspell_stem(word, dict = "en_US"), 
                           `[`, 1, FUN.VALUE = character(1)),
             Word = ifelse(is.na(stem), word, stem)) %>% 
      select(-stem) %>% 
      filter(!word %in% stop_words, 
             !word %in% non_words) 
  } else {
    
    cleaned <- cleaned %>% 
      filter(!word %in% stop_words, 
             !word %in% non_words) 
  }
  
  # add sentiments
  cleaned <- cleaned %>%
    left_join(sentiments, by = "word") %>%
    mutate(
      class = if_else(is.na(class), "neutral", class),
      score = case_when(
        class == "positive" ~  1,
        class == "negative" ~ -1,
        TRUE ~ 0)
    )
  
  polarity_reviews <- cleaned %>%
    group_by(date, id) %>%
    filter(n() >= min) %>% 
    summarise(n_words = n(),
              polarity = sum(score) / n_words,
              .groups = 'drop') %>%
    ungroup() %>%
    mutate(elaboration = n_words / mean(n_words))
  
  polarity_words <- cleaned %>%
    group_by(id) %>%
    filter(n() >= min) %>% 
    mutate(n_words = n()) %>%
    group_by(category, rating, word, class) %>% 
    summarise(elaboration = mean(n_words),
              n_reviews = n(),
              .groups = 'drop') %>% 
    filter(n_reviews > min)
  
  n_reviews <- cleaned %>% 
    distinct(id) %>% 
    nrow()
  
  top_words <- cleaned %>% 
    count(category, rating, word, sort = TRUE)
  
  res <- list(
    n_reviews = n_reviews,
    polarity_reviews = polarity_reviews,
    polarity_words = polarity_words,
    top_words = top_words
  )
  
  return(res)
}

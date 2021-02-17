
analyze_reviews <- function(reviews_data, sentiments, non_words = NULL, min = 3L, stemming = TRUE) {
    
    library("tidyr")
    library("dplyr")
    library("ggplot2")
    library("tm")
    library("SnowballC")
    library("wordcloud")
    library("tidytext")
    library("stringr")
    library("hunspell")
    library("scales")
    
    stop_words <- rbind(
        get_stopwords(language = "English"),
        data.frame(word = tm::stopwords("English"),
                   lexicon = "tm"),
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
        mutate(id = 1:nrow(.),
               # split reviews into sentences
               review := str_split(string = review, 
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
    
    polarity <- cleaned %>%
        group_by(id) %>%
        filter(n() >= min) %>% 
        summarise(n = n(),
                  polarity = sum(score) / n) %>%
        ungroup() %>%
        mutate(writingDegree = n / mean(n))
    
    n_reviews <- cleaned %>% 
        distinct(id) %>% 
        nrow()
    
    top_words <- cleaned %>% 
        count(word, sort = TRUE) %>% 
        mutate(wt = n / n_reviews) %>%  
        filter(wt >= 0.01)
    
    y_max <- max(top_words$n)
    
    # barplot <- ggplot(data = top_words %>% 
    #                       top_n(n = 15, wt = n),
    #                   aes(x = reorder(word, n), y = n)) + 
    #     geom_bar(stat = "identity", fill = "#18A9FF") +
    #     geom_text(aes(label = percent(n / n_reviews, 2)), 
    #               hjust = -.05, size = 5, fontface = "bold") +
    #     scale_y_continuous(limits = c(0, y_max + 5)) +
    #     labs(x = "Word", y = "Frequency",
    #          subtitle = paste0(comma(n_reviews), " reviews")) +
    #     coord_flip() + 
    #     theme_minimal(base_size = 14)
    
    res <- list(
        n_reviews = n_reviews,
        polarity = polarity,
        top_words = top_words
        # barplot = barplot
    )
    
    return(res)
}

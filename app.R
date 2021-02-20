library("shiny")
library("shinythemes")
library("ggplot2")
library("DT")
library('stringr')
library("tidyr")
library("dplyr")
library("readr")

source(file = "analyze_reviews.R")
source(file = "utils.R") # ggplot custom theme

my_pal <- c("#f72585", "#b5179e", "#7209b7", "#480ca8", "#3f37c9", "#4361ee", "#4895ef", "#4cc9f0")

# data loading
reviews_data <- read_csv(
  file = './data/reviews.csv',
  col_types = cols(
    date = col_datetime(format = ""),
    rating = col_double(),
    .default = col_character()
  )
)

classified <- read_csv(
  file = './data/classified.csv',
  col_types = cols(
    .default = col_character()
  )
)

# data transformation
years_list <- 2015:2018

n_cat <- max(sapply(reviews_data$primaryCategories, function(x) str_count(x, ",")))

col_names <- paste0("X__", 1:(n_cat + 1))

reviews_data <- reviews_data %>% 
  mutate(id = 1:nrow(.),
         year = lubridate::year(date)) %>% 
  filter(year %in% years_list) %>% 
  separate(
    primaryCategories, 
    sep = ",", 
    into = col_names
  ) %>% 
  gather(aux, category, col_names) %>% 
  filter(!is.na(category))

# WARNING: uncomment only for testing!!
# reviews_data <- reviews_data %>%
#   sample_n(size = 1000)

# helpers for inputs
primary_categories <- reviews_data %>% 
  count(category, sort = TRUE) %>% 
  filter(n > median(n)) %>% 
  pull(category)

ui <- fluidPage(
  # to add a bootstrap
  # themeSelector(),
  theme = shinytheme("flatly"),
  
  # app title
  titlePanel("Amazon Reviews Analyzer"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      # select years to be included in the analysis
      checkboxGroupInput(
        inputId = "years",
        label = "Select years:",
        choices = years_list,
        selected = years_list
      ),
      
      # select the primary categories
      selectInput(
        inputId = "pcategories",
        label = "Select primary category(ies):",
        choices = primary_categories,
        multiple = TRUE,
        selected = primary_categories[1]
      ),
      
      # number of stars
      sliderInput(
        inputId = "stars",
        label = "Select ratings:",
        min = 1,
        max = 5,
        value = c(1, 5),
        step = 1,
        dragRange = TRUE,
        ticks = FALSE
      ),
      
      # words to be excluded
      textInput(
        inputId = "non_words",
        label = "Words to be excluded:", 
        placeholder = "Insert the words separated by commas"
      ),
      
      # analyze button
      actionButton(
        inputId = "go", 
        label = "Analyze"
      ),
      
      downloadButton(
        outputId = 'download_selection', 
        label = "Download data"
      ),
    ),
    
    mainPanel(
      
      tabsetPanel(
        tabPanel(
          title = "Wordcloud",
          h3("Words in negative ratings (1 & 2)"),
          plotOutput(outputId = "wcnegative"),
          br(),
          
          h3("Words in neutral ratings (3)"),
          plotOutput(outputId = "wcneutral"),
          br(),
          
          h3("Words in positive ratings (4 & 5)"),
          plotOutput(outputId = "wcpositive")
        ),
        
        tabPanel(
          title = "Analysis by Word",
          plotOutput(outputId = "pwords", width = 800, height = 600)
        ),
        
        tabPanel(
          title = "Analysis by Review",
          plotOutput(
            outputId = "previews", 
            width = 800, 
            height = 600, 
            brush = 'user_selection'
          ),
          DT::dataTableOutput(outputId = "table_reviews")
        )
      )
    )
  )
)

# define server function
server <- function(input, output, session) {
  
  reviews_analysis <- eventReactive(input$go, {
    
    if (!is.null(input$non_words)) {
      non_words <- str_trim(unlist(strsplit(input$non_words, ",")))
    } 
    else { 
      non_words <- NULL
    }
    
    reviews_data %>%
      filter(
        year %in% input$years,
        category %in% input$pcategories,
        rating >= input$stars[1] & 
          rating <= input$stars[2]
      ) %>% 
      analyze_reviews(
        sentiments = classified,
        non_words = non_words
      )
  })
  
  output$wcnegative <- renderPlot({
    
    reviews_analysis()$top_words %>%
      filter(rating < 3) %>% 
      with(
        wordcloud(
          words = word, 
          freq = n, 
          random.order = FALSE,
          scale = c(3, .5), 
          rot.per = .30,
          min.freq = 2, 
          max.words = 150,
          colors = my_pal[1:3]
        )
      )
    
  })
  
  output$wcneutral <- renderPlot({
    
    reviews_analysis()$top_words %>%
      filter(rating == 3) %>% 
    with(
      wordcloud(
        words = word, 
        freq = n, 
        random.order = FALSE,
        scale = c(3, .5), 
        rot.per = .30,
        min.freq = 2, 
        max.words = 150,
        colors = c(gray(.9), my_pal[4:5])
      )
    )
    
  })
  
  output$wcpositive <- renderPlot({
    
    reviews_analysis()$top_words %>%
      filter(rating > 3) %>% 
    with(
      wordcloud(
        words = word, 
        freq = n, 
        random.order = FALSE,
        scale = c(3, .5), 
        rot.per = .30,
        min.freq = 2, 
        max.words = 150,
        colors = my_pal[6:8]
      )
    )
    
  })
  
  output$pwords <- renderPlot({
    
    # uncomment only for testing!!
    # analyzed <- reviews_data %>%
    #   analyze_reviews(
    #     sentiments = classified,
    #     non_words = NULL
    #   )
    
    data <- reviews_analysis()$polarity_words %>%
      # analyzed$polarity_words %>%
      group_by(class, category, rating) %>% 
      top_n(n = 3, wt = n_reviews)
    
    n_reviews <- reviews_analysis()$n_reviews
    
    ggplot(data, 
           aes(
             y = word, 
             x = elaboration,
             size = n_reviews,
             color = class
           )) +
      geom_point() +
      facet_grid(
        facets = category ~ rating, 
        scales = "free_y"
      ) +
      scale_color_manual(
        values = c("negative" = my_pal[1],
                   "neutral" = my_pal[4],
                   "positive" = my_pal[8]),
        limits = c("negative", "neutral", "positive"),
        name = "Sentiment"
      ) +
      labs(x = "Elaboration\n(average number of words used in review)",
           y = "",
           title = "Sentiment Analysis by Rating & Category",
           subtitle = paste0("Total No. of Reviews: ", comma(n_reviews))) +
      my_theme
    
  })
  
  polarity_reviews <- reactive({
    
    req(input$pcategories)
    reviews_analysis()$polarity_reviews %>% 
      # analyzed$polarity_reviews %>% 
      left_join(reviews_data, by = c('id', 'date')) %>%
      filter(category %in% input$pcategories) %>% 
      select(
        product = name,
        category, 
        date, 
        rating, 
        review, 
        polarity,
        elaboration
      ) %>% 
      mutate(polarity = round(polarity, digits = 2))
  })
  
  output$previews <- renderPlot({
    
    polarity_reviews() %>% 
      ggplot(aes(
        x = date, 
        y = polarity,
        size = elaboration,
        color = factor(rating)
      )) +
      geom_point(alpha = .65) +
      facet_grid(category ~ .) +
      scale_y_continuous(limits = c(-1, 1)) +
      scale_size_continuous(range = c(1, 5)) +
      scale_color_manual(
        values = my_pal[c(1, 3, 5, 7, 8)], 
        name = "rating"
      ) +
      labs(x = "Date", y = "Polarity") +
      theme_minimal(base_size = 12) +
      my_theme
    
  })
  
  brushed <- reactive({
    brushedPoints(
      df = polarity_reviews() %>% select(-elaboration), 
      brush = input$user_selection
    )
  })
  
  output$table_reviews <- DT::renderDataTable({
    brushed()
  })
  
  output$download_selection <- downloadHandler(
    filename = function() {
      paste('AmazonNLP-brushed', Sys.Date(), '.csv', sep = '')
    },
    content = function(file){
      write.csv(brushed(), file)
    }
  )
}

# run the application
shinyApp(ui = ui, server = server)
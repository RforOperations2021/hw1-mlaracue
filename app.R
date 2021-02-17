library("shiny")
library("shinythemes")
library("ggplot2")
library("DT")
library('stringr')
library("tidyr")
library("dplyr")
library("readr")

reviews_data <- read_csv(
  file = './data/reviews.csv',
  col_types = cols(
    date = col_datetime(format = ""),
    rating = col_double(),
    .default = col_character()
  )
)

ui <- fluidPage(
  # to add a bootstrap
  themeSelector(),
  
  sidebarLayout(
    
    sidebarPanel(
      # here goes the inputs
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel(
          title = "Wordcloud",
          plotOutput(outputId = "wordcloud")
        ),
        
        tabPanel(
          title = "Top words",
          plotOutput(outputId = "top_words")
        ),
        
        tabPanel(
          title = "Polarity",
          plotOutput(outputId = "polarity")
        )
      )
    )
  )
)

# define server function
server <- function(input, output, session) {
  
}

# run the application
shinyApp(ui = ui, server = server)
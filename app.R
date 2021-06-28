
library(shiny)
library(tidyverse)
covid19 <- read_csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv")

dates_where_20 <- covid19 %>% group_by(state) %>%
  filter(cases >= 20) %>%
  group_by(state) %>%
  summarize(date_where_20 = min(date))
data <- covid19 %>%
  left_join(dates_where_20, by = "state") %>%
  mutate(days_since_20 = date - date_where_20) %>%
  filter(days_since_20 >= 0)
choices <- data %>%
  group_by(state) %>%
  summarize()

ui <- fluidPage(
  selectInput("states", 
              "states",
              choices = choices$state, multiple = TRUE),
  submitButton(text = "Create my plot!"),
  plotOutput(outputId = "myplot")
)

server <- function(input, output) {
  output$myplot <- renderPlot({
    data %>%
      filter(state %in% input$states) %>% 
      
      ggplot(aes(x = days_since_20, y = cases)) +
      geom_line(aes(color = state)) +
      scale_y_log10() +
      theme_minimal()
  })
}


shinyApp(ui = ui, server = server)
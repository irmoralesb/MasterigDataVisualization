# Interactive
  
library(dplyr)
library(RColorBrewer)
library(shiny)
library(ggplot2)
colors <- brewer.pal(4, "Set3")

## UI

ui <- fluidPage(
  titlePanel("Interactive Suicide Data"),
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        inputId = "year",
        label = "Year",
        min = 1985,
        max = 2016,
        value = c(1985, 2016),
        sep = ""),
      textInput(
        inputId = "country",
        label = "country")),
    mainPanel(
      plotOutput(
        outputId = "plot"))))


## Server
server <- function(input, output){
  output$plot <- renderPlot({
    suicide_rates_dataset <- read.csv("../data/SuicideRatesOverview1985-to-2016.csv")
    map <- map_data("world")
    
    suicide_dataset <- suicide_rates_dataset %>%
      left_join(map, by =c("country" = "region")) %>%
      filter(year >= input$year[1] & year <= input$year[2]) %>%
      filter(input$country == "" | grepl(input$country, country)) %>%
      select(
        country,
        Longitude = long,
        Latitude = lat,
        Group = group,
        Order = order,
        Suicides100k = suicides.100k.pop) %>%
      arrange(Order) %>%
      as.data.frame()
    
    plot <- ggplot(
      data = suicide_dataset) + 
      borders(
        database = "world",
        colour = "grey60",
        fill = "grey90") +
      xlab("") +
      ylab("") +
      theme(
        panel.background = element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank()) +
      geom_polygon(aes(
        x = Longitude,
        y = Latitude,
        group = Group,
        fill = Suicides100k),
        color = "grey60") +
      scale_fill_gradient(
        low = "white",
        high = "red") +
      ggtitle("Count of Suicides by Country") +
      labs(color = "Suicides")
    print(plot)
  })
}


## App
shinyApp(
  ui = ui,
  server = server)


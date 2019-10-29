library(shiny)
library(ggplot2)
library(dplyr)
library(ggvis)



shinyUI(fluidPage(
  
  titlePanel("Analyzing board games I've played"),
  
  sidebarLayout(
    sidebarPanel(
        sliderInput("playercount", "How many people can play?", 1,10, value=c(2,4)),
        sliderInput("playtime", "How many minutes does the game take?", 0,240, value=c(30,120), step=10),
        sliderInput("complex", "What is the complexity rating?", 1,5, value=c(1.0,5.0), step=.1),
        tags$small(paste0(
           "Note: The community on boardgame geek uses a 5 point scale to measure the complexity",
            "of a game (i.e., community rating for how difficult a game is to understand) where a",
           "lower rating means easier to learn."
        )),
        h3(),
        sliderInput("year", "What year was the game published?", 1980,2019, value=c(1990,2019), sep = ""),
        numericInput("rank", "Only display games ranked this or better", value=10000),
        tags$small(paste0(
            "A lower number means the game is rated more favorably by the boardgamegeek community"
        )),
        h3(),
        checkboxGroupInput("own", "Do I own the game", choices = list("Yes"=1, "No"=0), selected=c(1,0))
        
    ),
    
    mainPanel(
        ggvisOutput("plot1"),
        wellPanel(
            span("Number of games displayed:",
                 textOutput("n_games")
            )
        )
    )
  )
))

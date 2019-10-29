library(shiny)
library(ggplot2)
library(dplyr)
library(ggvis)



data <- read.csv("collection.csv")
#keep only columns I care about
data <- data[,c(1,2,3,4,6,22,23,24,27,28,29,30,33)]
#keep only games I've rated and have at least one registred play
data <- subset(data, rating>0 & !is.na(numplays) & rank>0)
#rename columns
names(data) <- c("Game","ID", "Personal.Rating", "#.of.plays", "Own", "BGG.Rating", "Complexity.Rating",
                 "BGG.Rank", "Name", "Min.Players", "Max.Players", "Playing.Time", "Year.Published")
#removed rows with duplicated IDs
data <- data[!duplicated(data$ID),]



shinyServer(function(input, output) {
 
    # Filter the games, returning a data frame
    games <- reactive({
        # Due to dplyr issue #318, we need temp variables for input values
        rank <- input$rank
        minplayer <- input$playercount[1]
        maxplayer <- input$playercount[2]
        mintime <- input$playtime[1]
        maxtime <- input$playtime[2]
        mincomplex <- input$complex[1]
        maxcomplex <- input$complex[2]    
        minyear <- input$year[1]
        maxyear <- input$year[2]
        owner <- input$own
 
            #display message if all ownership boxes unchecked.
        validate(
            need(input$own != "", 'Choose level of ownership.')
        )

           
    # Apply filters
    g <- data %>%
        filter(
            BGG.Rank <= rank,
            Min.Players <= minplayer,
            Max.Players >= maxplayer,
            Playing.Time >= mintime,
            Playing.Time <= maxtime,
            Complexity.Rating >= mincomplex,
            Complexity.Rating <= maxcomplex,
            Year.Published >= minyear,
            Year.Published <= maxyear,
            Own %in% owner
        ) 
 
    g <- as.data.frame(g)
    
    # Add column which says whether I own
    g$do_own <- character(nrow(g))
    g$do_own[g$Own == 0] <- "No"
    g$do_own[g$Own >= 1] <- "Yes"
    g

    })
    

    # Function for generating tooltip text
    game_tooltip <- function(x) {
        if (is.null(x)) return(NULL)
        if (is.null(x$ID)) return(NULL)
        
        # Pick out the game with this Game ID
        data <- isolate(games())
        game <- data[data$ID == x$ID, ]
        
        #This is the info that will be in the hover text
        paste0("<b>", game$Name, "</b><br>",
               "Year:", game$Year, "<br>",
               "BGG Rank:", game$BGG.Rank, "<br>"
        )
    }

    # A reactive expression with the ggvis plot
    vis <- reactive({
        games %>%
            ggvis(x = ~jitter(Personal.Rating, factor = 6), y = ~BGG.Rating) %>%
            layer_points(size := 50, size.hover := 200,
                         fillOpacity := 0.2, fillOpacity.hover := 0.5,
                         stroke = ~do_own, key := ~ID) %>%
            add_tooltip(game_tooltip, "hover") %>%
            add_axis("x", title = "Personal Rating") %>%
            add_axis("y", title = "BGG Rating") %>%
            add_legend("stroke", title = "Own", values = c("Yes", "No")) %>%
            scale_nominal("stroke", domain = c("Yes", "No"),
                          range = c("orange", "#aaa")) %>%
            set_options(width = 750, height = 750)
    })  

    vis %>% bind_shiny("plot1")
  
    output$n_games <- renderText({ nrow(games()) })
  
})

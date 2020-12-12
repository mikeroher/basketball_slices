#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(stringr)

source("PolarChartsNBA.R", local=TRUE)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Basketball Slices"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            selectizeInput("playerName", "Player Name", choices=setNames(
                playerStats$namePlayer,
                paste0(playerStats$namePlayer, " [", playerStats$slugTeamBREF, "]")
                )
            ),
            downloadButton(outputId = "down", label = "Download the chart!"),
            width = 12
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("distPlot", width = "100%", height=750),
           width = 12
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    output$distPlot <- renderPlot(polar.graph(input$playerName))
    
    output$down <- downloadHandler(
        filename =  function() {
            paste(input$playerName, "png", sep=".")
        },
        # content is a function with argument file. content writes the plot to the device
        content = function(file) {
            device <- function(..., width, height) {
                grDevices::png(..., width = width, height = height,
                               res = 300, units = "in")
            }
            ggsave(file, plot = polar.graph(input$playerName), device = device)
        } 
    )
}

# Run the application 
shinyApp(ui = ui, server = server)

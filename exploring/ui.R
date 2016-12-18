library('shiny')
library('dplyr')

# NOTE: Participants 37 and 16 have quite a high understanding of 'about half'
# but let's keep it for now ...

# still has the 10, 11, 15, 22, 34 in the data set (they were rejected in the final data analysis)
dat = read.csv('../data/cleaned_data.csv', stringsAsFactors = FALSE)

shinyUI(fluidPage(
    titlePanel("Traceplots and Model Predictions"),
    sidebarLayout(
        sidebarPanel(
            selectInput("id", label = "Participant",
                        choices = setNames(unique(dat$id), seq(50))),
            selectInput("model", label = "Model",
                        choices = c('distance', 'closer', 'barker')),
            selectInput("quantifier", label = "Quantifier",
                        choices = c('Half', 'About half', 'Less than half', 'Few', 'Very few',
                                    'Many', 'Most', 'The majority', 'Some', 'Almost all')),
            checkboxInput("plotQuant", label = "Plot quantifier")
        ),
        
        mainPanel(
            tabsetPanel(
                tabPanel("Plot", plotOutput("modelPlot")),
                tabPanel("Table", dataTableOutput("table"))
            )
        )
    )
))
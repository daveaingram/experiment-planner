
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Experiment Planner"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      h4("Basic settings"),
      textInput("choices",
                "Names of Choices:",
                value = "Option A, Option B"),
      helpText("Enter a comma separated list of choices"),
      sliderInput("days",
                  "Number of days:",
                  min = 2,
                  max = 50,
                  value = 14),
      sliderInput("count",
                  "Total trials per day:",
                  min = 100,
                  max = 10000,
                  value = 1000),
      sliderInput("rate",
                  "Average success rate:",
                  min = 1,
                  max = 100,
                  value = 3),
      hr(),
      h4("Experiment adjustments"),
      uiOutput("controlchoice"),
      uiOutput("adjustchoice"),
      sliderInput("effectsize",
                  "Experimental Effect (%)",
                  min = -100,
                  max = 100,
                  value = 10),
      helpText("How much of a simulated effect do you want for the above choice?"),
      actionButton("goButton", "Run Simulation!")
    ),

    # Show a plot of the generated distribution
    mainPanel(
        tabsetPanel(
            tabPanel("Simulation",
                     uiOutput("helptext"),
                     plotOutput("simulation"),
                     tableOutput("simulationSummary")
            ), 
            tabPanel("Calculations",
                     uiOutput("power")
            ) 
        )
    )
  )
))

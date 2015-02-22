
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
            ),
            tabPanel("Documentation",
                     h3("Simulation"),
                     p("To get started with Experiment Planner, you can simply
                       click on 'Run Simulation' at the bottom of the left
                       panel and the first simulation will be run. There are
                       many settings which can also be tweaked, which are 
                       described here"),
                     h4("Names of Choices"),
                     p("Here you can name the variations that will be a part
                       of your experiment. You can enter a comma separated list,
                       and the simulation will adjust to have the correct number
                       of variations with the correct names"),
                     h4("Number of Days"),
                     p("Selecting a number of days for the simulation to run
                       will adjust both the simulation and the resulting graph.
                       It will also effect the calculation of p values since
                       there will be more or less values in the corresponding
                       t test."),
                     h4("Total Trials Per Day"),
                     p("Average number of trials to be simulated in a single 
                       day."),
                     h4("Average Success Rate"),
                     p("What percentage of variations should be set as a 'success'?
                       You will have the opportunity to adjust one variation up
                       or down to see how that effects the resulting experiment."),
                     h4("Select Control"),
                     p("When calculating the p-values, which group should be 
                       considered the control group?"),
                     h4("Experiment Group to Boost"),
                     p("The Experimental Effect control will adjust this group
                       by that percentage. This allows for the simulation to 
                       become more or less likely to find a signicant winner."),
                     h4("Experimental Effect"),
                     p("This will be the relative percentage of successes that
                       are altered by in the group above. This means that if
                       the simulation initially yields 100 successes for a day,
                       and the effect is set to +10%, the result will be 110
                       successes for that day"),
                     h3("Calculations"),
                     p("On this tab, you will be able to see the statistical 
                       power calculation that results from the parameters on 
                       this page as well as the experimental effect in the 
                       left hand toolbar"),
                     h4("Alpha level"),
                     p("This allows you to set the statistical significance. It
                       defaults to 0.05 which is the same as a 95% statistical
                       confidence."),
                     h4("Beta level"),
                     p("Statistical Power is equal to 1 - beta, so if you want
                       a statistical power of 80%, set beta to 0.2")
                )
        )
    )
  )
))

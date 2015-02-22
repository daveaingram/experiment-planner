
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(ggplot2)
library(reshape)
library(stringr)
library(grid)

shinyServer(function(input, output) {
  choices <- reactive({
    input$goButton
    choices <- isolate(parseChoices(input$choices))
    choices
  })
  data <- reactive({
    input$goButton
    data <- isolate(simulateData(choices(), input$days, 
                                 input$count, input$rate, 
                                 input$boost, input$effectsize))
    data
  })
  
  output$simulation <- renderPlot({
    input$goButton
    
    if(input$goButton > 0) {
        # draw the graph
        df <- isolate(data())
        for(i in 2:nrow(df)) {
            for(j in 2:ncol(df)) {
                df[i,j] <- mean(df[1:i,j])
            }
        }
        df <- melt(df, id="date")
        qplot(date, value, data=df, color=variable, geom="line",
              main = "Simulated Cumulative Average Conversion Rate Per Day",
              xlab = "", ylab="Conversion Rate (%)") + 
              theme(axis.title.x=element_text(vjust=-2)) +
              theme(axis.title.y=element_text(angle=90, vjust=2)) +
              theme(plot.title=element_text(size=15, vjust=3)) +
              theme(plot.margin = unit(c(1,1,1,1), "cm"))
    }
  })
  
  output$simulationSummary <- renderTable({
      input$goButton
      if(input$goButton > 0) {
          table <- data.frame("Name" = character(),
                              "P Value" = numeric())
          
          control.index <- grep(input$control, choices())
          choices <- choices()
          data <- data()
          for(i in 1:length(choices)) {
              ttest <- t.test(data[,i+1], 
                              data[,control.index+1], 
                              alternative = "greater")
              table <- rbind(table, data.frame("Name" = choices()[i], 
                                               "P Value" = round(ttest$p.value, 4)))
              table[control.index, 2] <- '--'
          }
          
          table
      }
  })
  
  output$adjustchoice <- renderUI({
      if(!is.null(input$boost)) {
          select <- input$boost
      } else {
          select <- "Option B"
      }
      selectInput("boost",
                  "Select Experiment group to boost:",
                  choices = choices(),
                  selected = select
      )
  })
  
  output$controlchoice <- renderUI({
      selectInput("control",
                  "Select Control:",
                  choices = choices()
      )
  })
  
  output$helptext <- renderUI({
      input$goButton
      if(input$goButton < 1) {
          list(
              h3("Welcome!"),
              p("Use the controls to the left to configure the parameters
                of an experiment. Once configured (or feel free to just
                use the defaults), click on 'Run Simulation'
                and a randomized set of data will be generated for you and
                a graph appear here which will reflect the cumulative average
                of all simulations. This data simulates what
                one might find in an A/B test run on a website"),
              p("Keep an eye on the summary below the graph and especially
                the P Values that are generated. It may be interesting to
                note how many times an experiment needs to be run before
                finding a 'highly significant' result, even if the boosted
                value is set to 0")
          )
      }
  })
  
  output$power <- renderUI({
      pwr <- pwr.t.test(d = abs(input$effectsize) / 100, 
                        sig.level = ifelse(is.null(input$alpha), 0.05, as.numeric(input$alpha)), 
                        power = 1 - ifelse(is.null(input$beta), 0.2, as.numeric(input$beta)), 
                        type = c("two.sample"))
      list(
          h3("Statistical Power"),
          p(
              "Using a sufficient sample size is essential when running an 
              experiment. Given a minimum effect of ",
              paste(abs(input$effectsize), '%,', sep=""),
              'a significance level of',
              paste(100 - as.numeric(input$alpha) * 100, 
                    '%, (alpha = ', as.numeric(input$alpha), ')', sep=""),
              'and a statistical power of ',
              paste(100 - as.numeric(input$beta) * 100, 
                    '%, (alpha = ', as.numeric(input$beta), ')', sep=""),
              ', you will need ',
              strong(round(pwr$n)), 'observations per experiemental group.'
          ),
          hr(),
          textInput('alpha',
                       'Set an alpha level',
                       value = ifelse(!is.null(input$alpha), input$alpha, '0.05')),
          helpText('the significance or alpha (α) level is the probability of 
                   rejecting the null hypothesis given that it is true.'),
          textInput('beta',
                    'Set a beta level',
                    value = ifelse(!is.null(input$beta), input$beta, '0.2')),
          helpText('The power or sensitivity of a statistical test is the 
                   probability that it correctly rejects the null hypothesis 
                   (H0) when it is false. It can be equivalently thought of 
                   as the probability of correctly accepting the alternative 
                   hypothesis (H1) when it is true - that is, the ability of a 
                   test to detect an effect, if the effect actually exists. ')
      )
  })
})

#########################################################
####  Helper Functions                               ####
#########################################################

simulateData <- function(choices, days, count, rate, boost, effectsize) {
    # Determine Dates to be used for simulation
    today <- Sys.Date()
    startDate <- today - (days - 1)
    dates <- seq.Date(startDate, today, by = 1)
    
    num.choices <- length(choices)
    total <- days * num.choices
    
    # Generate the raw counts per day
    counts <- matrix(data = rpois(total, count), 
                     nrow = days, 
                     ncol = num.choices)
    
    # Calculate the success rate by converting percent to decimal and multiply
    # by the count
    successes <- matrix(rpois(total, count * rate / 100),
                        nrow = days,
                        ncol = num.choices)
    
    # The choice that's selected for adjustment can now get a boost
    index <- grep(boost, choices)
    successes[,index] <- successes[,index] + successes[,index] * effectsize / 100

    rates <- round(successes / counts * 100, 2)
    
    # Manipulate the data so I can graph it how I want to
    df <- data.frame(rates)
    colnames(df) <- choices
    df <- data.frame(date = dates, df)
    df
}

run.ttest <- function(control, boost, data, choices) {
    control.index <- grep(control, choices) + 1
    boost.index <- grep(boost, choices) + 1
    ttest <- t.test(data[,boost.index], 
                    data[,control.index], 
                    alternative = "greater")
    ttest
}

parseChoices <- function(choices) {
    choices <- strsplit(choices, split = ",")[[1]]
    choices <- str_trim(choices)
    choices
}
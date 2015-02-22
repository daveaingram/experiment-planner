## Shared functionality between application and presentation

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
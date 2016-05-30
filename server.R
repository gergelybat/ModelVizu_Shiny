library(shiny)
library(ggplot2)

model2dispay <- lm(mpg ~ hp + I(hp^2) +wt + disp + wt:disp + cyl + drat , mtcars)

# TODO:
# Curretly the script takes the whole model as an input (including the data frame)
# This is ineffective if dataset is huge. Instead we need only formula+ranges
allVars <- all.vars(formula(model2dispay), unique = TRUE)
inputVars <- allVars[-1]
numInputVars <- length(inputVars)
outputVar <- allVars[1]
NUMPOINS <- 20

selectedValues <- 1:numInputVars

# calculate range (needed for ploting the axis) and grid. This is fixed across all Shyni sessions.
range_outputVar <- range(model2dispay$model[[outputVar]])
rangeOfVars <- matrix(ncol=2,nrow=numInputVars)
pointsOfVars <- matrix(ncol=NUMPOINS,nrow=numInputVars)
for (k in 1:numInputVars){
rangeOfVars[k,] <- range(model2dispay$model[[inputVars[k]]])
pointsOfVars[k,] = seq(rangeOfVars[k,1], rangeOfVars[k,2], length=NUMPOINS)
}


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  # calculate mean: this will be the default selected point
  for (k in 1:numInputVars){
    selectedValues[k] <- mean(model2dispay$model[[inputVars[k]]])
  }
  

  vals <- reactiveValues(
    selectedValues=selectedValues
  )


  output$plots <- renderUI({
    plot_output_list <- lapply(1:numInputVars, function(i) {
      plotname <- paste("plot", i, sep="")
      clickname <- paste("click", i, sep="")
      column(3,plotOutput(plotname, click=clickname, height = 200, width = 300))
    })
    # Convert the list to a tagList - this is necessary for the list of items
    # to display properly.
    do.call(tagList, plot_output_list)
  })
  
  # Call renderPlot for each one. Plots are only actually generated when they
  # are visible on the web page.
  for (i in 1:numInputVars) {
    # Need local so that each item gets its own number. Without it, the value
    # of i in the renderPlot() will be the same across all instances, because
    # of when the expression is evaluated.
    local({
      my_i <- i
      plotname <- paste("plot", my_i, sep="")

      output[[plotname]] <- renderPlot({
print(paste0("DEBUG: in renderPlot ",plotname))
        inputVar <-inputVars[my_i]
        #preparing df and calaculating predictions
        df <- data.frame(1:NUMPOINS)
        for(k in 1:numInputVars){
          if (k==my_i){
            df[inputVars[k]] <- pointsOfVars[k,]
          }
          else {
            df[inputVars[k]] <- vals$selectedValues[k]
          }
        }
        pointsOfOutput <- predict(model2dispay, df)

        
        #preparing df and calaculating one predictions for horiyontal line
        df_one <- data.frame(1)
        for(k in 1:numInputVars){
          df_one[inputVars[k]] <- vals$selectedValues[k]
        }
        selected_y <- predict(model2dispay, df_one)
        
        #preparing df and plotting
        df_plot <- data.frame(pointsOfVars[my_i,], pointsOfOutput)
        names(df_plot)[1] <-  inputVar
        names(df_plot)[2] <-  outputVar
         ggplot(data=df_plot, aes_string(x=inputVar, y=outputVar))+
            xlim(rangeOfVars[my_i,1], rangeOfVars[my_i,2])+
            ylim(range_outputVar[1], range_outputVar[2])+
           geom_line()  +
            geom_vline(xintercept=vals$selectedValues[my_i], colour="red")+
            geom_hline(yintercept=selected_y, colour="red")

      })
    })
  }  


# whenever user click on a plot, we need to recalc all the values
  for(k in 1:numInputVars){
    local({
      my_k <- k
      clickname <- paste("click", k, sep="")
      observeEvent(input[[clickname]], {
        print(paste0("DEBUG: IN OBS ", clickname))
        vals$selectedValues[my_k] <- input[[clickname]]$x
      })
    })
  }
  
})

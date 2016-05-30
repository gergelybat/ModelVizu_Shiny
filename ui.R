
allVars <- all.vars(formula(mtcars_model), unique = TRUE)

shinyUI(fluidPage(
  
  titlePanel("Model vizu"),
    fluidRow(
    uiOutput("plots") # This is the dynamic UI for the plots
    )
  )
)

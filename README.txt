This App uses R+Shiny to visualize a fitted model.
It creates as many plots as there are input variables in the model.
Each plot is a drawing of Y vs. X given all the rest of the input variables.
You can click on a plot: as a result all of the plots will be updated.

In server.R  you can change the formula of the model:
- you can remove or include variables
- you can create non-linearities, interactions
- you can change the dataframe.
- you can swiths to another model type (glm for example)
The App will discover used variables and will create plots accordingly.

The App works with all kinds of models, that support the predict() and formula() function and the $model property.

Things that could be improved:
- performance improvements: lapply instead of loops
- improve appearance: use a HTML container that arranges all the plots in one row.


Future:
-dynamically fetch (a user provided) model, and make plots
-use just the formula and provided ranges to create plots
-use client side updates: this would be possible with heavy JavaScript coding, or with Shiny add-ons (shinyDashboard, shinySignals, plotly, metrics,...).
-plot more Y variables at the same time
-confidence intervals
-categorical variables

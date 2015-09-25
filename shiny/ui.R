library(shiny)
library(ggplot2)

shinyUI(fluidPage(theme = "bootstrap.css",
	titlePanel("Fuel economy surveyor"),
               
	sidebarLayout(
		sidebarPanel(
			br(),
			h3("Description"),
			p("Simple Shiny app based on ggplot's mpg data set.",
			  "Based on two user selectable variables 'Transmission type' and",
			  "'Travel type', a simple overall fuel economy average is calculated.",
			  "The table tab panel reflects the filtering on the data set.",
			  "The plot tab panel shows per car their fuel economy change over",
			  "a 10-year period. The plot also updates based on the user's filtering."),
			br(),
			checkboxGroupInput('trans.check', label = h3("Transmission type"), 
                                           choices = list("Manual" = 'manual', "Automatic" = 'auto'), selected = list('manual','auto')),
		        helpText("Note: when no transmission is selected",
		                 "the values will be restored to their defaults",
		                 "after submitting."),
			radioButtons('fuel.radio', label = h3("Travel type"),
				     choices = list("City" = 'cty', "Highway" = 'hwy'), selected = 'cty')
                                
			#submitButton("Submit")
                ),

                mainPanel(
                        tabsetPanel(
                                tabPanel("Summary",
                                        #verbatimTextOutput('z'),
                                        h3("Selected values:"),
		                        helpText("This section shows the entered values in their raw format",
		                                 "after submitting."),
                                        h4("Transmission"),
                                        verbatimTextOutput('x1'),
                                        br(),
                                        h4("Fuel economy"),
                                        verbatimTextOutput('x2'),
                                        br(),
                                        
                                        h3("Results:"),
		                        helpText("The values below are calculated for the table subset,",
		                                 "based on the selection in the panel on the left, and grouped by year."),
                                        h4("Average fuel economy (mpg)"),
                                        #verbatimTextOutput('y1'),
		                        tableOutput('y1tab')
                                ), 
                                tabPanel("Table", 
                                        br(),
                                        dataTableOutput("tableview")
                                ),
                                tabPanel("Plot",
                                         br(),
                                         p("Just a very basic slope graph. Darker points or lines means more overlapping data."),
                                         plotOutput("plot", height="750px"),
                                         helpText("Note: Data is not cleaned and not complete;",
                                                  "some cars are not present for all years, some",
                                                  "are even listed twice in the same year. Hence",
                                                  "some slopes are missing.")
                                ), 
                                tabPanel("About",
                                        br(),
                                        h4("Usage"),
                                        p("In the left panel select the filtering options required.",
                                          "You can opt for manual transmission, automatic transmission or both;",
                                          "Then choose the kind of mileage to take into account, either city",
                                          "traffic or highway travel."
                                          ),
                                        h4("Results"),
                                        p("In the main panel the raw values of the chosen filtering is shown.",
                                          "Below that the averave mileage of the filtered data is calculated",
                                          "grouped by year.",
                                          "The filtering is reflected in the table in the 'Table' tab panel",
                                          "showing only the filtered data. In the 'Plot' tab panel a basic",
                                          "slope graph is plotted. "
                                          ),
                                        p("Changes in the filtering are reflected instantly in all tab panels"),
                                        h4("Source"),
                                        helpText(a("Click here to see the source on GitHub",
                                                   href="https://github.com/d8a-sci/devdataprod/tree/master/shiny",
                                                   target="_blank")
                                        )
                                ),
                                tabPanel("Codebook",
                                        br(),
                                        htmlOutput('mpghelp')
                                )
                        )
                )
	)
))

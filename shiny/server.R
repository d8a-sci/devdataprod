library(shiny,           quietly = TRUE, warn.conflicts=FALSE)
library(data.table,      quietly = TRUE, warn.conflicts=FALSE)
library(dplyr,           quietly = TRUE, warn.conflicts=FALSE)
library(ggplot2,         quietly = TRUE, warn.conflicts=FALSE)
library(ggthemes,        quietly = TRUE, warn.conflicts=FALSE)

dt      <- data.table(mpg)
dt      <- dt %>% mutate( trans  = factor(gsub("(.*)\\(.*","\\1",trans)), grp=factor(paste0(manufacturer,model,displ,cyl,trans,drv)) ) %>% select(manufacturer:hwy,grp)

shinyServer(
        function(input, output, session) {
                n   <- reactive({length(input$trans.check)})
                observe({
                        if ( n() == 0) {
                                updateCheckboxGroupInput(session, 'trans.check', selected = list('manual','auto'))
                                #output$z <- renderPrint({input$trans.check})
                        }
                })
                dt.filter   <- reactive({
                        if ( n() == 1 )
                                ifelse( input$trans.check[[1]] == "manual", 'trans=="manual"', 'trans=="auto"')
                        else
                                'trans=="manual" | trans=="auto"'
                })
                mpg.label <- reactive({
                        if ( n() == 1 )
                                ifelse( input$trans.check[[1]] == "manual", "with manual transmission\n", "with automatic transmission\n")
                        else
                                "with any transmission\n"
                })
                travel <- reactive({input$fuel.radio})
                travel.label <- reactive({
                        switch( input$fuel.radio,
                                 "cty" = "Fuel economy in city traffic\n",
                                 "hwy" = "Fuel economy on highway travel\n")
                })
                
                output$x1 <- renderPrint({
                        input$trans.check
                })
                output$x2 <- renderPrint({input$fuel.radio})
                
                output$y1tab <- renderTable({
                        t <- filter(dt, eval(parse(text=dt.filter()))) %>% group_by(year) %>% summarise(mean(eval(parse(text=travel()))))
                        colnames(t) <- c("Year","Average mpg")
                        t
                }, include.rownames=FALSE)
                output$y1 <- renderPrint({
                        mean( ( filter( dt, eval(parse(text=dt.filter())) ) %>% select( eval(parse(text=travel())) ) )[[1]] )
                })
                
                                
                getPage <- function() { return(includeHTML( "mpg.html" )) }
                output$mpghelp <-  renderUI({getPage()}) 
                
                
                # Show the data table
                output$tableview <- renderDataTable(filter(dt, eval(parse(text=dt.filter())) ), options = list(
                                        pageLength=10,
                                        lengthMenu = list(c(5,10,-1), c('5','10','All')),
                                        searching = FALSE
                                    ))
                
                # Show a simple plot f8f5f0
                output$plot <- renderPlot({
                        xvar <- 'year'
                        yvar <- travel()
                        title <- paste0(travel.label() , mpg.label())
                        dtp <- filter(dt, eval(parse(text=dt.filter())))
                        xs   <- as.numeric(levels(factor(dtp$year)))
                        #g <- eval(substitute(ggplot(dtp, aes(x=var1,y=var2)),list(var1 = as.name(xvar),var2 = as.name(yvar))))
                        #g <- g + geom_point()
                        g <- ggplot(dtp)
                        g <- g + eval(substitute(geom_line(aes(x=var1,y=var2, group=grp), alpha=0.6),list(var1 = as.name(xvar),var2 = as.name(yvar))))
                        g <- g + eval(substitute(geom_point(aes(x=var1,y=var2),size=3,alpha=0.1),list(var1 = as.name(xvar),var2 = as.name(yvar))))
                        g <- g + ggtitle(title)
                        g <- g + xlab("\nYear") + ylab("Fuel economy in mpg\n")
                        g <- g + theme_tufte(base_size=14) + scale_y_tufte()
                        g <- g + scale_x_continuous(limits=xs, breaks=xs)
                        g <- g + theme(plot.title=element_text(size=16, face="bold.italic"))
                        g <- g + theme(axis.title=element_text(face="bold"))
                        g
                })
        }
)

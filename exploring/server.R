library('VGAM')
library('dplyr')
library('shiny')
library('ggplot2')
library('reshape2')
library('RColorBrewer')
source('prepare_exploring.R')

shinyServer(function(input, output) {
    
    plotHeight = reactive({
        ifelse(input$plotQuant, 1200, 400)
    })
    
    output$modelPlot = renderPlot({
        test = melt_data(d, input$id, 'id')
        
        if (input$plotQuant) {
            test = melt_data(d, input$quantifier, 'quant')
        }
        
        test = mutate(test, predictions = test[[paste0('pred_', input$model)]]) %>%
            mutate(predictions_ggplot = ifelse(chose_higher, predictions, 1 - predictions))
        
        
        p = ggplot(test, aes(x = trial, y = value)) +
              geom_point(aes(color = predictions_ggplot), size = 3) +
              scale_colour_continuous(low = 'red', high = 'green', limits = c(0, 1)) +
            
              geom_path(data = filter(test, choice == 'number_chosen'), size = 1.2) +
              xlab('Trial') + ylab('Number') +
              geom_hline(yintercept = c(108, 216, 324, 432), linetype = 'dotted') +
              scale_y_continuous(breaks = scales::pretty_breaks(n = 15),
                                 limits = c(0, 432)) + theme_bw()
        
        if (input$plotQuant) {
            
            all_ids = unique(d$id)
            test_ids = unique(test$id)
            labels = as.list(sapply(test_ids, function(id) which(id == all_ids)))
            
            labeller = function(variable, value) {
                value = droplevels(value)
                labels[value]
            }
            
            p + facet_wrap(~ id, ncol = 3, labeller = labeller)
            
        } else {
            p + facet_wrap(~ quantifier)
        }
        
    }, height = plotHeight)
    
    output$table = renderDataTable({
        
        if (input$plotQuant) {
            test = melt_data(d, input$quantifier, 'quant')
        } else {
            test = melt_data(d, input$id, 'id')
        }
        
        test %>% 
            mutate(number_chosen = value) %>% 
            filter(choice == 'number_chosen') %>% 
            select(id_int, quantifier, trial, number_chosen, pred_distance, pred_closer, pred_barker)
    })
})
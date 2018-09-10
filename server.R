shinyServer(function(input, output) {

  text <- reactive({
    input$text
  })

  translations <- reactive({

    if (nchar(input$text)) {
      translate_text <- translate(text())
      lang_groups %>%
        multidplyr::cluster_assign_value("translate_text", translate_text) %>%
        mutate(translation = map2_chr(name, code, translate_text)) %>%
        collect() %>%
        as_tibble()
    } else {
      languages %>% mutate(translation = "")
    }
  })

  lapply(1:nrow(languages), function(i) {
    output[[paste0('translation', i)]] <- renderUI({
      tags$div(class = "panel panel-primary panel-sm",
               tags$div(class = "panel-heading",
                        tags$small(translations()$name[[i]])),
               tags$div(class = "panel-body",
                        translations()$translation[[i]]
               ))
    })
  })

})

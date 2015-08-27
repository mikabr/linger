library(shiny)
library(httr)
library(purrr)

shinyServer(function(input, output) {

  #   detect <- reactive({
  #     if (nchar(input$text)) {
  #       req <- GET("https://www.googleapis.com/language/translate/v2/detect",
  #                  query = list(key = app_key,
  #                               q = input$text)
  #       )
  #       content(req)$data$detections[[1]][[1]]$language
  #     }
  #   })
  #
  #   output$detection <- renderUI({
  #     tags$span(class = "label label-success", detect())
  #   })

  languages <- reactive({
    req <- GET("https://www.googleapis.com/language/translate/v2/languages",
               query = list(key = app_key,
                            target = "en")
               #                            target = detect())
    )
    discard(content(req)$data$languages, function(language) {
      language$language == "en"
    })
  })

  translate <- reactive({

    language_codes <- map(languages(), function(language) language$language)
    language_names <- map(languages(), function(language) language$name)
    if (length(languages())) {
      if (nchar(input$text)) {
        map2(language_codes, language_names, function(language_code, language_name) {
          req <- GET("https://www.googleapis.com/language/translate/v2",
                     query = list(key = app_key,
                                  # source = detect(),
                                  source = "en",
                                  target = language_code,
                                  q = input$text)
          )
          list(language = language_name,
               translation = content(req)$data$translations[[1]]$translatedText)
        })
      } else {
        map2(language_codes, language_names, function(language_code, language_name) {
          list(language = language_name,
               translation = "")
        })
      }
    }
  })

  output$loaded <- reactive({
    print(length(translate()))
    length(translate())
  })

  #   num_langs <- reactive({
  #     ifelse(is.na(languages()), 0, length(languages()))
  #   })

  lapply(1:num_langs, function(i) {
    output[[paste0('translation', i)]] <- renderUI({
      tags$div(class = "panel panel-primary",
               tags$div(class = "panel-heading",
                        tags$small(translate()[[i]]$language)),
               tags$div(class = "panel-body",
                        #tags$span(class = "label label-primary", translate()[[i]]$language),
                        #br(),
                        translate()[[i]]$translation
               ))
    })
  })

})

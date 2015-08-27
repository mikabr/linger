library(shiny)
library(shinythemes)

num_cols <- 6

shinyUI(fluidPage(
  theme = shinytheme("cosmo"),

  h1("linger ", tags$small("translate text into many languages at once")),

  fluidRow(
    column(width = 3,
           textInput("text", label = "")
    )
    # uiOutput("detection")
  ),

  hr(),
  #  hidden(textOutput("loaded")),
  #   conditionalPanel(condition = "input.text.length != 0 && output.loaded == 0",
  #                    "I'm busy!"),
  #   conditionalPanel(
  #     condition = "input.text.length > 0 && output.loaded != 0",
  lapply(1:ceiling(num_langs/num_cols), function(row) {
    fluidRow(
      lapply(1:num_cols, function(col) {
        if (col + num_cols * (row - 1) <= num_langs) {
          column(width = floor(12 / num_cols),
                 uiOutput(paste0('translation', col + num_cols * (row - 1)))
          )
        }
      })
    )
  }),
  #  )

  hr(),

  div(align = "center",
      helpText(
        # "© Mika Braginsky 2015 |",
        a(href = "https://github.com/mikabr/linger", "Source code"), "|",
        "Powered by", a(href = "https://translate.google.com/", "Google Translate"))
  )
))

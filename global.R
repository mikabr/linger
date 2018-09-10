library(glue)
library(shiny)
library(httr)
library(purrr)
library(shinythemes)
library(multidplyr)

num_cols <- 6
source <- "en"

Sys.setenv("GOOGLE_APPLICATION_CREDENTIALS" =
             glue("{here::here()}/linger-9f6ce9749810.json"))
tok <- system("/Users/mikabr/Downloads/google-cloud-sdk/bin/gcloud auth application-default print-access-token",
              intern = TRUE)

req <- GET("https://translation.googleapis.com/language/translate/v2/languages",
           add_headers("Authorization" = glue("Bearer {tok}")),
           query = list(target = source))

langs <- content(req)$data$languages
languages <- data_frame(name = unlist(transpose(langs)$name),
                        code = unlist(transpose(langs)$language)) %>%
  filter(code != source)

cores <- parallel::detectCores()
cluster <- multidplyr::create_cluster(cores = cores)

lang_groups <- languages %>%
  mutate(group = sample(rep(1:cores, length.out = n()))) %>%
  partition(group, cluster = cluster)

translate <- function(query) {
  function(name, code) {
    req <- GET("https://translation.googleapis.com/language/translate/v2",
               add_headers("Authorization" = glue("Bearer {tok}")),
               query = list(source = "en",
                            target = code,
                            q = query))
    content(req)$data$translations[[1]]$translatedText
  }
}

lang_groups %>%
  multidplyr::cluster_library("purrr") %>%
  multidplyr::cluster_library("httr") %>%
  multidplyr::cluster_library("glue") %>%
  multidplyr::cluster_assign_value("tok", tok) #%>%
  # multidplyr::cluster_assign_value("translate", translate("dog"))

# translations <- lang_groups %>%
#   mutate(translation = map2_chr(name, code, translate)) %>%
#   collect() %>%
#   as_tibble()

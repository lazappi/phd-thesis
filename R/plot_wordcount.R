suppressPackageStartupMessages({
    library("dplyr")
    library("ggplot2")
})

message("Reading wordcount data...")
words <- readr::read_tsv(here::here("docs/wordcount.txt"),
                         col_types = readr::cols(
                             Date = readr::col_date(format = ""),
                             Time = readr::col_time(format = ""),
                             Name = readr::col_character(),
                             Level = readr::col_character(),
                             Text = readr::col_integer(),
                             Headers = readr::col_integer(),
                             Captions = readr::col_integer(),
                             Total = readr::col_integer()
                         )) %>%
    mutate(Datetime = lubridate::ymd_hms(paste(Date, Time))) %>%
    mutate(Name = forcats::fct_inorder(Name))

plots <- list()

message("Creating document plot...")
plots$document <- words %>%
    filter(Level %in% c("Document")) %>%
    select(Datetime, Text, Headers, Captions, Total) %>%
    tidyr::gather(key = Type, value = Count, -Datetime) %>%
    ggplot(aes(x = Datetime, y = Count, colour = Type)) +
        geom_line() +
        labs(y = "Word count", colour = "Type") +
        theme_minimal() +
        theme(legend.position = "bottom")

message("Creating chapter plot...")
plots$chapters <- words %>%
    filter(Level %in% c("Chapter")) %>%
    ggplot(aes(x = Datetime, y = Text, colour = Name)) +
        geom_line() +
        labs(y = "Word count", colour = "Chapter") +
        theme_minimal() +
        theme(legend.position = "bottom")

message("Saving wordcount.pdf...")
pdf(here::here("docs/wordcount.pdf"))
for (plot in plots) {
    print(plot)
}
invisible(dev.off())

message("Done!")

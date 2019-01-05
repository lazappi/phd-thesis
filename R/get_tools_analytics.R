suppressMessages(
    library("googleAnalyticsR")
)

message("Getting OAuth token...")
if (!file.exists(here::here("googleAnalyticsR.httr-oauth"))) {
    stop("Missing googleAnalyticsR.httr-oauth, set up authentication")
}

ga_auth(token = here::here("googleAnalyticsR.httr-oauth"))

message("Setting GA id...")
ga_id <- "155271574"

message("Getting user data...")
users <- lapply(c("1dayUsers", "7dayUsers", "30dayUsers"), function(metric) {
    google_analytics(ga_id,
                     date_range = c("2017-07-15", as.character(Sys.Date())),
                     metrics = metric,
                     dimensions = "date")
})

users <- purrr::reduce(users, dplyr::left_join, by = "date")
colnames(users) <- c("Date", "Users1Day", "Users7Day", "Users30Day")

message("Getting country data...")
countries <- google_analytics(ga_id,
                              date_range = c("2017-07-15",
                                             as.character(Sys.Date())),
                              metrics = "users",
                              dimensions = c("country", "continent",
                                             "subcontinent"))

colnames(countries) <- c("Country", "Continent", "Subcontinent", "Users")

message("Writing user data...")
readr::write_tsv(users, here::here("data/tools-users.tsv"))

message("Writing country data...")
readr::write_tsv(countries, here::here("data/tools-countries.tsv"))

suppressPackageStartupMessages({
    library("dplyr")
    library("ggplot2")
})

message("Reading wordcount data...")
words <- readr::read_tsv(here::here("wordcount.txt"),
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
    mutate(Datetime = lubridate::ymd_hms(paste(Date, Time),
                                         tz = Sys.timezone())) %>%
    mutate(Name = forcats::fct_inorder(Name)) %>%
    filter(Name != "References")

message("Adding additional word counts...")
additions <- list(
    list(
        section = "Splatter publication",
        added = "2018-10-30",
        counts = c(Text = 8848L, Headers = 69L, Captions = 600L)
    ),
    list(
        section = "Simulating scRNA-seq data",
        added = "2018-10-30",
        counts = c(Text = 8848L, Headers = 69L, Captions = 600L)
    ),
    list(
        section = "docs/thesis.tex",
        added = "2018-10-30",
        counts = c(Text = 8848L, Headers = 69L, Captions = 600L)
    ),
    list(
        section = "scRNA-tools publication",
        added = lubridate::ymd_hm("2019-01-12 17:00", tz = Sys.timezone()),
        counts = c(Text = 4883L, Headers = 49L, Captions = 1305L)
    ),
    list(
        section = "The scRNA-seq tools landscape",
        added = lubridate::ymd_hm("2019-01-12 17:00", tz = Sys.timezone()),
        counts = c(Text = 4883L, Headers = 49L, Captions = 1305L)
    ),
    list(
        section = "docs/thesis.tex",
        added = lubridate::ymd_hm("2019-01-12 17:00", tz = Sys.timezone()),
        counts = c(Text = 4883L, Headers = 49L, Captions = 1305L)
    )
)

for (add in additions) {
    words <- words %>%
        mutate(Text = if_else(Name == add$section & Datetime >= add$added,
                              Text + add$counts["Text"], Text),
               Headers = if_else(Name == add$section & Datetime >= add$added,
                                 Headers + add$counts["Headers"], Headers),
               Captions = if_else(Name == add$section & Datetime >= add$added,
                                  Captions + add$counts["Captions"], Captions),
               Total = if_else(Name == add$section & Datetime >= add$added,
                               Total + sum(add$counts), Total))
}

message("Reading git log...")
git_log_opts <- c(Datetime = "cd", Subject = "s")
option_delim <- "\t"
log_format   <- glue::glue("%{git_log_opts}") %>%
    glue::glue_collapse(option_delim)
log_options  <- glue::glue('--pretty=format:"{log_format}" ',
                           '--date=format:"%Y-%m-%d %H:%M:%S"')
log_cmd      <- glue::glue('git log {log_options}')
git_log <- system(log_cmd, intern = TRUE) %>%
    stringr::str_split_fixed(option_delim, length(git_log_opts)) %>%
    as_tibble() %>%
    setNames(names(git_log_opts)) %>%
    mutate(Datetime = lubridate::ymd_hms(Datetime)) %>%
    filter(!stringr::str_detect(Subject, "Merge branch"))

message("Reading git tags...")
git_tag_opts <- c(Datetime = "(creatordate:format:%Y-%m-%d %H:%M:%S)",
                  Subject = "(subject)")
tag_format <- glue::glue("%{git_tag_opts}") %>%
    glue::glue_collapse(option_delim)
tag_options <- glue::glue('--format="{tag_format}"')
tag_cmd <- glue::glue('git tag {tag_options}')
git_tags <- system(tag_cmd, intern = TRUE) %>%
    stringr::str_split_fixed(option_delim, length(git_tag_opts)) %>%
    as_tibble() %>%
    setNames(names(git_tag_opts)) %>%
    mutate(Datetime = lubridate::ymd_hms(Datetime))

message("Calculating milestones...")
milestones <- tribble(
    ~From,              ~To,                ~Text,
    "2018-10-16 10:56",                 NA, "Initial commit",
    "2018-10-30 15:10",                 NA, "Add Splatter publication",
    "2018-11-23 15:00", "2018-11-25 19:30", "Thesis bootcamp",
    "2019-01-12 17:20",                 NA, "Add scRNA-tools publication"
) %>%
    mutate(From = lubridate::ymd_hm(From, tz = Sys.timezone()),
           To   = lubridate::ymd_hm(To, tz = Sys.timezone()))

milestones <- git_tags %>%
    rename(From = Datetime, Text = Subject) %>%
    mutate(To = NA) %>%
    bind_rows(milestones) %>%
    select(From, To, Text)

plots <- list()

message("Creating document plot...")

plot_data <- words %>%
    filter(Level %in% c("Document")) %>%
    select(Date, Datetime, Text, Headers, Captions, Total) %>%
    tidyr::complete(Date = seq.Date(min(Date), max(Date), by = "day")) %>%
    mutate(Datetime = if_else(is.na(Datetime),
                              lubridate::ymd(Date, tz = Sys.timezone()),
                              Datetime)) %>%
    tidyr::fill(Text, Headers, Captions, Total) %>%
    select(-Date) %>%
    tidyr::gather(key = Type, value = Count, -Datetime)

plots$document <- ggplot(plot_data) +
    geom_rect(data = filter(milestones, !is.na(To)),
              aes(xmin = From, xmax = To, ymin = -Inf, ymax = Inf),
              fill = "grey80") +
    geom_vline(data = filter(milestones, is.na(To)),
               aes(xintercept = From),
               colour = "grey80") +
    geom_rug(data = git_log,
             aes(x = Datetime),
             colour = "grey60") +
    geom_text(data = milestones,
              aes(x = From, label = Text),
              y = Inf, angle = 90, hjust = 1.1, vjust = -1,
              size = 3, colour = "grey60") +
    geom_line(aes(x = Datetime, y = Count, colour = Type)) +
    labs(y = "Word count", colour = "Type") +
    theme_minimal() +
    theme(legend.position = "bottom")

message("Creating chapter plot...")

plot_data <- words %>%
    filter(Level %in% c("Chapter")) %>%
    group_by(Name) %>%
    tidyr::complete(Date = seq.Date(min(Date), max(Date), by = "day")) %>%
    mutate(Datetime = if_else(is.na(Datetime),
                              lubridate::ymd(Date, tz = Sys.timezone()),
                              Datetime)) %>%
    tidyr::fill(Text)

plots$chapters <- ggplot(plot_data,
                         aes(x = Datetime, y = Text, fill = Name)) +
        geom_area() +
        labs(y = "Word count", colour = "Chapter") +
        theme_minimal() +
        theme(legend.position = "bottom")

message("Creating sankey plot...")

getCounts <- function(ids, levels, plot_data, type = "Document") {
    counts <- lapply(ids, function(id) {
        getCount(id, levels, plot_data, type)
    })
    counts <- bind_rows(counts)
    return(counts)
}

getCount <- function(id, levels, plot_data, type = "Document") {

    if (type == "Subsection") {
        sub_name <- plot_data$Name[id]
        sub_text <- plot_data$Text[id]
        return(data_frame(Subsection = sub_name, Text = sub_text))
    }

    next_id <- levels[[type]][which(levels[[type]] == id) + 1]
    id_name <- plot_data$Name[id]
    id_text <- plot_data$Text[id]
    switch (type,
            Document = {
                next_type <- "Chapter"
                id_counts <- data_frame(Document = id_name,
                                        Chapter = id_name,
                                        Section = id_name,
                                        Subsection = id_name,
                                        Text = id_text)
                if (length(levels$Document == 1)) {
                    next_id <- Inf
                }
            },
            Chapter = {
                next_type <- "Section"
                id_counts <- data_frame(Chapter = id_name,
                                        Section = id_name,
                                        Subsection = id_name,
                                        Text = id_text)
            },
            Section = {
                next_type <- "Subsection"
                id_counts <- data_frame(Section = id_name,
                                        Subsection = id_name,
                                        Text = id_text)
            }
    )

    if (!is.na(next_id)) {
        subs <- levels[[next_type]][levels[[next_type]] > id &
                                        levels[[next_type]] < next_id]
        if (length(subs) > 0) {
            counts <- getCounts(subs, levels, plot_data, type = next_type)

            id_counts$Text <- id_counts$Text - sum(counts$Text)

            counts[[type]] <- id_name
            counts <- bind_rows(id_counts, counts)
        } else {
            counts <- id_counts
        }
    } else {
        counts <- id_counts
    }

    return(counts)
}

getSankeyData <- function(words) {
    plot_data <- words %>% filter(Datetime == max(Datetime)) %>%
        select(Name, Level, Text) %>%
        mutate(Name = as.character(Name))

    levels <- list(Document    = which(plot_data$Level == "Document"),
                   Chapter     = which(plot_data$Level == "Chapter"),
                   Section     = which(plot_data$Level == "Section"),
                   Subsection  = which(plot_data$Level == "Subsection"))

    getCounts(1, levels, plot_data, "Document") %>%
        mutate(Document = "Thesis") %>%
        mutate(Section = paste(Chapter, Section, sep = "/"),
               Subsection = paste(Chapter, Section, Subsection, sep = "/")) %>%
        ggforce::gather_set_data(1:4) %>%
        mutate(x = factor(x, levels = names(levels)),
               Chapter = factor(Chapter, levels = unique(Chapter)))
}

plot_data <- getSankeyData(words)

plots$sankey <- ggplot(plot_data,
                       aes(x = x, id = id, split = y, value = Text)) +
    ggforce::geom_parallel_sets(aes(fill = Chapter),
                                alpha = 0.8, axis.width = 0.05) +
    ggforce::geom_parallel_sets_axes(axis.width = 0.05) +
    #ggforce::geom_parallel_sets_labels(colour = 'white') +
    theme_void() +
    theme(legend.position = "bottom",
          axis.text.x = element_text())

message("Saving wordcount.pdf...")
pdf(here::here("wordcount.pdf"), width = 10, height = 8)
for (plot in plots) {
    print(plot)
}
invisible(dev.off())

message("Done!")

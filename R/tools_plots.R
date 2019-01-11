plotToolsNumber <- function(date_counts, pal) {

    number_plot <- ggplot(date_counts, aes(x = Date, y = Total)) +
        geom_line(size = 2, colour = pal["purple"]) +
        xlab("Date added") +
        ylab("Database size") +
        scale_x_date(breaks = scales::pretty_breaks(n = 10),
                     date_labels = "%b %Y") +
        scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
        ggtitle("") +
        theme_cowplot() +
        theme(axis.text = element_text(size = 12),
              axis.title = element_text(size = 14),
              axis.title.x = element_blank(),
              axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)
        )

    return(number_plot)
}

plotPublication <- function(tools, pal) {
    pub_levels <- c("Published", "Preprint", "NotPublished")
    pub_labels <- c("Published", "Preprint", "Not Published")

    plot_data <- tools %>%
        mutate(Publications = if_else(is.na(Publications), 0L, Publications),
               Preprints = if_else(is.na(Preprints), 0L, Preprints)) %>%
        summarise(NotPublished = sum(Preprints == 0 & Publications == 0,
                                     na.rm = TRUE),
                  Published = sum(Publications > 0, na.rm = TRUE),
                  Preprint = sum(Preprints > 0 & Publications == 0,
                                 na.rm = TRUE)) %>%
        gather(key = Type, value = Count) %>%
        mutate(Type = factor(Type, levels = pub_levels,
                             labels = pub_labels)) %>%
        mutate(Label = paste0(Type, "\n",
                              chrRound(Count / sum(Count) * 100, 1), "%")) %>%
        mutate(TooLow = if_else((Count - 0.2 * max(Count)) < 0,
                                TRUE, FALSE)) %>%
        mutate(Colour = if_else(TooLow,
                                pal[as.numeric(Type)], "white")) %>%
        mutate(vjust = if_else(TooLow, -0.1, 1.1))

    pub_plot <- ggplot(plot_data,
                       aes(x = Type, y = Count, fill = Type)) +
        geom_col() +
        geom_text(aes(label = Label, colour = Colour, vjust = vjust),
                  size = 4) +
        scale_fill_manual(values = unname(pal)) +
        scale_colour_identity() +
        scale_y_continuous(expand = expand_scale(mult = c(0, 0))) +
        ylab("Number of tools") +
        ggtitle("") +
        theme_cowplot() +
        theme(legend.position = "none",
              axis.text = element_text(size = 12),
              axis.text.x = element_blank(),
              axis.title = element_text(size = 14),
              axis.title.x = element_blank(),
              axis.ticks.x = element_blank()
        )

    return(pub_plot)
}

plotLicenses <- function(tools, pal) {
    license_levels <- c("GPL", "MIT", "Apache", "BSD", "Artistic", "Other",
                        "Unknown")

    plot_data <- tools %>%
        select(License) %>%
        mutate(IsGPL = str_detect(License, "GPL"),
               IsBSD = str_detect(License, "BSD"),
               IsMIT = str_detect(License, "MIT"),
               IsApache = str_detect(License, "Apache"),
               IsArtistic = str_detect(License, "Artistic"),
               IsUnknown = is.na(License),
               IsOther = !(IsGPL | IsBSD | IsMIT | IsApache | IsArtistic |
                               IsUnknown)) %>%
        summarise(Apache = sum(IsApache, na.rm = TRUE),
                  Artistic = sum(IsArtistic, na.rm = TRUE),
                  BSD = sum(IsBSD, na.rm = TRUE),
                  GPL = sum(IsGPL, na.rm = TRUE),
                  MIT = sum(IsMIT, na.rm = TRUE),
                  Other = sum(IsOther),
                  Unknown = sum(IsUnknown)) %>%
        gather(key = License, value = Count) %>%
        mutate(License = factor(License, levels = license_levels),
               Label = paste0(License, " ",
                              chrRound(Count / sum(Count) * 100, 1), "%")) %>%
        mutate(TooLow = if_else((Count - 0.2 * max(Count)) < 0,
                                TRUE, FALSE)) %>%
        mutate(Colour = if_else(TooLow,
                                pal[as.numeric(License)], "white")) %>%
        mutate(hjust = if_else(TooLow, -0.05, 1.05))

    licenses_plot <- ggplot(plot_data,
                            aes(x = License, y = Count, fill = License)) +
        geom_col() +
        geom_text(aes(label = Label, colour = Colour, hjust = hjust),
                  size = 4, angle = 90) +
        scale_fill_manual(values = unname(pal)) +
        scale_colour_identity() +
        scale_y_continuous(expand = expand_scale(mult = c(0, 0))) +
        ylab("Number of tools") +
        ggtitle("") +
        theme_cowplot() +
        theme(legend.position = "none",
              axis.text = element_text(size = 12),
              axis.text.x = element_blank(),
              axis.title = element_text(size = 14),
              axis.title.x = element_blank(),
              axis.ticks.x = element_blank()
        )

    return(licenses_plot)
}

plotPlatforms <- function(tools, pal) {
    platforms_levels <- c("R", "Python", "CPP", "MATLAB", "Other")
    platforms_labels <- c("R", "Python", "C++", "MATLAB", "Other")

    plot_data <- tools %>%
        select(Platform) %>%
        mutate(IsR = str_detect(Platform, "R"),
               IsPython = str_detect(Platform, "Python"),
               IsMATLAB = str_detect(Platform, "MATLAB"),
               IsCPP = str_detect(Platform, "C++"),
               IsOther = !(IsR | IsPython | IsMATLAB | IsCPP)) %>%
        summarise(R = sum(IsR),
                  Python = sum(IsPython),
                  MATLAB = sum(IsMATLAB),
                  CPP = sum(IsCPP),
                  Other = sum(IsOther)) %>%
        gather(key = Platform, value = Count) %>%
        mutate(Platform = factor(Platform,
                                 levels = platforms_levels,
                                 labels = platforms_labels)) %>%
        mutate(Label = paste0(Platform, "\n",
                              chrRound(Count / nrow(tools) * 100, 1), "%")) %>%
        mutate(TooLow = if_else((Count - 0.2 * max(Count)) < 0,
                                TRUE, FALSE)) %>%
        mutate(Colour = if_else(TooLow,
                                pal[as.numeric(Platform)], "white")) %>%
        mutate(vjust = if_else(TooLow, -0.1, 1.1))

    platforms_plot <- ggplot(plot_data,
                             aes(x = Platform, y = Count, fill = Platform)) +
        geom_col() +
        geom_text(aes(label = Label, colour = Colour, vjust = vjust),
                  size = 4) +
        scale_fill_manual(values = unname(pal)) +
        scale_colour_identity() +
        scale_y_continuous(expand = expand_scale(mult = c(0, 0))) +
        ylab("Number of tools") +
        ggtitle("") +
        theme_cowplot() +
        theme(legend.position = "none",
              axis.text = element_text(size = 12),
              axis.text.x = element_blank(),
              axis.title = element_text(size = 14),
              axis.title.x = element_blank(),
              axis.ticks.x = element_blank()
        )

    return(platforms_plot)
}

plotCategories <- function(cat_counts, pal) {

    plot_data <- cat_counts %>%
        mutate(Category = forcats::fct_recode(Category,
                                              `Dim. Reduction` =
                                                  "Dimensionality Reduction")) %>%
        mutate(Label = paste0(Category, " ", chrRound(Prop * 100, 1), "%")) %>%
        mutate(TooLow = if_else((Count < 0.8 * max(Count)), TRUE, FALSE)) %>%
        mutate(Colour = if_else(TooLow,
                                pal[as.numeric(Phase)], "white")) %>%
        mutate(hjust = if_else(TooLow, -0.05, 1.05))

    cats_plot <- ggplot(plot_data, aes(x = Category, y = Count, fill = Phase)) +
        geom_col() +
        geom_text(aes(y = Count, label = Label, colour = Colour,
                      hjust = hjust), size = 3.5, angle = 90) +
        scale_fill_manual(values = pal, name = "Analysis phase") +
        scale_colour_identity() +
        scale_y_continuous(expand = expand_scale(mult = c(0, 0))) +
        ylab("Number of tools") +
        ggtitle("") +
        guides(fill = guide_legend(keywidth = 1, keyheight = 1,
                                   ncol = 2)) +
        theme_cowplot() +
        theme(legend.position = c(0.65, 0.80),
              legend.title = element_text(size = 14),
              legend.text = element_text(size = 12),
              axis.text = element_text(size = 12),
              axis.text.x = element_blank(),
              axis.title = element_text(size = 14),
              axis.title.x = element_blank(),
              axis.ticks.x = element_blank()
        )

    return(cats_plot)
}

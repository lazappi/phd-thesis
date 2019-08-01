plotUsers <- function(tools_users) {
    plot_data <- tools_users %>%
        gather(key = Type, value = Users, -Date) %>%
        mutate(Type = factor(Type,
                             levels = c("Users1Day", "Users7Day", "Users30Day"),
                             labels = c("1 Day", "7 Days", "30 Days")))

    users_plot <- ggplot(plot_data, aes(x = Date, y = Users, colour = Type)) +
        geom_vline(xintercept = as.Date("2017-11-01"), colour = pal["grey"]) +
        annotate("text", label = "Genome Informatics\npresentation",
                 x = as.Date("2017-11-01"), y = Inf,
                 angle = 90, hjust = 1, vjust = -0.4,
                 size = 4, colour = pal["grey"]) +
        geom_vline(xintercept = as.Date("2018-03-23"), colour = pal["grey"]) +
        annotate("text", label = "bioRxiv preprint",
                 x = as.Date("2018-03-23"), y = Inf,
                 angle = 90, hjust = 1, vjust = -1,
                 size = 4, colour = pal["grey"]) +
        geom_vline(xintercept = as.Date("2018-06-25"), colour = pal["grey"]) +
        annotate("text", label = "Publication",
                 x = as.Date("2018-06-25"), y = Inf,
                 angle = 90, hjust = 1, vjust = -1,
                 size = 4, colour = pal["grey"]) +
        geom_line(size = 2) +
        scale_color_manual(values = unname(pal)) +
        scale_x_date(breaks = scales::pretty_breaks(n = 10),
                     date_labels = "%b %Y") +
        ggtitle("") +
        theme_minimal() +
        theme(axis.title.x = element_blank(),
              legend.title = element_blank())

    return(users_plot)
}

plotUsersMap <- function(tools_countries) {
    world <- map_data("world")

    plot_data <- left_join(world, tools_countries, by = c(region = "Country"))

    map <- ggplot(plot_data,
                  aes(x = long, y = lat, group = group, fill = Users)) +
        geom_polygon() +
        scale_fill_viridis_c(na.value = "grey80") +
        ggtitle("") +
        theme_minimal() +
        theme(axis.title = element_blank(),
              axis.text = element_blank(),
              panel.grid = element_blank(),
              legend.position = "bottom",
              legend.key.width = unit(1, "cm"))

    return(map)
}

plotUsersCountries <- function(tools_countries) {
    plot_data <- tools_countries %>%
        group_by(Country) %>%
        tally(Users, sort = TRUE) %>%
        mutate(Country = factor(c(Country[1:10], rep("Other", n() - 10)),
                                levels = c(Country[1:10], "Other"))) %>%
        group_by(Country) %>%
        tally(n) %>%
        rename(Users = nn) %>%
        mutate(Country = forcats::fct_rev(Country)) %>%
        mutate(Label = paste0(Country, " ",
                              chrRound(Users / sum(Users) * 100, 1), "%")) %>%
        mutate(TooLow = if_else((Users - 0.4 * max(Users)) < 0,
                                TRUE, FALSE)) %>%
        mutate(Colour = if_else(TooLow, "grey40", "white")) %>%
        mutate(hjust = if_else(TooLow, -0.1, 1.1))

    countries <- ggplot(plot_data,
                        aes(x = Country, y = Users, fill = Country)) +
        geom_col() +
        geom_text(aes(label = Label, colour = Colour, hjust = hjust),
                  size = 3.5) +
        scale_fill_manual(values = unname(c(pal["grey"],
                                            rep(pal["purple"], 10)))) +
        scale_colour_identity() +
        coord_flip() +
        ggtitle("") +
        theme_minimal() +
        theme(axis.title.y = element_blank(),
              axis.text.y = element_blank(),
              panel.grid = element_blank(),
              legend.position = "none")

    return(countries)
}

plotUsersContinents <- function(tools_countries) {
    plot_data <- tools_countries %>%
        group_by(Continent) %>%
        summarise(Users = sum(Users)) %>%
        arrange(-Users) %>%
        mutate(Continent = factor(Continent, levels = Continent)) %>%
        mutate(Continent = forcats::fct_relevel(Continent,
                                                "(not set)", after = Inf),
               Continent = forcats::fct_recode(Continent,
                                               Unknown = "(not set)"),
               Continent = forcats::fct_rev(Continent)) %>%
        mutate(Label = paste0(Continent, " ",
                              chrRound(Users / sum(Users) * 100, 1), "%")) %>%
        mutate(TooLow = if_else((Users - 0.3 * max(Users)) < 0,
                                TRUE, FALSE)) %>%
        mutate(Colour = if_else(TooLow, "grey40", "white")) %>%
        mutate(hjust = if_else(TooLow, -0.1, 1.1))

    continents <- ggplot(plot_data,
                         aes(x = Continent, y = Users, fill = Continent)) +
        geom_col() +
        geom_text(aes(label = Label, colour = Colour, hjust = hjust),
                  size = 4) +
        scale_fill_manual(values = unname(c(pal["grey"],
                                            rep(pal["purple"], 5)))) +
        scale_colour_identity() +
        coord_flip() +
        ggtitle("") +
        theme_minimal() +
        theme(axis.title.y = element_blank(),
              axis.text.y = element_blank(),
              panel.grid = element_blank(),
              legend.position = "none")

    return(continents)
}

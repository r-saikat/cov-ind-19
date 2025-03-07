plot_fig_2 <- function(start.date = as.Date("2020-05-01"))
{
    Day.max <- 100
    cases.threshold <- 100
    deaths.threshold <- 3

    fmt <- function(x) format(x, big.mark = ",", scientific = F, trim = T)
    data <- vroom(paste0(data_repo, "/", today, "/jhu_data_mod.csv"), col_types = cols())
    
    min.date = data %>% group_by(Country) %>% filter(Cases >= cases.threshold) %>%
        arrange(Date) %>% ungroup() %>% mutate(min_date = min(Date)) %>% 
        pull(min_date) %>% unique()

    cases.data <- data %>%
    group_by(Country) %>% filter(Cases >= cases.threshold) %>%
    arrange(Date) %>%
    mutate(Day = seq(n()) - 1) %>%
    ungroup() %>%
    filter(Day > 30) %>%
    #filter(Day <= Day.max) %>%
    group_by(Country) %>%
    mutate(Date = format(Date, format = "%b %e"),
           Incident_Cases = Cases - dplyr::lag(Cases)) %>%
    mutate(Cases_fmt = fmt(Incident_Cases)) %>%
    mutate(text = paste0(Country, "<br>", Date, ": ", Cases_fmt,
                         " incident cases<br>")
    ) %>% 
    ungroup()
    
    cases.data <- cases.data %>%
    group_by(Country) %>%
    mutate(loess_cases = c(0, predict(loess(formula = Incident_Cases ~ Day, span = 0.15))))

    deaths.data <- data %>%
    group_by(Country) %>% filter(Deaths >= deaths.threshold) %>%
    arrange(Date) %>%
    mutate(Day = seq(n()) - 1) %>%
    ungroup() %>%
    filter(Day > 30) %>%
    #filter(Day <= Day.max) %>%
    group_by(Country) %>%
    mutate(Date = format(Date, format = "%b %e"),
           Incident_Deaths = Deaths - dplyr::lag(Deaths)) %>%
    mutate(Deaths_fmt = fmt(Incident_Deaths)) %>%
    mutate(text = paste0(Country, "<br>", Date, ": ", Deaths_fmt,
                         " incident deaths<br>")
    ) %>% 
    ungroup()
    
    deaths.data <- deaths.data %>%
    group_by(Country) %>%
    mutate(loess_deaths = c(0, predict(loess(formula = Incident_Deaths ~ Day, span = 0.15))))
    

    cases.title <- paste("COVID-19 cases in India compared",
                         "to other countries")

    deaths.title <- paste("COVID-19 deaths in India compared",
                          "to other countries")

    cap <- paste0("\uA9 COV-IND-19 Study Group. Last updated: ",
                  format(today, format = "%b %e"), sep = ' ')

    axis.title.font <- list(size = 16)
    tickfont        <- list(size = 16)
    
    x.date.span = as.numeric(as.Date(today) - as.Date(min.date))

    cases.xaxis <- list(title = "Days since cumulative cases passed 100",
                        titlefont = axis.title.font, showticklabels = TRUE,
                        tickangle = 0, showline = T, zeroline = F,
                        range = list(30, x.date.span + 14)
    )

    deaths.xaxis <- list(title = "Days since cumulative deaths passed 3",
                         titlefont = axis.title.font, showticklabels = TRUE,
                         tickangle = 0, showline = T, zeroline = F,
                         range = list(30, x.date.span + 14)
    )


    cases.yaxis <- list(title = "Incident number of reported cases", titlefont =
                  axis.title.font, tickfont = tickfont, zeroline = F,
                  showline = F)

    deaths.yaxis <- list(title = "Incident number of reported deaths",
                        titlefont = axis.title.font, tickfont = tickfont,
                        zeroline = F, showline = F)

    else_color  <- "#999999"
    india_color <- "#138808"
    # viridis::plasma(length(unique(data$Country)) - 1)
    # rep(else_color, length(unique(data$Country)) - 1)
    colors <- c(viridis::plasma(length(unique(data$Country)) - 1, begin = 0, end = 0.8),
                india_color)

    names(colors) <- c(setdiff(unique(data$Country), "India"), "India")

    case_plot <- plot_ly(cases.data, x = ~ Day, y = ~loess_cases, text = ~text,
                         color = ~Country, colors = colors,
                         legendgroup = ~Country, hoverinfo = "text",
                         mode = "markers+lines", hoverlabel = list(align = "left"),
                         showlegend = F, line = list(width = 3)
    ) %>%
    add_trace(
        data = cases.data %>% filter(Country != "India"), type = "scatter",
        mode = "lines", visible = "legendonly", line = list(width = 2)
    ) %>%
    add_trace(data = cases.data %>% filter(Country == "India"),
              type = "scatter", mode = "lines", line = list(width = 3)
    )  %>%
    layout(xaxis = cases.xaxis, yaxis = cases.yaxis,
           annotations = list(text = cases.title, xref = "paper", yref = "paper",
                              xanchor = "left", x = 0, y = 1.1, showarrow = F,
                              font = list(size = 22))
    )

    death_plot <- plot_ly(deaths.data, x = ~ Day, y = ~loess_deaths, text = ~text,
                          color = ~Country, colors = colors,legendgroup = ~Country,
                          hoverinfo = "text", mode = "markers+lines",
                          hoverlabel = list(align = "left"), showlegend = T
    ) %>%
    add_trace(
        data = deaths.data %>% filter(Country != "India"), type = "scatter",
        mode = "lines", visible = "legendonly", line = list(width = 2)
    ) %>%
    add_trace(data = deaths.data %>% filter(Country == "India"),
              type = "scatter", mode = "lines", line = list(width = 3)
    ) %>%
    layout(xaxis = deaths.xaxis, yaxis = deaths.yaxis,
           annotations = list(text = deaths.title, xref = "paper", yref = "paper",
                              xanchor = "left", x = 0, y = 1.1, showarrow = F,
                              font = list(size = 22))
    )

    subplot(case_plot, death_plot, titleX = T, titleY = T, margin = .08,
            nrows = 2, shareX = F) %>%
            plotly::config(toImageButtonOptions = list(width = NULL, height = NULL))
}


suppressPackageStartupMessages({
library(vroom)
library(tidyverse)
library(ggtext)
library(scales)
library(tidyr)
})

plot_fig_vax = function() {
  # vax_dat <- suppressMessages(vroom("http://api.covid19india.org/csv/latest/vaccine_doses_statewise.csv")) %>%
  #   pivot_longer(
  #     names_to = "date",
  #     values_to = "vaccines",
  #     -State
  #   ) %>%
  #   mutate(
  #     date = as.Date(date, format = "%d/%m/%Y")
  #   ) %>%
  #   dplyr::rename(
  #     state = State
  #   ) %>%
  #   group_by(state) %>%
  #   arrange(date) %>%
  #   mutate(
  #     daily_vaccines = vaccines - dplyr::lag(vaccines)
  #   ) %>%
  #   ungroup()
  
  vax_dat <- read_csv("http://api.covid19india.org/csv/latest/vaccine_doses_statewise.csv") %>%
    pivot_longer(names_to = "date", values_to = "count", -State) %>%
    mutate(date = as.Date(date, "%e/%m/%Y")) %>%
    arrange(date) %>%
    filter(State == "Total") %>%
    mutate(count = replace(count, count == 0, NA),
           lag = count - dplyr::lag(count)
    ) %>% fill()
  
  # vax_dat %>%
  #   ggplot(aes(x = date, y = vaccines)) +
  #   geom_line() +
  #   labs(
  #     title = "Cumulative COVID-19 vaccines delivered in India",
  #     x     = "Date",
  #     y     = "Number of vaccines",
  #     caption = "**Source:** covid19india.org<br>**\uA9 COVIND-19 Study Group**"
  #   ) +
  #   scale_y_continuous(labels = comma) +
  #   theme_minimal()+
  #   theme(
  #     plot.title   = element_text(face = "bold", hjust = 0.5),
  #     plot.caption = element_markdown(hjust = 0)
  #   )
  # lag = ifelse(lag < 0, 0, lag),
  vax_india = vax_dat %>% 
    rename(Day = date) %>% 
    mutate(text = paste0("India", "<br>", Day, ": ", format(lag, big.mark = ","),
                         " daily vaccines<br>")) %>% 
    filter(Day >= as.Date("2021-02-15"))
  
  india_color <- "#138808"
  names(india_color) <- "India"
  
  vax.title <- "Daily COVID-19 vaccines delivered in India"
  
  axis.title.font <- list(size = 16)
  
  vax.xaxis <- list(title = "Date",
                    titlefont = axis.title.font, showticklabels = TRUE,
                    tickangle = 0, showline = T, zeroline = F)
  
  vax.yaxis <- list(title = "Number of vaccines", titlefont =
                      axis.title.font, zeroline = F, showline = F)
  
  case_plot <- plot_ly(vax_india, x = ~ Day, y = ~ lag, text = ~ text, color = I("#138808"),
                       hoverinfo = "text", type = "bar", hoverlabel = list(align = "left"),
                       showlegend = F, line = list(width = 3)
  ) %>%
    layout(xaxis = vax.xaxis, yaxis = vax.yaxis,
           annotations = list(text = vax.title, xref = "paper", yref = "paper",
                              xanchor = "left", x = 0, y = 1.1, showarrow = F,
                              font = list(size = 22))
    )
  
  case_plot
}

suppressPackageStartupMessages({
library(tidyverse)
library(vroom)
})

data_repo <- Sys.getenv("data_repo")
today <- Sys.getenv("today")

x_20 <- vroom(paste0(data_repo, "/", today, "/covid19india_data.csv"), col_types = cols()) %>%
group_by(State) %>%
filter(Date == max(Date) & State != "un" & State != "la" & State != "dd") %>%
ungroup() %>%
top_n(20, Cases)

x_all <- vroom(paste0(data_repo, "/", today, "/covid19india_data.csv"), col_types = cols()) %>%
group_by(State) %>%
filter(Date == max(Date) & State != "un" & State != "la" & State != "dd") %>%
ungroup()

x_rest = setdiff(x_all, x_20)

cat(x_20$State, "\n")

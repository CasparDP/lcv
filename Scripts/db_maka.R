# Process the downloaded HTML files and extract the data

library(tidyverse)
library(rvest)
library(duckdb)


# Load the downloaded HTML files
files <- list.files("data-raw", pattern = "lcv_.*\\.html", full.names = TRUE)

## Processing function
# sites  <- files[107]

data_processor <- function(sites) {
    message(
        "Processing file: ", str_extract(sites, "\\d{4}") %>% as.numeric(),
        " - ",
        str_extract(sites, "senate|house")
    )

    # Read the HTML file from disc
    x <- rvest::read_html(sites) %>%
        html_nodes(".congress-item")
    # Extract the data from each file
    data <- tibble(
        year = str_extract(sites, "\\d{4}") %>% as.numeric(),
        type = str_extract(sites, "senate|house"),
        name = x %>%
            html_nodes(".congress-card") %>%
            html_nodes(".card-link") %>%
            html_text(),
        link = x %>%
            html_nodes(".congress-card") %>%
            html_nodes(".card-link") %>%
            html_attr("href"),
        party = x %>%
            html_nodes(".congress-card") %>%
            html_nodes(".congress-party") %>%
            html_text() %>%
            str_squish(),
        scores_list = x %>%
            html_nodes(".congress-card") %>%
            html_nodes(".congress-data") %>%
            html_text() %>% str_extract_all("\\d+%"),
        vote_year = x %>%
            html_nodes(".congress-card") %>%
            html_nodes(".congress-data") %>%
            html_text() %>% str_extract("\\d{4}") %>%
            as.numeric(),
        year_score = map_dbl(
            scores_list,
            ~ .x %>%
                str_extract("\\d+") %>%
                .[1] %>%
                as.numeric(),
            .default = NA_real_
        ),
        life_time_score = map_dbl(
            scores_list,
            ~ .x %>%
                str_extract("\\d+") %>%
                .[2] %>%
                as.numeric(),
            .default = NA_real_
        )
    )

    # return(data)

    # Add state information

    s <- rvest::read_html(sites)

    state <-
        s %>%
        html_nodes(".state-title") %>%
        html_text() %>%
        str_squish()

    number_of_candidates <- s %>%
        html_nodes(".state-listing") %>%
        html_text() %>%
        str_extract_all("Lifetime Score") %>%
        map_dbl(., ~ length(.x))

    # Make state vector the same length as number_of_candidates
    state <- rep(state, number_of_candidates)

    # Add state to the data
    data <- data %>% bind_cols(state = state)
}

# Build the dataset and write it to duckdb

data <- map_dfr(files, data_processor) %>%
    mutate(across(c(year, vote_year, year_score, life_time_score), ~ as.integer(.x)))


# TODO: What to do if vote_year is empty?  Replace year_score with NA and life_time_score with year_score?

# Write to Disk

# Create a directory to store the downloaded files

if (!dir.exists("data-processed")) {
    dir.create("data-processed")
    message("Directory 'data-processed' created.")
}

# Write to CSV - safety check
write_rds(data, "data-processed/lcv_data.rds")

# Write to DB
con <- dbConnect(duckdb::duckdb(), "data-processed/lcv_data.duckdb")
dbWriteTable(con, "lcv_data", data %>% select(-scores_list), overwrite = TRUE)
dbDisconnect(con)

# Clean up

rm(list = ls())

# Download each site from https://www.lcv.org/congressional-scorecard/members-of-congress/

library(tidyverse)
library(rvest)



## List of sites to scrape
years <- seq(1971, as.numeric(substr(Sys.time(), 1, 4)) - 1, by = 1)
sites <- paste0(
    "https://www.lcv.org/congressional-scorecard/members-of-congress/?sort=state-a-z&active_tab=&chamber=senate&street_address=&zip=&session_year=",
    years,
    "&state=&party=All&last_name=&export-type=moc-listing"
) %>%
    append(
        paste0(
            "https://www.lcv.org/congressional-scorecard/members-of-congress/?sort=state-a-z&active_tab=&chamber=house&street_address=&zip=&session_year=",
            years,
            "&state=&party=All&last_name=&export-type=moc-listing"
        )
    )

type <- str_extract(sites, "senate|house")

# Double length of years to match the number of sites
years <- rep(years, 2)

# Create a directory to store the downloaded files

if (!dir.exists("data-raw")) {
    dir.create("data-raw")
    message("Directory 'data-raw' created.")
}

done  <- length(sites) - length(list.files("data-raw")) # Check the number of sites to be downloaded

sites <- sites[done:length(sites)] # Filter out already downloaded sites

# Download each site for each year and type

loada  <- function(sites, type, years) {

message("Starting to download sites...")

download.file(sites,
            destfile = paste0("data-raw/lcv_", type, "_", years, ".html"),
            quiet = TRUE
        )

    
}

map(1:length(sites), ~ loada(sites[.x], type[.x], years[.x]))

    # Check if the file already exists
    if (list.files("data-raw", pattern = paste0("lcv_", type[i], "_", years[i], ".html")) != "") {


message("All sites downloaded successfully.")

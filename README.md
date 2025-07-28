# League of Conservation Voters Congressional Scorecard Dataset

[![R](https://img.shields.io/badge/R-276DC3?style=flat&logo=r&logoColor=white)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

This repository contains a comprehensive dataset of the League of Conservation Voters (LCV) Congressional Scorecard data spanning from 1971 to 2024. The LCV Scorecard tracks how members of Congress vote on environmental legislation and assigns annual environmental scores to each representative and senator.

## About the LCV Scorecard

The League of Conservation Voters National Environmental Scorecard is the gold standard for tracking the environmental voting records of members of Congress. Each year, LCV analyzes the most important environmental votes and assigns scores based on the percentage of pro-environment votes cast by each member.

- **Scoring Range**: 0-100% (100% = perfect environmental voting record)
- **Coverage**: All voting members of the U.S. House and Senate
- **Frequency**: Annual scores plus lifetime cumulative scores

## Dataset Features

- **Temporal Coverage**: 1971-2024 (54 years of data)
- **Legislative Bodies**: U.S. House of Representatives and U.S. Senate
- **Variables**: Member name, party affiliation, state, annual score, lifetime score
- **Format**: Available in R (.rds) and DuckDB formats
- **Total Records**: 50,000+ individual member-year observations

## Repository Structure

```
lcv/
├── Scripts/
│   ├── get_sites.R          # Downloads HTML files from LCV website
│   └── db_maka.R            # Processes HTML files into structured data
├── data-raw/                # Raw HTML files (100+ files)
│   ├── lcv_house_YYYY.html
│   └── lcv_senate_YYYY.html
├── data-processed/          # Clean, processed datasets
│   ├── lcv_data.rds         # R data format
│   └── lcv_data.duckdb      # DuckDB database
└── README.md
```

## Installation & Dependencies

### Option 1: Using renv (Recommended)

```r
# Clone the repository and navigate to the project folder
# Then restore the exact package environment:
renv::restore()
```

### Option 2: Using DESCRIPTION file

```r
# Install from DESCRIPTION file (simpler than renv)
devtools::install_deps()
# or
remotes::install_deps()
```

### Option 3: Manual Installation

```r
install.packages(c(
  "tidyverse",  # Data manipulation and visualization
  "rvest",      # Web scraping
  "duckdb"      # Database operations
))
```

### For Developers

If you're contributing to this project:

```r
# After making changes, update the lockfile:
renv::snapshot()

# To add new packages:
install.packages("new_package")
renv::snapshot()  # Record the addition
```

## Usage

### Download Fresh Data

```r
source("Scripts/get_sites.R")
```

This script will:

- Download HTML files from the LCV website for all years (1971-current)
- Store files in the `data-raw/` directory
- Skip already downloaded files

### Process Raw Data

```r
source("Scripts/db_maka.R")
```

This script will:

- Parse all HTML files in `data-raw/`
- Extract structured data (names, scores, party, state)
- Save processed data to `data-processed/`

### Load Processed Data

```r
# Load as R dataframe
data <- readRDS("data-processed/lcv_data.rds")

# Or connect to DuckDB
library(duckdb)
con <- dbConnect(duckdb(), "data-processed/lcv_data.duckdb")
data <- dbReadTable(con, "lcv_data")
dbDisconnect(con)
```

## Data Structure

| Variable          | Type      | Description                        |
| ----------------- | --------- | ---------------------------------- |
| `year`            | integer   | Year of the scorecard              |
| `type`            | character | "house" or "senate"                |
| `name`            | character | Member's full name                 |
| `link`            | character | URL to member's LCV profile        |
| `party`           | character | Political party affiliation        |
| `vote_year`       | integer   | Year of voting record              |
| `year_score`      | integer   | Annual environmental score (0-100) |
| `life_time_score` | integer   | Cumulative lifetime score (0-100)  |
| `state`           | character | State represented                  |

## Example Analyses

```r
library(tidyverse)

# Load data
data <- readRDS("data-processed/lcv_data.rds")

# Average scores by party over time
party_trends <- data %>%
  group_by(year, party) %>%
  summarise(avg_score = mean(year_score, na.rm = TRUE))

# State environmental rankings
state_rankings <- data %>%
  filter(year == 2024) %>%
  group_by(state) %>%
  summarise(avg_score = mean(year_score, na.rm = TRUE)) %>%
  arrange(desc(avg_score))
```

## Data Quality Notes

- Some early years may have incomplete data due to LCV's evolving methodology
- Missing scores (`NA`) occur when members didn't vote on key environmental legislation
- Party affiliations are as recorded by LCV at the time of voting

## Citation

If you use this dataset in your research, please cite:

```
League of Conservation Voters Congressional Scorecard Dataset (1971-2024)
Available at: https://github.com/CasparDP/lcv.git
Original data source: League of Conservation Voters (https://www.lcv.org/scorecard/)
```

## Related Resources

- [LCV Scorecard Methodology](https://www.lcv.org/scorecard/methodology/)
- [League of Conservation Voters Website](https://www.lcv.org/)

## Contributing

Contributions are welcome! Please feel free to:

- Report bugs or data inconsistencies
- Suggest improvements to data processing scripts
- Add analysis examples
- Improve documentation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Note**: While this repository's code is under MIT license, the underlying LCV scorecard data is publicly available but owned by the League of Conservation Voters. Please respect their terms of use when using this data.

## Disclaimer

This is an independent research project and is not officially affiliated with the League of Conservation Voters. The data is collected from publicly available sources for academic and research purposes.

---

**Last Updated**: June 2025  
**Data Coverage**: 1971-2024

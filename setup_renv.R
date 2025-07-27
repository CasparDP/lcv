# Setup script for renv
# Run this once to initialize renv in your project

# Install renv if not already installed
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}

# Initialize renv in the project
renv::init()

# Install project dependencies
install.packages(c(
  "tidyverse",
  "rvest", 
  "duckdb"
))

# Take a snapshot of current packages
renv::snapshot()

# Clean up
file.remove("setup_renv.R")  # Remove this setup script

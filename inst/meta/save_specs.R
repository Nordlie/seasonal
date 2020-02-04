library(tidyverse)

# SPECS meta data --------------------------------------------------------------

# load SPECS data from .csv and store as data/SPECS.RData
SPECS <- read_csv("inst/meta/SPECS.csv", col_types = cols(), na = c("NA"))
save(SPECS, "data/SPECS.RData")


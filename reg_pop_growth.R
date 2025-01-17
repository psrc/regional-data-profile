# Cleaning and calculating population growth
# Geographies: Region & county
# Data Vintage: 2024 OFM April 1 estimates
# Created By: Eric Clute

# Assumptions ---------------------
library(dplyr)
library(openxlsx)
library(tidyverse)
library(psrchousing)

export_path <- "C:/Users/eclute/GitHub/regional-data-profile"
source_info <- c("OFM April 1 Population and Housing Estimates. Data representing 2010-2024. Calculated by Eric Clute.")

newest_vintage <- 2024
years <- seq(2010, newest_vintage)

# Import ---------------------
pop_raw <- ofm_county_population_data()

# Crunch pop data ---------------------
pop <- pop_raw %>% filter(year %in% years) %>% select(year, geography, population) %>%
                   mutate(population = round(population, -2)) %>% # Round to the nearest 1,000
                   pivot_wider(names_from = geography, values_from = population)

# Crunch pop per sq/mile --------------------
pop_per_mile <- pop_raw %>% filter(year %in% newest_vintage) %>%
                            select(year, geography, population) %>%
                            mutate(population = round(population, -2), # Round to the nearest 1,000
                                   sq_mile = case_when(
                                     geography == "King" ~ 2115.6,
                                     geography == "Kitsap" ~ 394.9,
                                     geography == "Pierce" ~ 1669.5,
                                     geography == "Snohomish" ~ 2087.3,
                                     geography == "Region" ~ 6267.3,
                                     TRUE ~ NA_real_ ), # Assign NA for any unmatched geography
                                   pop_per_sq_mile = population / sq_mile) 
                           

# Cleanup and export ---------------------
export_file <- paste0(export_path, "/reg_pop_growth_raw.xlsx")
work_book <- createWorkbook()

addWorksheet(work_book, sheetName = "pop growth")
writeData(work_book, sheet = "pop growth", pop)
writeData(work_book, sheet = "pop growth", x = data.frame(source_info), startRow = nrow(pop) + 3, startCol = 1)

addWorksheet(work_book, sheetName = "pop per sq mile")
writeData(work_book, sheet = "pop per sq mile", pop_per_mile)
writeData(work_book, sheet = "pop per sq mile", x = data.frame(source_info), startRow = nrow(pop_per_mile) + 3, startCol = 1)

saveWorkbook(work_book, file = export_file, overwrite = TRUE)
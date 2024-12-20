# Crunching housing data for Regional Data Profile
# Geographies: Region & Counties
# Data Vintage: 2000 - 2024 OFM April 1 estimates
# Created By: Eric Clute

# Assumptions ---------------------
library(dplyr)
library(openxlsx)
library(tidyverse)
library(psrchousing)

export_path <- "H:/Projects/2024/Regional Data Profile Update"
source_info <- c("OFM April 1 Housing Estimates. Data representing 2000 thru 2024. Calculated by Eric Clute.")

newest_vintage <- 2024
years <- seq(2010, newest_vintage)
decades <- c(2010, 2020)
decades_and_newest_vintage <- unique(c(decades, newest_vintage))

# Import & Clean ---------------------
hu_raw <- ofm_county_housing_unit_data()
hu <- hu_raw %>%
  filter(year %in% years) %>%
  select(year, geography, sf, mf, mh, total)

# CHART #1 - Total Housing Units by County ---------------------
chart_1 <- hu %>% 
  select(year, geography, total) %>%
  pivot_wider(names_from = geography, values_from = total) %>%
  select(-c(Region))

# CHART #2 - Housing Units by Structure Type ---------------------
chart_2 <- hu %>%
  filter(year %in% decades_and_newest_vintage) %>%
  filter(geography == "Region")
  
# CHART #3 - Total Housing Units by County ---------------------
chart_3 <- hu %>% 
  select(year, geography, total) %>%
  pivot_wider(names_from = geography, values_from = total) %>%
  filter(year == newest_vintage)  
 
# CHART #4 - Total Housing Units Entire Region ---------------------
chart_4 <- hu %>% 
  select(year, geography, total) %>%
  pivot_wider(names_from = geography, values_from = total) %>%
  select(year, Region) 

# Cleanup and export ---------------------
export_file <- paste0(export_path, "/reg_housing_raw.xlsx")
work_book <- createWorkbook()

addWorksheet(work_book, sheetName = "chart_1")
writeData(work_book, sheet = "chart_1", chart_1)
writeData(work_book, sheet = "chart_1", x = data.frame(source_info), startRow = nrow(chart_1) + 3, startCol = 1)

addWorksheet(work_book, sheetName = "chart_2")
writeData(work_book, sheet = "chart_2", chart_2)
writeData(work_book, sheet = "chart_2", x = data.frame(source_info), startRow = nrow(chart_2) + 3, startCol = 1)

addWorksheet(work_book, sheetName = "chart_3")
writeData(work_book, sheet = "chart_3", chart_3)
writeData(work_book, sheet = "chart_3", x = data.frame(source_info), startRow = nrow(chart_3) + 3, startCol = 1)

addWorksheet(work_book, sheetName = "chart_4")
writeData(work_book, sheet = "chart_4", chart_4)
writeData(work_book, sheet = "chart_4", x = data.frame(source_info), startRow = nrow(chart_4) + 3, startCol = 1)

saveWorkbook(work_book, file = export_file, overwrite = TRUE)
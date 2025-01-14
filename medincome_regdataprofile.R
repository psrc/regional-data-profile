library(tidyverse)
library(psrcelmer)
library(psrccensus)
library(openxlsx)
library(here)

export_path <- "J:/Projects/regional_data_profile"
source_info <- c("U.S. Census Bureau, 2010-2023 American Community Survey 5-Year Estimates, Table B25014;. Calculated by Mary Richards.")

year_range <- c("2010", "2011", "2012", "2013", "2014", "2015", 
                "2016", "2017", "2018", "2019", #"2020",
                "2021", "2022", "2023")

# The regular 1-year ACS for 2020 was not released and is not available in tidycensus. Due to low response rates, the Census Bureau instead released a set of experimental estimates for the 2020 1-year ACS. These estimates can be downloaded at https://www.census.gov/programs-surveys/acs/data/experimental-data/1-year.html.
# Data only available at state level. 

county_acs_data <- get_acs_recs(geography ='county', 
                                table.names = 'B19013', #subject table code
                                years = c(as.numeric(year_range)),
                                acs.type = 'acs1')
  
# checking data
nrow(county_acs_data) #52 - 13 years, 4 counties
table(county_acs_data$year, county_acs_data$name)

# format data 
# year rows, county columns, removed data quality info
pivot <- county_acs_data %>% 
  select(name, estimate, year) %>% 
  pivot_wider(names_from = name,
              values_from = estimate)

# create workbook with data
work_book <- createWorkbook()

addWorksheet(work_book, sheetName = "median income")
writeData(work_book, sheet = "median income", pivot)
writeData(work_book, sheet = "median income", x = data.frame(source_info), startRow = nrow(pivot) + 3, startCol = 1)

saveWorkbook(work_book, 
             file = file.path(export_path, 
                                         "medincome_regdataprofile.xlsx"), 
             overwrite = TRUE)
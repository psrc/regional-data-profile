library(tidyverse)
library(psrcelmer)
library(psrccensus)
library(openxlsx)
library(here)

export_path <- "J:/Projects/regional_data_profile"
source_info_1 <- c("U.S. Census Bureau, 2010-2023 American Community Survey 1-Year Estimates, Table B25014;. Calculated by Mary Richards.")
source_info_2 <- c("U.S. Census Bureau, 2010-2023 American Community Survey 1-Year Estimates, Table S1701;. Calculated by Mary Richards.")

year_range <- c("2010", "2011", "2012", "2013", "2014", "2015", 
                "2016", "2017", "2018", "2019", #"2020",
                "2021", "2022", "2023")

# The regular 1-year ACS for 2020 was not released and is not available in tidycensus. Due to low response rates, the Census Bureau instead released a set of experimental estimates for the 2020 1-year ACS. These estimates can be downloaded at https://www.census.gov/programs-surveys/acs/data/experimental-data/1-year.html.
# Data only available at state level. 

# median income -----
county_acs_data_medianincome <- get_acs_recs(geography ='county', 
                                             table.names = 'B19013', # median income ACS table
                                             years = c(as.numeric(year_range)),
                                             acs.type = 'acs1')

# checking data
nrow(county_acs_data_medianincome) #52 - 13 years, 4 counties
table(county_acs_data_medianincome$year, county_acs_data_medianincome$name)

# format data 
# year rows, county columns, removed data quality info
pivot_medincome <- county_acs_data_medianincome %>% 
  select(name, estimate, year) %>% 
  pivot_wider(names_from = name,
              values_from = estimate)

# create workbook with data
work_book <- createWorkbook()

addWorksheet(work_book, sheetName = "median income")
writeData(work_book, sheet = "median income", pivot_medincome)
writeData(work_book, sheet = "median income", 
          x = data.frame(source_info_1), 
          startRow = nrow(pivot_medincome) + 3, 
          startCol = 1)


# poverty status -----
county_acs_data_poverty <- get_acs_recs(geography ='county', 
                                        table.names = 'S1701', # poverty status ACS table
                                        years = c(as.numeric(year_range)),
                                        acs.type = 'acs1') 

filter <- county_acs_data_poverty %>% 
  filter(variable=="S1701_C03_001", # Percent below poverty level!!Estimate!!Population for whom poverty status is determined
         name != "Region") 

# checking data
nrow(filter) #52 - 13 years, 4 counties
table(filter$year, filter$name)

# format data 
# year rows, county columns, removed data quality info
pivot_poverty <- filter %>% 
  select(name, estimate, year) %>% 
  pivot_wider(names_from = name,
              values_from = estimate)

# add data to workbook
addWorksheet(work_book, sheetName = "poverty")
writeData(work_book, sheet = "poverty", pivot_poverty)
writeData(work_book, sheet = "poverty", x = data.frame(source_info_2), startRow = nrow(pivot_poverty) + 3, startCol = 1)

# export workbook to Y drive project folder
saveWorkbook(work_book, 
             file = file.path(export_path, 
                              "income__poverty_regdataprofile.xlsx"), 
             overwrite = TRUE)

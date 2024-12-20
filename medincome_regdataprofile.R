library(tidyverse)
library(psrcelmer)
library(psrccensus)
library(here)

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

write.csv(county_acs_data,
          "T:/2024November/Mary/Other/medincome_regdataprofile.csv")

#### Tidyverse Tutorial with Norah and Julie ####
# Kalina Hunter, Oct 3, 2019

#Tidyverse is a universe of packages for organizing, cleaning, etc. your data

install.packages('tidyverse')
library(tidyverse)

load("LPIdata_Feb2016.Rdata")
load("puffin_GBIF.Rdata")

puffins <- puffin_GBIF
head(puffins)


#### 1. HOW TO FORMAT YOUR DATA ####

# Reshaping data frames using gather()
# Long format = each row represents an observation and each column represents a variable
# LONG FORMAT IS THE STANDARD --> ENTER DATA THIS WAY

# look at the data
# It's not tidy, since it's WIDE FORMAT
View(head(LPIdata_Feb2016))

# Gives you column numbers
names(LPIdata_Feb2016)

# For gathering you need 2 columns: what you're gathering (year) and then the values associated with that (pop'n)
# Gather allows you to pick a variable (e.g. year) and organize the data by that (the KEY)
# KEY = COLUMN; VALUES = CELL VALUES); SELECT = DO IT FOR THESE COLUMNS
# value is what it's currently sorted by? in this case pop = pop'n
# When you manipulate data, always rename it and be descriptive
LPI_long <- gather(data = LPIdata_Feb2016, key = "year", value = "pop", select = 26:70)

# Tibble is a dataframe in tidyverse, gives you more info (if something is a factor, number of rows/columns)
LPI_long <- as.tibble(LPI_long)


#### 2. Manipulating data using dyplr

# To make sure there are no duplicate rows, we can use distinct(): (tidy version of unique)
LPI_long <- distinct(LPI_long)
LPI_long
# Before there was 747,180 observations
# Distinct shows there was only 684,990 distinct
747180 - 684990
# = 62 190 repeats!!!


# Then we can remove any rows that have missing or infinite data:
# Although it might not be best practice to filter out NAs (biologically they might be zeros)
# But some functions won't work if you have NAs
LPI_long_fl <- filter(LPI_long, is.finite(pop))
LPI_long_fl

# Pipes = sequence of operations on how to manipulate your data
# Efficient, keeps it all together
# cmd + shft + m
LPI_long <- LPI_long_fl %>%
  group_by(genus_species_id) %>%  # group rows so that each group is one population
  mutate(maxyear = max(year), minyear = min(year),  # Create columns for the first and most recent years that data was collected
         lengthyear = maxyear-minyear,  # Create a column for the length of time data available
         scalepop = (pop-min(pop))/(max(pop)-min(pop))) %>%  # Scale population trend data so that all values are between 0 and 1
  filter(is.finite(scalepop),  # remove NAs
         lengthyear > 5) %>%  # Only keep rows with more than 5 years of data
  ungroup()  # Remove any groupings you've greated in the pipe



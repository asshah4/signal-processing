#!/usr/bin/env Rscript

# File to extract Matlab code ~ practice
library(tidyverse)
library(lubridate)
library(magrittr)

# Start time
start_time <- Sys.time()

# Read in raw data
tmp <- read_delim("test.txt", delim = "\n", col_names = FALSE)

# Structure is a very tall, tall tibble. Extract only relevant rows
time <- tmp$X1[grep("Sample", tmp$X1)]
rr <- tmp$X1[grep("RRI", tmp$X1)]

# Combine into dataframe
# Split into columns to help extract time stamps
df <- 
  inner_join(enframe(time, value = "time"), enframe(rr, value = "RR"), by = "name") %>% # combine into a single data frame
  separate(time, sep = ',', into = c("index", "datetime", "lead", "flash", "hr", "resp", "activity", "mag"), remove = TRUE) %>%  # Split up initial string of sample data into its components
  separate(index, into = c("sample", "index"), sep = "=", remove = TRUE, convert = TRUE) %>% # extract the time index 
  separate(datetime, into = c("trash", "datetime"), sep = "=", remove = TRUE, convert = TRUE) %>%  # Need to convert this date time column appropriately downstream
  separate(hr, into = c("hr", "bpm"), sep = "=", remove = TRUE, convert = TRUE)  %>% # Pull HR in bpm
  separate(resp, into = c("rr", "resp"), sep = "=", remove = TRUE, convert = TRUE) # Extract predicted respiratory rate
  
# Convert date time format, but need to preserve miliseconds
options(digits.secs = 3)
df$datetime %<>% ymd_hms()

# Extract the RR intervals as well
df$RR <- str_extract(df$RR, "\\d+") %>% as.integer(.)

# Select relevant columns
df <- df[c("index", "datetime", "bpm", "resp", "RR")]

# Sort row order
df <- df[order(df$index),]

# Write to a file readable by stupid matlab
write_csv(df, "temp.csv", append = FALSE, col_names = TRUE)

# End of process
end_time <- Sys.time()
print(end_time - start_time)

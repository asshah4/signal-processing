#!/usr/bin/env Rscript

#### Read in raw VivaLNK for time stamps ####

# Read in raw data
tmp <- read_delim(file.path(raw_folder, paste0(name, ".txt")), delim="\n", col_names=FALSE)

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

# Final form of vivalnk raw text information
df_vivalnk <- df[order(df$index),]

# Write to a file readable by stupid matlab
write_csv(df_vivalnk, file.path(folder, paste0(name, ".csv")), append = FALSE, col_names = TRUE)

# Remove unused files
rm(time, rr)

#### Read in HRV ####
rawfile <- read_csv(Sys.glob(file.path(folder, "*allwindows*.csv")), col_names = TRUE)

# Pick out relevant columns
svar <- c("t_start", "NNmean", "SDNN", "RMSSD", "pnn50", "ulf", "vlf", "lf", "hf", "lfhf", "ttlpwr", "ac", "dc", "SampEn", "ApEn")
df <- rawfile[svar] %>% na.omit()
names(df) <- c("time", "NN", "SDNN", "RMSSD", "PNN50", "ULF", "VLF", "LF", "HF", "LFHF", "TP", "AC", "DC", "SampEn", "ApEn")

# Saved final HRV data
df_hrv <- df

# Removed files
removed <- read_csv(Sys.glob(file.path(folder, "Removed*")), col_names = TRUE)

# HRV parameters
hrvparams <- read_csv(Sys.glob(file.path(folder, "Parameters*.csv")), col_names = TRUE)

# Cath/chart data
# Including timing
interventions <- read_excel(Sys.glob(file.path(raw_folder, "patient_log.xlsx")))
